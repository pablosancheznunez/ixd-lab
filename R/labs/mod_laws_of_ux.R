# Laws of UX: run Fitts's and Hick's law experiments in the browser and fit the models to your own data.
fitts_example <- local({
  set.seed(7)
  w <- rep(c(20, 40, 80), 6); d <- round(runif(18, 80, 520))
  id <- log2(d / w + 1)
  list(d = d, w = w, t = round(180 + 140 * id + rnorm(18, 0, 45)), misses = 1)
})
hick_example <- local({
  set.seed(11)
  n <- rep(c(2, 4, 8, 16), 4)
  list(n = n, t = round(420 + 260 * log2(n + 1) + rnorm(16, 0, 90)), errors = 1)
})

experiment_area <- function(kind, input_id, start_label) {
  div(class = "exp-area", `data-fitts` = if (kind == "fitts") input_id, `data-hick` = if (kind == "hick") input_id,
      `data-done` = tr("Done! Your results are below.", "¡Hecho! Tus resultados están debajo."),
      `data-target` = tr("Target", "Objetivo"), `data-find` = tr("Click:", "Pulsa:"),
      div(class = "d-flex justify-content-between align-items-center mb-2",
        tags$button(type = "button", class = "btn btn-primary btn-sm", `data-exp-start` = NA, start_label),
        span(class = "exp-status footnote", `aria-live` = "polite")),
      div(class = "exp-stage", p(class = "exp-done", tr("Press start when you are ready. Use a mouse or trackpad and go as fast as you can without errors.",
                                                         "Pulsa empezar cuando estés listo. Usa un ratón o trackpad y ve lo más rápido que puedas sin cometer errores."))))
}

laws_of_ux_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Measure how target size and distance affect pointing time (Fitts's law).", "Medir cómo afectan el tamaño y la distancia del objetivo al tiempo de apuntado (ley de Fitts)."),
                   tr("Measure how the number of choices affects decision time (Hick's law).", "Medir cómo afecta el número de opciones al tiempo de decisión (ley de Hick)."),
                   tr("Translate the models into design decisions.", "Traducir los modelos en decisiones de diseño.")),
    concept = tr("Some UX ‘laws’ are robust experimental findings. Fitts's law predicts that big, close targets are faster to hit; Hick's law predicts that decision time grows with the number of equally likely options, but only logarithmically.",
                 "Algunas «leyes» de UX son hallazgos experimentales sólidos. La ley de Fitts predice que los objetivos grandes y cercanos se alcanzan antes; la de Hick, que el tiempo de decisión crece con el número de opciones igual de probables, pero solo de forma logarítmica."),
    activity = tagList(
      navset_underline(
        nav_panel(tr("Fitts's law", "Ley de Fitts"),
          div(class = "pt-3",
            p(tr("Click each green target as soon as it appears. There are 18 targets of three sizes at random distances.", "Pulsa cada objetivo verde en cuanto aparezca. Hay 18 objetivos de tres tamaños a distancias aleatorias.")),
            experiment_area("fitts", ns("fitts_data"), tr("Start Fitts experiment", "Empezar experimento de Fitts")),
            layout_columns(col_widths = c(7, 5), class = "mt-3",
              plotOutput(ns("fitts_plot"), height = "320px"),
              uiOutput(ns("fitts_model"))))),
        nav_panel(tr("Hick's law", "Ley de Hick"),
          div(class = "pt-3",
            p(tr("Find and click the city named at the top. The number of options changes between 2 and 16.", "Encuentra y pulsa la ciudad indicada arriba. El número de opciones cambia entre 2 y 16.")),
            experiment_area("hick", ns("hick_data"), tr("Start Hick experiment", "Empezar experimento de Hick")),
            layout_columns(col_widths = c(7, 5), class = "mt-3",
              plotOutput(ns("hick_plot"), height = "320px"),
              uiOutput(ns("hick_model")))))),
      p(class = "footnote mt-2", tr("Your timings stay in this browser session. ‘Load an example’ fills both experiments with simulated data.", "Tus tiempos se quedan en esta sesión del navegador. «Cargar un ejemplo» rellena ambos experimentos con datos simulados."))),
    reflection = tr("Where in a product you know would a bigger or closer target, or fewer choices, make a real difference? What would you trade off?",
                    "¿En qué punto de un producto que conozcas marcaría la diferencia un objetivo más grande o más cercano, o menos opciones? ¿Qué sacrificarías?"))
}

laws_of_ux_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    fitts <- reactiveVal(NULL)
    hick <- reactiveVal(NULL)
    observeEvent(input$fitts_data, fitts(lapply(input$fitts_data[c("d", "w", "t", "misses")], unlist)))
    observeEvent(input$hick_data, hick(lapply(input$hick_data[c("n", "t", "errors")], unlist)))

    fitts_fit <- reactive({
      f <- fitts(); req(f)
      df <- data.frame(id = log2(f$d / f$w + 1), t = f$t, w = f$w)
      df <- df[df$t < 5000, ]
      m <- lm(t ~ id, data = df)
      list(df = df, m = m, a = coef(m)[[1]], b = coef(m)[[2]], r2 = summary(m)$r.squared, tp = mean(df$id / (df$t / 1000)), misses = f$misses)
    })
    hick_fit <- reactive({
      h <- hick(); req(h)
      df <- data.frame(n = h$n, h = log2(h$n + 1), t = h$t)
      df <- df[df$t < 10000, ]
      m <- lm(t ~ h, data = df)
      list(df = df, m = m, a = coef(m)[[1]], b = coef(m)[[2]], r2 = summary(m)$r.squared, errors = h$errors)
    })

    empty_plot <- function(msg) { ixd_par(); plot.new(); text(.5, .5, msg, col = "#5f665f") }
    output$fitts_plot <- renderPlot({
      if (is.null(fitts())) return(empty_plot(tr("Run the experiment to see your data", "Haz el experimento para ver tus datos")))
      f <- fitts_fit(); cols <- c(`20` = ixd_red, `40` = ixd_sand, `80` = ixd_green)
      ixd_par()
      plot(f$df$id, f$df$t, pch = 19, col = cols[as.character(f$df$w)], xlab = tr("Index of difficulty, ID = log2(D/W + 1) bits", "Índice de dificultad, ID = log2(D/W + 1) bits"), ylab = tr("Movement time (ms)", "Tiempo de movimiento (ms)"))
      abline(f$m, col = "#202522", lwd = 2)
      legend("topleft", legend = paste(c(20, 40, 80), "px"), pch = 19, col = cols, bty = "n", title = tr("Target width", "Ancho del objetivo"), cex = .85)
    }, res = 96)
    output$fitts_model <- renderUI({
      if (is.null(fitts())) return(div(class = "panel-soft footnote", tr("The model MT = a + b · ID will be fitted to your clicks.", "El modelo MT = a + b · ID se ajustará a tus clics.")))
      f <- fitts_fit()
      div(class = "panel-soft",
        span(class = "eyebrow", tr("YOUR MODEL", "TU MODELO")),
        p(class = "model-eq", sprintf("MT = %.0f + %.0f · ID", f$a, f$b)),
        tags$ul(class = "footnote mb-0",
          tags$li(sprintf(tr("Each extra bit of difficulty costs you about %.0f ms.", "Cada bit extra de dificultad te cuesta unos %.0f ms."), f$b)),
          tags$li(sprintf(tr("R² = %.2f: the model explains %.0f%% of the variation in your times.", "R² = %.2f: el modelo explica el %.0f%% de la variación de tus tiempos."), f$r2, 100 * f$r2)),
          tags$li(sprintf(tr("Throughput ≈ %.1f bits/s · missed clicks: %d", "Rendimiento ≈ %.1f bits/s · clics fallidos: %d"), f$tp, as.integer(f$misses)))),
        p(class = "footnote mt-2 mb-0", tr("With only 18 trials the estimate is noisy; lab studies use hundreds per person.", "Con solo 18 intentos la estimación es ruidosa; los estudios de laboratorio usan cientos por persona.")))
    })
    output$hick_plot <- renderPlot({
      if (is.null(hick())) return(empty_plot(tr("Run the experiment to see your data", "Haz el experimento para ver tus datos")))
      h <- hick_fit()
      means <- tapply(h$df$t, h$df$n, mean)
      ixd_par()
      plot(h$df$h, h$df$t, pch = 19, col = adjustcolor(ixd_green, .45), xlab = tr("log2(n + 1), n = number of options", "log2(n + 1), n = número de opciones"), ylab = tr("Decision time (ms)", "Tiempo de decisión (ms)"), xaxt = "n")
      axis(1, at = log2(c(2, 4, 8, 16) + 1), labels = paste0("n=", c(2, 4, 8, 16)))
      points(log2(as.numeric(names(means)) + 1), means, pch = 18, cex = 2.2, col = "#202522")
      abline(h$m, col = "#202522", lwd = 2)
    }, res = 96)
    output$hick_model <- renderUI({
      if (is.null(hick())) return(div(class = "panel-soft footnote", tr("The model RT = a + b · log2(n + 1) will be fitted to your choices.", "El modelo RT = a + b · log2(n + 1) se ajustará a tus elecciones.")))
      h <- hick_fit()
      div(class = "panel-soft",
        span(class = "eyebrow", tr("YOUR MODEL", "TU MODELO")),
        p(class = "model-eq", sprintf("RT = %.0f + %.0f · log2(n + 1)", h$a, h$b)),
        tags$ul(class = "footnote mb-0",
          tags$li(sprintf(tr("Doubling the options adds about %.0f ms, not double the time.", "Duplicar las opciones añade unos %.0f ms, no el doble de tiempo."), h$b)),
          tags$li(sprintf(tr("R² = %.2f · wrong clicks: %d", "R² = %.2f · clics erróneos: %d"), h$r2, as.integer(h$errors)))),
        p(class = "footnote mt-2 mb-0", tr("Here you searched for a word, so part of the time is visual search, which grows more steeply than Hick's law predicts.",
                                            "Aquí buscabas una palabra, así que parte del tiempo es búsqueda visual, que crece más deprisa de lo que predice la ley de Hick.")))
    })

    lines <- function() {
      c(if (!is.null(fitts())) { f <- fitts_fit(); sprintf(tr("Fitts: MT = %.0f + %.0f·ID ms, R² = %.2f, throughput %.1f bits/s, %d trials", "Fitts: MT = %.0f + %.0f·ID ms, R² = %.2f, rendimiento %.1f bits/s, %d intentos"), f$a, f$b, f$r2, f$tp, nrow(f$df)) }
        else tr("Fitts: not run", "Fitts: no realizado"),
        if (!is.null(hick())) { h <- hick_fit(); sprintf(tr("Hick: RT = %.0f + %.0f·log2(n+1) ms, R² = %.2f, %d trials", "Hick: RT = %.0f + %.0f·log2(n+1) ms, R² = %.2f, %d intentos"), h$a, h$b, h$r2, nrow(h$df)) }
        else tr("Hick: not run", "Hick: no realizado"))
    }
    observeEvent(input$example, {
      fitts(fitts_example); hick(hick_example)
      example_reflection(session, tr("The ‘Pay’ button on my bank's mobile app is small and at the top of the screen, far from the thumb. Moving it to a large bottom bar would cut pointing time; the trade-off is less space for content.",
                                     "El botón «Pagar» de la app de mi banco es pequeño y está arriba, lejos del pulgar. Llevarlo a una barra grande abajo reduciría el tiempo de apuntado; a cambio, queda menos espacio para el contenido."))
    })

    reflect_server(tr("Laws of UX", "Leyes de la UX"), input, output, session, lines)
  })
}

lab_content$laws <- list(
  theory = list(
    list(title = tr("Fitts's law", "Ley de Fitts"), body = c(
      tr("Paul Fitts (1954) showed that the time to point at a target grows with the <strong>index of difficulty</strong>, ID = log2(D/W + 1), where D is the distance and W the width of the target (Shannon formulation, MacKenzie 1992). The model is MT = a + b·ID.",
         "Paul Fitts (1954) mostró que el tiempo para apuntar a un objetivo crece con el <strong>índice de dificultad</strong>, ID = log2(D/W + 1), donde D es la distancia y W el ancho del objetivo (formulación de Shannon, MacKenzie 1992). El modelo es MT = a + b·ID."),
      tr("Design consequences: make frequent targets large, place related controls close to where the pointer or thumb already is, and use screen edges and corners, which behave as infinitely large targets for a mouse. WCAG 2.2 (2.5.8) asks for targets of at least 24 × 24 CSS pixels.",
         "Consecuencias de diseño: haz grandes los objetivos frecuentes, coloca los controles relacionados cerca de donde ya está el puntero o el pulgar, y aprovecha los bordes y esquinas de la pantalla, que para un ratón funcionan como objetivos infinitos. WCAG 2.2 (2.5.8) pide objetivos de al menos 24 × 24 píxeles CSS."))),
    list(title = tr("Hick–Hyman law", "Ley de Hick-Hyman"), body = c(
      tr("Hick (1952) and Hyman (1953) found that choice reaction time grows with the information in the choice: RT = a + b·log2(n + 1) for n equally likely options. Because the growth is logarithmic, splitting a list into many tiny menus can be slower than one well-organised list.",
         "Hick (1952) y Hyman (1953) observaron que el tiempo de reacción de elección crece con la información de la elección: RT = a + b·log2(n + 1) para n opciones igual de probables. Como el crecimiento es logarítmico, dividir una lista en muchos menús pequeños puede ser más lento que una lista bien organizada."),
      tr("The law applies to simple, familiar choices. When people must read and search unfamiliar items, time grows roughly linearly with the number of items. Group, order and highlight to reduce search.",
         "La ley se aplica a elecciones simples y conocidas. Cuando hay que leer y buscar elementos desconocidos, el tiempo crece de forma casi lineal con el número de elementos. Agrupa, ordena y destaca para reducir la búsqueda."))),
    list(title = tr("Other laws, and their limits", "Otras leyes y sus límites"), body = c(
      tr("<strong>Jakob's law</strong>: users spend most of their time on other sites, so they expect yours to work the same way. <strong>Doherty threshold</strong>: productivity rises when systems respond in under about 400 ms. <strong>Miller's 7±2</strong> concerns short-term memory span, not how many menu items are allowed: menus are recognised, not recalled.",
         "<strong>Ley de Jakob</strong>: los usuarios pasan la mayor parte del tiempo en otros sitios, así que esperan que el tuyo funcione igual. <strong>Umbral de Doherty</strong>: la productividad aumenta cuando el sistema responde en menos de unos 400 ms. <strong>El 7±2 de Miller</strong> trata de la memoria a corto plazo, no de cuántos elementos puede tener un menú: los menús se reconocen, no se recuerdan."),
      tr("These ‘laws’ are models with conditions. Cite the original study, check that the conditions apply, and prefer testing over quoting.",
         "Estas «leyes» son modelos con condiciones. Cita el estudio original, comprueba que se cumplen las condiciones y prefiere probar a citar.")))),
  mistakes = c(
    tr("Citing Miller's 7±2 to limit navigation menus to seven items.", "Citar el 7±2 de Miller para limitar los menús de navegación a siete elementos."),
    tr("Tiny tap targets on mobile because they ‘look cleaner’.", "Objetivos táctiles diminutos en móvil porque «se ven más limpios»."),
    tr("Placing destructive actions next to frequent ones, where they are easy to hit by accident.", "Colocar acciones destructivas junto a las frecuentes, donde es fácil pulsarlas por error."),
    tr("Using Hick's law to justify hiding options that people need.", "Usar la ley de Hick para justificar ocultar opciones que la gente necesita.")),
  reading = c(
    "Fitts, P. M. (1954). The information capacity of the human motor system. <em>Journal of Experimental Psychology, 47</em>(6), 381–391.",
    "MacKenzie, I. S. (1992). Fitts' law as a research and design tool in HCI. <em>Human–Computer Interaction, 7</em>(1), 91–139.",
    "Hick, W. E. (1952). On the rate of gain of information. <em>Quarterly Journal of Experimental Psychology, 4</em>(1), 11–26.",
    "Yablonski, J. (2020). <em>Laws of UX</em>. O'Reilly.",
    "Miller, G. A. (1956). The magical number seven, plus or minus two. <em>Psychological Review, 63</em>(2), 81–97."),
  quiz = list(
    list(q = tr("According to Fitts's law, which target is fastest to hit?", "Según la ley de Fitts, ¿qué objetivo se alcanza antes?"),
         options = c(tr("Small and far", "Pequeño y lejano"), tr("Large and close", "Grande y cercano"), tr("Small and close", "Pequeño y cercano")),
         answer = 2, why = tr("A low D/W ratio gives a low index of difficulty and a short movement time.", "Una relación D/W baja da un índice de dificultad bajo y un tiempo de movimiento corto.")),
    list(q = tr("Going from 4 to 8 equally likely options, Hick's law predicts that decision time…", "Al pasar de 4 a 8 opciones igual de probables, la ley de Hick predice que el tiempo de decisión…"),
         options = c(tr("Doubles", "Se duplica"), tr("Grows by a roughly constant amount", "Aumenta en una cantidad aproximadamente constante"), tr("Stays the same", "No cambia")),
         answer = 2, why = tr("Time grows with log2(n + 1), so each doubling adds about the same amount.", "El tiempo crece con log2(n + 1), así que cada duplicación añade más o menos lo mismo.")),
    list(q = tr("What does Miller's ‘7±2’ actually describe?", "¿Qué describe realmente el «7±2» de Miller?"),
         options = c(tr("The maximum number of menu items", "El número máximo de elementos de un menú"), tr("Short-term memory span for items like digits", "La capacidad de la memoria a corto plazo para elementos como dígitos"), tr("The number of clicks people tolerate", "El número de clics que tolera la gente")),
         answer = 2, why = tr("It is about recalling items, not recognising visible menu options.", "Trata de recordar elementos, no de reconocer opciones visibles de un menú.")))
)
