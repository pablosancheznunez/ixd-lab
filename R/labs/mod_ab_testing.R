# A/B testing: plan a sample size, run a simulated experiment, and see why peeking inflates false positives.
ab_sample_size <- function(base, mde_rel, alpha = .05, power = .8) {
  p1 <- base; p2 <- base * (1 + mde_rel)
  if (p2 <= 0 || p2 >= 1) return(NA_real_)
  ceiling(power.prop.test(p1 = p1, p2 = p2, sig.level = alpha, power = power)$n)
}

# Two-proportion z-test p-values, vectorised over cumulative counts.
z_pvalue <- function(xa, na, xb, nb) {
  p <- (xa + xb) / (na + nb)
  se <- sqrt(p * (1 - p) * (1 / na + 1 / nb))
  z <- ifelse(se > 0, (xb / nb - xa / na) / se, 0)
  2 * pnorm(-abs(z))
}

ab_testing_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Plan the sample size an experiment needs before running it.", "Planificar el tamaño de muestra que necesita un experimento antes de lanzarlo."),
                   tr("Read a result with its confidence interval and p-value.", "Leer un resultado con su intervalo de confianza y su valor p."),
                   tr("Understand why stopping early when results look good creates false positives.", "Entender por qué parar antes de tiempo cuando el resultado parece bueno crea falsos positivos.")),
    concept = tr("An A/B test randomly splits people between versions so that differences in behaviour can be attributed to the change. It answers ‘which works better?’, not ‘why?’, and only if it has enough traffic and is analysed as planned.",
                 "Un test A/B reparte a la gente al azar entre versiones para poder atribuir al cambio las diferencias de comportamiento. Responde a «¿qué funciona mejor?», no a «¿por qué?», y solo si tiene tráfico suficiente y se analiza como se planificó."),
    activity = tagList(
      navset_underline(
        nav_panel(tr("1 · Plan", "1 · Planifica"),
          div(class = "pt-3", layout_columns(col_widths = c(5, 7),
            div(
              numericInput(ns("base"), tr("Current conversion rate (%)", "Tasa de conversión actual (%)"), 8, min = .1, max = 90, step = .5),
              numericInput(ns("mde"), tr("Smallest relative lift worth detecting (%)", "Mejora relativa mínima que merece detectar (%)"), 10, min = 1, max = 200, step = 1),
              numericInput(ns("traffic"), tr("Visitors per day (both versions)", "Visitantes al día (ambas versiones)"), 2000, min = 10, step = 100),
              radioButtons(ns("power"), tr("Statistical power", "Potencia estadística"), c("80%" = .8, "90%" = .9), inline = TRUE)),
            uiOutput(ns("plan"))))),
        nav_panel(tr("2 · Run", "2 · Ejecuta"),
          div(class = "pt-3", layout_columns(col_widths = c(5, 7),
            div(
              sliderInput(ns("true_lift"), tr("True effect of version B (hidden in real life!)", "Efecto real de la versión B (¡oculto en la vida real!)"), -20, 30, 5, step = 1, post = "%"),
              numericInput(ns("visitors"), tr("Visitors per version", "Visitantes por versión"), 5000, min = 100, step = 500),
              actionButton(ns("run"), tr("Run the experiment", "Lanzar el experimento"), class = "btn-primary"),
              p(class = "footnote mt-2", tr("Each run is a new random sample: run it several times and watch the result change.", "Cada lanzamiento es una nueva muestra aleatoria: lánzalo varias veces y observa cómo cambia el resultado."))),
            div(plotOutput(ns("run_plot"), height = "230px"), uiOutput(ns("run_result")))))),
        nav_panel(tr("3 · The peeking problem", "3 · El problema de mirar antes"),
          div(class = "pt-3",
            p(tr("Here A and B are identical (an A/A test), so any ‘significant’ result is a false positive. A team checks the p-value every day for 30 days and stops as soon as p < 0.05.",
                 "Aquí A y B son idénticas (un test A/A), así que cualquier resultado «significativo» es un falso positivo. Un equipo mira el valor p cada día durante 30 días y para en cuanto p < 0,05.")),
            actionButton(ns("peek"), tr("Simulate 200 A/A tests", "Simular 200 tests A/A"), class = "btn-primary"),
            layout_columns(col_widths = c(7, 5), class = "mt-3",
              plotOutput(ns("peek_plot"), height = "280px"),
              uiOutput(ns("peek_result"))))))),
    reflection = tr("Your stakeholder wants to stop the test on day 3 because B is ‘winning’. What do you tell them, and what would you have agreed before the test started?",
                    "Tu responsable quiere parar el test el día 3 porque B «va ganando». ¿Qué le dices y qué habrías acordado antes de empezar?"))
}

ab_testing_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    plan <- reactive({
      n <- ab_sample_size(input$base / 100, input$mde / 100, power = as.numeric(input$power))
      list(n = n, days = if (is.na(n)) NA else ceiling(2 * n / max(1, input$traffic)))
    })
    output$plan <- renderUI({
      p <- plan()
      if (is.na(p$n)) return(div(class = "alert alert-warning", tr("That lift takes the rate outside 0–100%.", "Esa mejora saca la tasa fuera del 0–100%.")))
      div(class = "panel-soft",
        span(class = "eyebrow", tr("YOU NEED", "NECESITAS")),
        div(class = "big-number", format(p$n, big.mark = tr(",", "."))),
        p(class = "mb-1", tr("visitors per version", "visitantes por versión")),
        p(sprintf(tr("At %s visitors a day, that is about <strong>%d days</strong>. Run whole weeks to cover weekday and weekend behaviour.",
                     "Con %s visitantes al día, son unos <strong>%d días</strong>. Haz semanas completas para cubrir el comportamiento entre semana y en fin de semana."),
                  format(input$traffic, big.mark = tr(",", ".")), p$days) |> HTML()),
        p(class = "footnote mb-0", sprintf(tr("Detecting %.1f%% → %.1f%% with 5%% significance and %s power. Halving the detectable lift roughly quadruples the sample.",
                                              "Detectar %.1f%% → %.1f%% con un 5%% de significación y una potencia del %s. Reducir a la mitad la mejora detectable cuadruplica aproximadamente la muestra."),
                                           input$base, input$base * (1 + input$mde / 100), paste0(100 * as.numeric(input$power), "%"))))
    })

    run <- reactiveVal(NULL)
    observeEvent(input$run, {
      n <- max(100, round(input$visitors)); pa <- input$base / 100; pb <- min(.99, max(.001, pa * (1 + input$true_lift / 100)))
      xa <- rbinom(1, n, pa); xb <- rbinom(1, n, pb)
      t <- suppressWarnings(prop.test(c(xb, xa), c(n, n), correct = FALSE))
      run(list(n = n, xa = xa, xb = xb, diff = xb / n - xa / n, ci = t$conf.int, p = t$p.value, true = input$true_lift))
    })
    output$run_plot <- renderPlot({
      r <- run()
      if (is.null(r)) { ixd_par(); plot.new(); text(.5, .5, tr("Run the experiment to see the result", "Lanza el experimento para ver el resultado"), col = "#5f665f"); return() }
      rates <- c(r$xa, r$xb) / r$n
      se <- sqrt(rates * (1 - rates) / r$n)
      ixd_par()
      b <- barplot(100 * rates, names.arg = c("A", "B"), col = c("#bdb9ae", ixd_green), border = NA, ylim = c(0, 100 * max(rates + 2.5 * se)), ylab = tr("Conversion (%)", "Conversión (%)"))
      arrows(b, 100 * (rates - 1.96 * se), b, 100 * (rates + 1.96 * se), angle = 90, code = 3, length = .08, lwd = 2)
    }, res = 96)
    output$run_result <- renderUI({
      r <- run(); if (is.null(r)) return(NULL)
      sig <- r$p < .05
      verdict <- if (sig && r$diff > 0) tr("B is significantly better.", "B es significativamente mejor.")
                 else if (sig) tr("B is significantly worse.", "B es significativamente peor.")
                 else tr("No significant difference: the interval includes zero.", "No hay diferencia significativa: el intervalo incluye el cero.")
      truth <- if (r$true == 0 && sig) tr(" But the true effect is zero: this is a false positive (it happens about 5% of the time).", " Pero el efecto real es cero: es un falso positivo (ocurre en torno al 5% de las veces).")
               else if (r$true != 0 && !sig) tr(" But B really is different: the test was underpowered for this effect (a false negative).", " Pero B es realmente distinta: el test no tenía potencia suficiente para este efecto (un falso negativo).")
               else ""
      div(class = paste("alert mt-2", if (sig) "alert-success" else "alert-secondary"),
        p(class = "mb-1", sprintf(tr("A: %d/%d · B: %d/%d", "A: %d/%d · B: %d/%d"), r$xa, r$n, r$xb, r$n)),
        p(class = "mb-1", sprintf(tr("Difference: %+.2f points, 95%% CI %+.2f to %+.2f · p = %.3f", "Diferencia: %+.2f puntos, IC 95%% %+.2f a %+.2f · p = %.3f"), 100 * r$diff, 100 * r$ci[1], 100 * r$ci[2], r$p)),
        tags$strong(verdict), truth)
    })

    peek <- reactiveVal(NULL)
    observeEvent(input$peek, {
      days <- 30; per_day <- max(20, round(input$traffic / 2)); pa <- input$base / 100; sims <- 200
      res <- lapply(seq_len(sims), function(s) {
        xa <- cumsum(rbinom(days, per_day, pa)); xb <- cumsum(rbinom(days, per_day, pa)); n <- per_day * seq_len(days)
        z_pvalue(xa, n, xb, n)
      })
      pv <- do.call(rbind, res)
      peek(list(pv = pv, peeking = mean(apply(pv, 1, function(r) any(r < .05))), end = mean(pv[, days] < .05)))
    })
    output$peek_plot <- renderPlot({
      k <- peek()
      if (is.null(k)) { ixd_par(); plot.new(); text(.5, .5, tr("Simulate to see 20 of the p-value paths", "Simula para ver 20 de las trayectorias del valor p"), col = "#5f665f"); return() }
      ixd_par()
      matplot(t(k$pv[1:20, ]), type = "l", lty = 1, col = adjustcolor(ixd_green, .5), log = "y", ylim = c(.001, 1), xlab = tr("Day", "Día"), ylab = tr("p-value (log scale)", "Valor p (escala log)"))
      abline(h = .05, col = ixd_red, lwd = 2, lty = 2)
    }, res = 96)
    output$peek_result <- renderUI({
      k <- peek(); if (is.null(k)) return(NULL)
      div(class = "panel-soft",
        span(class = "eyebrow", tr("FALSE POSITIVES", "FALSOS POSITIVOS")),
        p(class = "mb-1", sprintf(tr("Checking every day and stopping at p < .05: <strong>%.0f%%</strong> of tests ‘find’ a winner.", "Mirando cada día y parando en p < 0,05: el <strong>%.0f%%</strong> de los tests «encuentra» un ganador."), 100 * k$peeking) |> HTML()),
        p(class = "mb-2", sprintf(tr("Analysing only once, on day 30: <strong>%.0f%%</strong>, close to the promised 5%%.", "Analizando una sola vez, el día 30: <strong>%.0f%%</strong>, cerca del 5%% prometido."), 100 * k$end) |> HTML()),
        p(class = "footnote mb-0", tr("Fix the sample size in advance, or use a method designed for continuous monitoring (sequential tests).", "Fija el tamaño de muestra de antemano o usa un método diseñado para la monitorización continua (tests secuenciales).")))
    })

    lines <- function() {
      p <- plan(); r <- run(); k <- peek()
      c(sprintf(tr("Plan: base %.1f%%, lift %d%% → %s visitors per version, about %s days", "Plan: base %.1f%%, mejora %d%% → %s visitantes por versión, unos %s días"), input$base, as.integer(input$mde), p$n, p$days),
        if (!is.null(r)) sprintf(tr("Experiment: true lift %d%%, observed difference %+.2f points (95%% CI %+.2f to %+.2f), p = %.3f", "Experimento: mejora real %d%%, diferencia observada %+.2f puntos (IC 95%% %+.2f a %+.2f), p = %.3f"), as.integer(r$true), 100 * r$diff, 100 * r$ci[1], 100 * r$ci[2], r$p),
        if (!is.null(k)) sprintf(tr("Peeking: %.0f%% false positives with daily checks vs %.0f%% with one final analysis", "Mirar antes: %.0f%% de falsos positivos mirando a diario frente a %.0f%% con un único análisis final"), 100 * k$peeking, 100 * k$end))
    }
    observeEvent(input$example, {
      updateNumericInput(session, "base", value = 8); updateNumericInput(session, "mde", value = 10); updateNumericInput(session, "traffic", value = 2000)
      updateSliderInput(session, "true_lift", value = 0)
      example_reflection(session, tr("Day 3 is far too early: we agreed on about 19,000 visitors per version, roughly 19 days, and stopping when B looks good inflates false positives well above 5%. Before the test I would document the hypothesis, the primary metric, the sample size and the stopping rule.",
                                     "El día 3 es demasiado pronto: acordamos unos 19.000 visitantes por versión, unos 19 días, y parar cuando B parece mejor dispara los falsos positivos muy por encima del 5%. Antes del test dejaría por escrito la hipótesis, la métrica principal, el tamaño de muestra y la regla de parada."))
    })

    reflect_server(tr("A/B testing", "Tests A/B"), input, output, session, lines)
  })
}

lab_content$ab <- list(
  theory = list(
    list(title = tr("Controlled experiments online", "Experimentos controlados en línea"), body = c(
      tr("In an A/B test, each visitor is randomly assigned to a version and a pre-defined <strong>primary metric</strong> (for example, conversion) is compared. Randomisation balances everything else on average, so a difference can be attributed to the change. Kohavi, Tang and Xu call these ‘trustworthy online controlled experiments’ when they follow a careful protocol.",
         "En un test A/B, cada visitante se asigna al azar a una versión y se compara una <strong>métrica principal</strong> definida de antemano (por ejemplo, la conversión). La aleatorización equilibra en promedio todo lo demás, así que la diferencia se puede atribuir al cambio. Kohavi, Tang y Xu los llaman «experimentos controlados en línea fiables» cuando siguen un protocolo cuidadoso."))),
    list(title = tr("Significance, power and sample size", "Significación, potencia y tamaño de muestra"), body = c(
      tr("The <strong>significance level</strong> (α = 5%) is the false-positive rate you accept when there is no real effect. <strong>Power</strong> (usually 80%) is the chance of detecting a real effect of the size you care about, the <strong>minimum detectable effect</strong>. Small effects on low conversion rates need large samples.",
         "El <strong>nivel de significación</strong> (α = 5%) es la tasa de falsos positivos que aceptas cuando no hay efecto real. La <strong>potencia</strong> (normalmente 80%) es la probabilidad de detectar un efecto real del tamaño que te importa, el <strong>efecto mínimo detectable</strong>. Los efectos pequeños sobre tasas de conversión bajas necesitan muestras grandes."),
      tr("A p-value is the probability of seeing a difference at least this large if there were no real effect. It is not the probability that B is better. Report the effect with its confidence interval.",
         "Un valor p es la probabilidad de observar una diferencia al menos así de grande si no hubiera efecto real. No es la probabilidad de que B sea mejor. Presenta el efecto con su intervalo de confianza."))),
    list(title = tr("Pitfalls", "Trampas habituales"), body = c(
      tr("<strong>Peeking</strong> (stopping when the result looks significant) and testing many metrics or segments without correction both inflate false positives. Watch for <strong>novelty effects</strong>, sample ratio mismatch (unequal split caused by bugs), and changes that harm long-term metrics or users' interests. Experiments with people also raise ethical questions: inform users where appropriate and do not test deceptive designs.",
         "<strong>Mirar antes</strong> (parar cuando el resultado parece significativo) y probar muchas métricas o segmentos sin corrección inflan los falsos positivos. Vigila los <strong>efectos de novedad</strong>, el desajuste en el reparto de la muestra (causado por errores técnicos) y los cambios que perjudican métricas a largo plazo o los intereses de los usuarios. Los experimentos con personas también plantean cuestiones éticas: informa cuando proceda y no pruebes diseños engañosos.")))),
  mistakes = c(
    tr("Stopping the test as soon as it looks significant.", "Parar el test en cuanto parece significativo."),
    tr("Running a test with far too little traffic and concluding ‘no difference’.", "Lanzar un test con muy poco tráfico y concluir «no hay diferencia»."),
    tr("Choosing the success metric after seeing the results.", "Elegir la métrica de éxito después de ver los resultados."),
    tr("Testing many variants and reporting only the one that won.", "Probar muchas variantes y presentar solo la que ganó.")),
  reading = c(
    "Kohavi, R., Tang, D., &amp; Xu, Y. (2020). <em>Trustworthy Online Controlled Experiments</em>. Cambridge University Press.",
    "Georgiev, G. (2019). <em>Statistical Methods in Online A/B Testing</em>. Self-published.",
    "Wasserstein, R. L., &amp; Lazar, N. A. (2016). The ASA statement on p-values. <em>The American Statistician, 70</em>(2), 129–133.",
    "Johari, R., et al. (2017). Peeking at A/B tests. <em>KDD '17</em>, 1517–1525."),
  quiz = list(
    list(q = tr("What does p = 0.03 mean in an A/B test?", "¿Qué significa p = 0,03 en un test A/B?"),
         options = c(tr("There is a 97% chance that B is better", "Hay un 97% de probabilidad de que B sea mejor"), tr("If there were no real difference, a result this extreme would occur about 3% of the time", "Si no hubiera diferencia real, un resultado así de extremo ocurriría un 3% de las veces"), tr("B improves conversion by 3%", "B mejora la conversión un 3%")),
         answer = 2, why = tr("A p-value is computed assuming no effect; it is not the probability that the hypothesis is true.", "Un valor p se calcula suponiendo que no hay efecto; no es la probabilidad de que la hipótesis sea cierta.")),
    list(q = tr("Why is checking results daily and stopping at p < 0.05 a problem?", "¿Por qué es un problema mirar los resultados a diario y parar en p < 0,05?"),
         options = c(tr("It wastes traffic", "Desperdicia tráfico"), tr("It inflates the false-positive rate well above 5%", "Dispara la tasa de falsos positivos muy por encima del 5%"), tr("It reduces power", "Reduce la potencia")),
         answer = 2, why = tr("Each look is another chance for noise to cross the threshold.", "Cada vistazo es otra oportunidad de que el ruido cruce el umbral.")),
    list(q = tr("You halve the minimum detectable effect. The required sample size…", "Reduces a la mitad el efecto mínimo detectable. El tamaño de muestra necesario…"),
         options = c(tr("Halves", "Se reduce a la mitad"), tr("Doubles", "Se duplica"), tr("Roughly quadruples", "Se cuadruplica aproximadamente")),
         answer = 3, why = tr("Sample size scales with 1/effect², so half the effect needs about four times the sample.", "El tamaño de muestra escala con 1/efecto², así que la mitad del efecto requiere unas cuatro veces la muestra.")))
)
