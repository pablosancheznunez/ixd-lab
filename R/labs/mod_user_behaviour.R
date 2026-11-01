behaviour_traces <- list(
  search = list(title = tr("Course search", "Búsqueda de cursos"), steps = data.frame(
    page = c(tr("Home", "Inicio"), tr("Search", "Buscar"), tr("Results", "Resultados"), tr("Search", "Buscar"), tr("Results", "Resultados"), tr("Course detail", "Ficha del curso")),
    seconds = c(3, 8, 14, 6, 22, 25),
    kind = c("view", "view", "view", "back", "view", "view"))),
  registration = list(title = tr("Event registration", "Inscripción a un evento"), steps = data.frame(
    page = c(tr("Event page", "Página del evento"), tr("Registration form", "Formulario"), tr("Help: payment", "Ayuda: pago"), tr("Registration form", "Formulario"), tr("Confirmation", "Confirmación")),
    seconds = c(4, 11, 17, 31, 3),
    kind = c("view", "view", "help", "view", "view"))),
  library = list(title = tr("Library checkout", "Préstamo en la biblioteca"), steps = data.frame(
    page = c(tr("Catalogue", "Catálogo"), tr("Book detail", "Ficha del libro"), tr("Sign in", "Iniciar sesión"), tr("Book detail", "Ficha del libro"), tr("Sign in", "Iniciar sesión"), tr("Reserve", "Reservar"), tr("Reserve", "Reservar")),
    seconds = c(9, 12, 20, 5, 28, 15, 4),
    kind = c("view", "view", "view", "back", "view", "view", "view")))
)

methods_choices <- c(tr("Think-aloud usability test", "Test de usabilidad con pensamiento en voz alta"), tr("Short follow-up interview", "Entrevista breve posterior"),
                     tr("Consented, anonymised analytics", "Analítica anonimizada y con consentimiento"), tr("Survey with open questions", "Encuesta con preguntas abiertas"),
                     tr("A/B test of a redesigned step", "Test A/B de un paso rediseñado"))

user_behaviour_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Read an interaction sequence.", "Leer una secuencia de interacción."),
                   tr("Separate observations from explanations.", "Separar observaciones de explicaciones."),
                   tr("Plan how to collect evidence ethically.", "Planificar cómo recoger evidencia de forma ética.")),
    concept = tr("A log shows what happened, never why. A long pause could be confusion, careful reading, or a phone call. Explanations become evidence only when you test them with people.",
                 "Un registro muestra qué pasó, nunca por qué. Una pausa larga puede ser confusión, lectura atenta o una llamada de teléfono. Las explicaciones solo se convierten en evidencia cuando las pruebas con personas."),
    activity = tagList(
      div(class = "alert alert-warning", tags$strong(tr("SIMULATED DATA · ", "DATOS SIMULADOS · ")),
          tr("Illustrative traces written for this exercise; no participants were observed.", "Recorridos ilustrativos escritos para este ejercicio; no se ha observado a ningún participante.")),
      layout_columns(col_widths = c(4, 8),
        div(
          radioButtons(ns("scenario"), tr("Scenario", "Escenario"), setNames(names(behaviour_traces), vapply(behaviour_traces, `[[`, "", "title"))),
          div(class = "panel-soft", span(class = "eyebrow", tr("SUMMARY", "RESUMEN")), uiOutput(ns("summary")))),
        div(
          uiOutput(ns("trace")),
          div(class = "legend mt-2", span(tags$i(style = "background:#276b5b;opacity:.75"), tr("Page view", "Visita a página")),
              span(tags$i(style = "background:#a35b4f"), tr("Went back", "Volvió atrás")), span(tags$i(style = "background:#d4a15e"), tr("Opened help", "Abrió la ayuda"))))),
      hr(),
      layout_columns(col_widths = c(6, 6),
        textAreaInput(ns("observation"), tr("What I observe (only what the trace shows)", "Lo que observo (solo lo que muestra el recorrido)"), rows = 3, width = "100%",
                      placeholder = tr("e.g. The person returned to Search after 14 seconds on Results.", "p. ej. La persona volvió a Buscar tras 14 segundos en Resultados.")),
        textAreaInput(ns("explanation"), tr("Possible explanations (at least two)", "Posibles explicaciones (al menos dos)"), rows = 3, width = "100%",
                      placeholder = tr("e.g. The results did not match the query; or the person refined it on purpose.", "p. ej. Los resultados no encajaban con la búsqueda; o la persona la afinó a propósito."))),
      checkboxGroupInput(ns("methods"), tr("How would you test your explanations?", "¿Cómo pondrías a prueba tus explicaciones?"), methods_choices),
      uiOutput(ns("method_feedback"))),
    reflection = tr("What alternative explanation could account for the longest pause? What would you need consent for?",
                    "¿Qué explicación alternativa podría justificar la pausa más larga? ¿Para qué necesitarías consentimiento?"))
}

user_behaviour_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    trace <- reactive(behaviour_traces[[input$scenario]]$steps)

    output$trace <- renderUI({
      x <- trace()
      longest <- max(x$seconds)
      tagList(lapply(seq_len(nrow(x)), function(i) div(class = "trace-row",
        span(paste0(i, ". ", x$page[i])),
        div(class = paste("trace-bar", x$kind[i]), style = sprintf("width:%.0f%%", 100 * x$seconds[i] / longest),
            role = "img", `aria-label` = sprintf(tr("%s, %d seconds", "%s, %d segundos"), x$page[i], x$seconds[i])),
        span(class = "footnote", paste(x$seconds[i], "s")))))
    })

    output$summary <- renderUI({
      x <- trace()
      tags$ul(class = "check-list footnote",
        tags$li(sprintf(tr("%d steps · %d s in total", "%d pasos · %d s en total"), nrow(x), sum(x$seconds))),
        tags$li(sprintf(tr("Longest step: %s (%d s)", "Paso más largo: %s (%d s)"), x$page[which.max(x$seconds)], max(x$seconds))),
        tags$li(sprintf(tr("Went back: %d · Opened help: %d", "Volvió atrás: %d · Abrió la ayuda: %d"), sum(x$kind == "back"), sum(x$kind == "help"))),
        tags$li(tr("Durations are illustrative, not measured.", "Las duraciones son ilustrativas, no medidas.")))
    })

    output$method_feedback <- renderUI({
      m <- input$methods
      req(length(m))
      notes <- c(
        if (methods_choices[1] %in% m) tr("Think-aloud shows why people pause, but needs informed consent and recording rules.", "Pensar en voz alta muestra por qué se detiene la gente, pero requiere consentimiento informado y normas de grabación."),
        if (methods_choices[3] %in% m) tr("Analytics tell you how often a pattern happens, not why; collect only the fields your question needs.", "La analítica dice con qué frecuencia ocurre algo, no por qué; recoge solo los campos que necesita tu pregunta."),
        if (methods_choices[5] %in% m) tr("An A/B test compares outcomes, but needs enough participants and a clear success measure.", "Un test A/B compara resultados, pero necesita suficientes participantes y una medida de éxito clara."),
        if (length(m) == 1) tr("Combining a behavioural method with one that asks people directly makes your explanation stronger.", "Combinar un método conductual con otro que pregunte directamente a las personas refuerza tu explicación."))
      req(length(notes))
      div(class = "alert alert-info mt-2", tags$ul(class = "mb-0", lapply(notes, tags$li)))
    })

    reflect_server(tr("User behaviour", "Comportamiento del usuario"), input, output, session, function() c(
      paste(tr("Scenario (simulated):", "Escenario (simulado):"), behaviour_traces[[input$scenario]]$title),
      paste(tr("Observation:", "Observación:"), trimws(input$observation %||% "")),
      paste(tr("Explanations:", "Explicaciones:"), trimws(input$explanation %||% "")),
      paste(tr("Methods:", "Métodos:"), if (length(input$methods)) paste(input$methods, collapse = "; ") else tr("(none)", "(ninguno)"))))
  })
}
