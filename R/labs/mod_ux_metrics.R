# Usability testing and metrics: SUS scoring, task success with confidence intervals,
# task time, and how many participants find how many problems.
sus_items <- c(
  tr("I think that I would like to use this system frequently.", "Creo que me gustaría usar este sistema con frecuencia."),
  tr("I found the system unnecessarily complex.", "El sistema me ha parecido innecesariamente complejo."),
  tr("I thought the system was easy to use.", "El sistema me ha parecido fácil de usar."),
  tr("I think that I would need the support of a technical person to be able to use this system.", "Creo que necesitaría ayuda de una persona técnica para poder usar este sistema."),
  tr("I found the various functions in this system were well integrated.", "Las distintas funciones del sistema me han parecido bien integradas."),
  tr("I thought there was too much inconsistency in this system.", "He encontrado demasiadas incoherencias en este sistema."),
  tr("I would imagine that most people would learn to use this system very quickly.", "Imagino que la mayoría de la gente aprendería a usar este sistema muy rápido."),
  tr("I found the system very cumbersome to use.", "El sistema me ha parecido muy engorroso de usar."),
  tr("I felt very confident using the system.", "Me he sentido muy seguro usando el sistema."),
  tr("I needed to learn a lot of things before I could get going with this system.", "He necesitado aprender muchas cosas antes de poder manejar este sistema.")
)

sus_score <- function(r) {
  r <- as.numeric(r)
  2.5 * (sum(r[c(1, 3, 5, 7, 9)] - 1) + sum(5 - r[c(2, 4, 6, 8, 10)]))
}
sus_grade <- function(s) {
  if (s >= 80.3) tr("Excellent: top 10% of products (grade A)", "Excelente: entre el 10% mejor de los productos (nota A)")
  else if (s >= 68) tr("Above the average of 68", "Por encima de la media de 68")
  else if (s >= 51) tr("Below average", "Por debajo de la media")
  else tr("Poor: bottom 15% of products", "Pobre: entre el 15% peor de los productos")
}

# Adjusted Wald (Agresti–Coull) interval: recommended for small-sample completion rates (Sauro & Lewis).
adjusted_wald <- function(x, n, conf = .95) {
  z <- qnorm(1 - (1 - conf) / 2)
  p <- (x + z^2 / 2) / (n + z^2)
  se <- sqrt(p * (1 - p) / (n + z^2))
  c(max(0, p - z * se), min(1, p + z * se))
}

metrics_study <- local({
  set.seed(42)
  tasks <- c(tr("Find this week's reading", "Encontrar la lectura de la semana"), tr("Submit an assignment", "Entregar un trabajo"), tr("Book office hours", "Reservar una tutoría"))
  p_success <- c(.9, .7, .4); mean_time <- c(55, 120, 210)
  d <- expand.grid(participant = paste0("P", 1:10), task = tasks, stringsAsFactors = FALSE)
  d$success <- rbinom(nrow(d), 1, rep(p_success, each = 10))
  d$time <- round(exp(rnorm(nrow(d), log(rep(mean_time, each = 10)), .45)))
  d$errors <- rpois(nrow(d), rep(c(.3, 1, 2), each = 10))
  list(tasks = tasks, data = d, sus = round(pmin(100, pmax(20, rnorm(10, 66, 14))) / 2.5) * 2.5)
})

ux_metrics_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Score the System Usability Scale and interpret it against benchmarks.", "Puntuar la System Usability Scale e interpretarla con valores de referencia."),
                   tr("Report task success and time with confidence intervals.", "Presentar el éxito y el tiempo en las tareas con intervalos de confianza."),
                   tr("Decide how many participants a test needs.", "Decidir cuántos participantes necesita un test.")),
    concept = tr("Usability (ISO 9241-11) is effectiveness, efficiency and satisfaction in a context of use. Measure all three, and always report uncertainty: with 10 participants, 70% success could really be anywhere from about 40% to 90%.",
                 "La usabilidad (ISO 9241-11) es eficacia, eficiencia y satisfacción en un contexto de uso. Mide las tres y presenta siempre la incertidumbre: con 10 participantes, un 70% de éxito podría estar en realidad entre un 40% y un 90%."),
    activity = tagList(
      navset_underline(
        nav_panel(tr("1 · SUS questionnaire", "1 · Cuestionario SUS"),
          div(class = "pt-3",
            p(tr("Think of a system you used today (your email, the university portal…) and answer as a participant would. 1 = strongly disagree, 5 = strongly agree.",
                 "Piensa en un sistema que hayas usado hoy (tu correo, el portal de la universidad…) y responde como lo haría un participante. 1 = muy en desacuerdo, 5 = muy de acuerdo.")),
            layout_columns(col_widths = c(7, 5),
              div(class = "sus-items", lapply(seq_along(sus_items), function(i)
                radioButtons(ns(paste0("sus_", i)), paste0(i, ". ", sus_items[i]), choices = 1:5, selected = 3, inline = TRUE, width = "100%"))),
              uiOutput(ns("sus_result"))))),
        nav_panel(tr("2 · Analyse a study", "2 · Analiza un estudio"),
          div(class = "pt-3",
            simulated_note(),
            p(tr("Ten participants tried three tasks on a learning platform. Choose a task to analyse.", "Diez participantes hicieron tres tareas en una plataforma de aprendizaje. Elige una tarea para analizarla.")),
            radioButtons(ns("task"), NULL, metrics_study$tasks, inline = TRUE),
            layout_columns(col_widths = c(6, 6),
              plotOutput(ns("task_plot"), height = "300px"),
              uiOutput(ns("task_stats"))),
            tags$details(class = "footnote mt-2", tags$summary(tr("See the raw data", "Ver los datos brutos")), tableOutput(ns("raw"))))),
        nav_panel(tr("3 · How many users?", "3 · ¿Cuántos usuarios?"),
          div(class = "pt-3",
            layout_columns(col_widths = c(4, 8),
              div(
                sliderInput(ns("p"), tr("Probability that one participant meets a given problem (p)", "Probabilidad de que un participante encuentre un problema concreto (p)"), .05, .6, .31, step = .01),
                sliderInput(ns("n"), tr("Participants (n)", "Participantes (n)"), 1, 20, 5, step = 1),
                uiOutput(ns("discovery"))),
              plotOutput(ns("discovery_plot"), height = "300px")))))),
    reflection = tr("Which of the three tasks would you fix first, and which metric convinced you? What does the confidence interval change in how you would report it?",
                    "¿Qué tarea arreglarías primero y qué métrica te convenció? ¿Qué cambia el intervalo de confianza en cómo lo comunicarías?"))
}

ux_metrics_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    sus_answers <- reactive(vapply(seq_along(sus_items), function(i) as.numeric(input[[paste0("sus_", i)]] %||% 3), 1))
    output$sus_result <- renderUI({
      s <- sus_score(sus_answers())
      div(class = "panel-soft sticky-panel",
        span(class = "eyebrow", tr("SUS SCORE", "PUNTUACIÓN SUS")),
        div(class = "big-number", s),
        div(class = "meter", div(class = "meter-fill", style = sprintf("width:%.0f%%", s)), div(class = "meter-mark", style = "left:68%", title = "68")),
        p(class = "mt-2 mb-1", tags$strong(sus_grade(s))),
        p(class = "footnote mb-0", tr("Odd items: answer − 1. Even items: 5 − answer. Sum × 2.5 gives 0–100. It is not a percentage: 68 is the average across hundreds of studies (Sauro, 2011).",
                                      "Ítems impares: respuesta − 1. Ítems pares: 5 − respuesta. La suma × 2,5 da 0–100. No es un porcentaje: 68 es la media de cientos de estudios (Sauro, 2011).")))
    })

    task_data <- reactive(metrics_study$data[metrics_study$data$task == input$task, ])
    output$task_plot <- renderPlot({
      d <- task_data()
      ixd_par()
      plot(seq_len(nrow(d)), d$time, pch = ifelse(d$success == 1, 19, 4), cex = 1.6, col = ifelse(d$success == 1, ixd_green, ixd_red), log = "y",
           xaxt = "n", xlab = "", ylab = tr("Time on task (s, log scale)", "Tiempo en la tarea (s, escala log)"))
      axis(1, at = seq_len(nrow(d)), labels = d$participant, cex.axis = .8)
      ok <- d$success == 1
      if (sum(ok) > 1) abline(h = exp(mean(log(d$time[ok]))), col = ixd_green, lty = 2)
      legend("topleft", c(tr("Success", "Éxito"), tr("Failure", "Fallo")), pch = c(19, 4), col = c(ixd_green, ixd_red), bty = "n", cex = .85)
    }, res = 96)
    task_stats <- reactive({
      d <- task_data(); x <- sum(d$success); n <- nrow(d); ci <- adjusted_wald(x, n)
      ok <- d$success == 1
      gm <- if (sum(ok) > 1) { l <- log(d$time[ok]); se <- sd(l) / sqrt(length(l)); tq <- qt(.975, length(l) - 1); exp(mean(l) + c(0, -1, 1) * tq * se) } else rep(NA, 3)
      list(x = x, n = n, ci = ci, gm = gm, errors = mean(d$errors))
    })
    output$task_stats <- renderUI({
      s <- task_stats()
      div(class = "panel-soft",
        span(class = "eyebrow", tr("EFFECTIVENESS", "EFICACIA")),
        p(class = "mb-1", sprintf(tr("Completion: %d/%d = %.0f%%", "Éxito: %d/%d = %.0f%%"), s$x, s$n, 100 * s$x / s$n)),
        p(class = "footnote", sprintf(tr("95%% CI (adjusted Wald): %.0f%% – %.0f%%", "IC 95%% (Wald ajustado): %.0f%% – %.0f%%"), 100 * s$ci[1], 100 * s$ci[2])),
        span(class = "eyebrow", tr("EFFICIENCY", "EFICIENCIA")),
        p(class = "mb-1", if (is.na(s$gm[1])) tr("Too few successes to estimate time.", "Demasiados pocos éxitos para estimar el tiempo.")
                          else sprintf(tr("Typical time (geometric mean, successes): %.0f s", "Tiempo típico (media geométrica, éxitos): %.0f s"), s$gm[1])),
        if (!is.na(s$gm[1])) p(class = "footnote", sprintf(tr("95%% CI: %.0f – %.0f s", "IC 95%%: %.0f – %.0f s"), s$gm[2], s$gm[3])),
        p(class = "mb-0", sprintf(tr("Errors per participant: %.1f", "Errores por participante: %.1f"), s$errors)),
        p(class = "footnote mt-2 mb-0", sprintf(tr("Mean SUS for the whole study: %.1f", "SUS medio del estudio: %.1f"), mean(metrics_study$sus))))
    })
    output$raw <- renderTable({
      d <- task_data()[, c("participant", "success", "time", "errors")]
      setNames(d, c(tr("Participant", "Participante"), tr("Success", "Éxito"), tr("Time (s)", "Tiempo (s)"), tr("Errors", "Errores")))
    }, width = "100%")

    output$discovery <- renderUI({
      found <- 1 - (1 - input$p)^input$n
      need <- ceiling(log(1 - .85) / log(1 - input$p))
      div(class = "panel-soft",
        div(class = "big-number", sprintf("%.0f%%", 100 * found)),
        p(class = "footnote mb-1", sprintf(tr("of problems with p = %.2f are expected to be seen at least once with %d participants.", "de los problemas con p = %.2f se espera que se vean al menos una vez con %d participantes."), input$p, input$n)),
        p(class = "footnote mb-0", sprintf(tr("To see 85%% of them you need about %d participants.", "Para ver el 85%% necesitas unos %d participantes."), need)))
    })
    output$discovery_plot <- renderPlot({
      n <- 1:20; p <- input$p
      ixd_par()
      plot(n, 1 - (1 - p)^n, type = "l", lwd = 3, col = ixd_green, ylim = c(0, 1), xlab = tr("Participants", "Participantes"), ylab = tr("Share of problems found", "Proporción de problemas encontrados"))
      for (q in c(.1, .5)) graphics::lines(n, 1 - (1 - q)^n, col = "#bdb9ae", lty = 3)
      points(input$n, 1 - (1 - p)^input$n, pch = 19, cex = 2, col = ixd_sand)
      abline(h = .85, col = "#e3e0d7", lty = 2)
      text(20, c(1 - (1 - .1)^20, 1 - (1 - .5)^20) - .04, c("p = .10", "p = .50"), pos = 2, cex = .8, col = "#9a9a9a")
    }, res = 96)

    lines <- function() {
      s <- task_stats()
      c(sprintf(tr("SUS for the system I rated: %.1f (%s)", "SUS del sistema que valoré: %.1f (%s)"), sus_score(sus_answers()), sus_grade(sus_score(sus_answers()))),
        sprintf(tr("Task analysed: %s · completion %d/%d, 95%% CI %.0f–%.0f%%", "Tarea analizada: %s · éxito %d/%d, IC 95%% %.0f–%.0f%%"), input$task, s$x, s$n, 100 * s$ci[1], 100 * s$ci[2]),
        sprintf(tr("Problem discovery: p = %.2f, n = %d → %.0f%% of problems", "Descubrimiento de problemas: p = %.2f, n = %d → %.0f%% de los problemas"), input$p, input$n, 100 * (1 - (1 - input$p)^input$n)))
    }
    observeEvent(input$example, {
      for (i in seq_along(sus_items)) updateRadioButtons(session, paste0("sus_", i), selected = c(4, 2, 4, 1, 4, 2, 5, 2, 4, 2)[i])
      updateRadioButtons(session, "task", selected = metrics_study$tasks[3])
      updateSliderInput(session, "p", value = .2); updateSliderInput(session, "n", value = 8)
      example_reflection(session, tr("I would fix ‘Book office hours’ first: only 5 of 10 succeeded and it is also the slowest task. With 10 people the interval is wide, so I would report ‘about half, plausibly 24–76%’ rather than a single number, and retest after the fix.",
                                     "Arreglaría primero «Reservar una tutoría»: solo 5 de 10 lo consiguieron y además es la tarea más lenta. Con 10 personas el intervalo es amplio, así que diría «en torno a la mitad, plausiblemente 24–76%» en lugar de un único número, y volvería a probar tras el cambio."))
    })

    reflect_server(tr("Usability testing and metrics", "Tests de usabilidad y métricas"), input, output, session, lines)
  })
}

lab_content$metrics <- list(
  theory = list(
    list(title = tr("Planning and moderating a usability test", "Planificar y moderar un test de usabilidad"), body = c(
      tr("Define the research questions, recruit participants who match the users, write realistic <strong>task scenarios</strong> with a clear end point, and pilot the session. During the test, use the <strong>think-aloud</strong> protocol, stay neutral, and avoid helping unless the participant is completely stuck.",
         "Define las preguntas de investigación, recluta participantes que se parezcan a los usuarios, escribe <strong>escenarios de tarea</strong> realistas con un final claro y haz una sesión piloto. Durante el test, usa el protocolo de <strong>pensamiento en voz alta</strong>, mantente neutral y no ayudes salvo que el participante esté completamente bloqueado."),
      tr("Qualitative (formative) tests find problems to fix; quantitative (summative) tests measure performance against a benchmark or competitor and need larger samples.",
         "Los tests cualitativos (formativos) encuentran problemas que arreglar; los cuantitativos (sumativos) miden el rendimiento frente a un valor de referencia o un competidor y necesitan muestras mayores."))),
    list(title = tr("The core metrics", "Las métricas principales"), body = c(
      tr("<strong>Effectiveness</strong>: task completion rate and errors. <strong>Efficiency</strong>: time on task, usually summarised with the geometric mean because times are skewed. <strong>Satisfaction</strong>: standardised questionnaires such as <strong>SUS</strong> (Brooke, 1996), UMUX-Lite, or the single-ease question (SEQ) after each task.",
         "<strong>Eficacia</strong>: tasa de éxito en la tarea y errores. <strong>Eficiencia</strong>: tiempo en la tarea, que suele resumirse con la media geométrica porque los tiempos son asimétricos. <strong>Satisfacción</strong>: cuestionarios estandarizados como el <strong>SUS</strong> (Brooke, 1996), el UMUX-Lite o la pregunta de facilidad única (SEQ) tras cada tarea."),
      tr("For small samples, Sauro and Lewis recommend the adjusted Wald interval for completion rates and log-transformed times for confidence intervals.",
         "Con muestras pequeñas, Sauro y Lewis recomiendan el intervalo de Wald ajustado para las tasas de éxito y transformar los tiempos con logaritmos para los intervalos de confianza."))),
    list(title = tr("Is five users enough?", "¿Bastan cinco usuarios?"), body = c(
      tr("Nielsen and Landauer (1993) modelled problem discovery as 1 − (1 − p)^n. With p ≈ 0.31, five participants find about 85% of the problems. But p varies: rare problems (p = 0.1) need many more participants, and each distinct user group needs its own sample. Five users per round, with several iterative rounds, is a heuristic for formative testing, not a law.",
         "Nielsen y Landauer (1993) modelizaron el descubrimiento de problemas como 1 − (1 − p)^n. Con p ≈ 0,31, cinco participantes encuentran en torno al 85% de los problemas. Pero p varía: los problemas poco frecuentes (p = 0,1) requieren muchos más participantes, y cada grupo de usuarios necesita su propia muestra. Cinco usuarios por ronda, con varias rondas iterativas, es una regla práctica para tests formativos, no una ley.")))),
  mistakes = c(
    tr("Reporting ‘80% success’ from 5 participants without an interval.", "Presentar «80% de éxito» con 5 participantes sin intervalo."),
    tr("Using the arithmetic mean for task times, which outliers inflate.", "Usar la media aritmética para los tiempos, que los valores extremos inflan."),
    tr("Treating SUS as a percentage (‘the system is 70% usable’).", "Tratar el SUS como un porcentaje («el sistema es usable al 70%»)."),
    tr("Leading tasks that contain the label of the button to click.", "Tareas inductoras que contienen la etiqueta del botón que hay que pulsar.")),
  reading = c(
    "Sauro, J., &amp; Lewis, J. R. (2016). <em>Quantifying the User Experience</em> (2nd ed.). Morgan Kaufmann.",
    "Brooke, J. (1996). SUS: A ‘quick and dirty’ usability scale. In <em>Usability Evaluation in Industry</em> (pp. 189–194). Taylor &amp; Francis.",
    "Nielsen, J., &amp; Landauer, T. K. (1993). A mathematical model of the finding of usability problems. <em>INTERCHI '93</em>, 206–213.",
    "Tullis, T., &amp; Albert, B. (2013). <em>Measuring the User Experience</em> (2nd ed.). Morgan Kaufmann.",
    "Rubin, J., &amp; Chisnell, D. (2008). <em>Handbook of Usability Testing</em> (2nd ed.). Wiley."),
  quiz = list(
    list(q = tr("A product scores 72 on SUS. What does that mean?", "Un producto obtiene 72 en el SUS. ¿Qué significa?"),
         options = c(tr("72% of users find it usable", "Al 72% de los usuarios le parece usable"), tr("Slightly above the average of about 68", "Algo por encima de la media, en torno a 68"), tr("It failed the test", "Ha suspendido el test")),
         answer = 2, why = tr("SUS is not a percentage; it is interpreted against benchmarks, with 68 as the average.", "El SUS no es un porcentaje; se interpreta con valores de referencia, con 68 como media.")),
    list(q = tr("Why use the geometric mean for task times?", "¿Por qué usar la media geométrica para los tiempos de tarea?"),
         options = c(tr("Task times are skewed by a few slow participants", "Los tiempos están sesgados por unos pocos participantes lentos"), tr("It is always larger", "Siempre es mayor"), tr("It removes failures", "Elimina los fallos")),
         answer = 1, why = tr("Times are right-skewed; the geometric mean is closer to the typical time.", "Los tiempos tienen asimetría a la derecha; la media geométrica se acerca más al tiempo típico.")),
    list(q = tr("A problem affects 10% of users. How many participants to see it with about 85% probability?", "Un problema afecta al 10% de los usuarios. ¿Cuántos participantes para verlo con un 85% de probabilidad?"),
         options = c("5", tr("About 18", "Unos 18"), "50"),
         answer = 2, why = tr("1 − 0.9^18 ≈ 0.85: rare problems need many more than five users.", "1 − 0,9^18 ≈ 0,85: los problemas poco frecuentes necesitan muchos más de cinco usuarios.")))
)
