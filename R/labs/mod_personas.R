# Personas: tag research snippets (affinity mapping) and build an evidence-based persona.
persona_tags <- c(goal = tr("Goal", "Objetivo"), frustration = tr("Frustration", "Frustración"), behaviour = tr("Behaviour", "Comportamiento"), context = tr("Context", "Contexto"))

persona_snippets <- data.frame(
  who = c("P1", "P1", "P1", "P2", "P2", "P2", "P3", "P3", "P3", "P4", "P4", "P4"),
  text = c(
    tr("I study on the train, so everything has to work on my phone.", "Estudio en el tren, así que todo tiene que funcionar en el móvil."),
    tr("What I want is to know on Monday what I must hand in by Friday.", "Lo que quiero es saber el lunes qué tengo que entregar el viernes."),
    tr("The platform logs me out every time I switch apps, and I lose what I wrote.", "La plataforma me cierra la sesión cada vez que cambio de app y pierdo lo que escribí."),
    tr("I keep a paper planner because the calendar never shows all my subjects together.", "Llevo una agenda en papel porque el calendario nunca muestra todas mis asignaturas juntas."),
    tr("I just want to stop missing deadlines.", "Solo quiero dejar de saltarme fechas de entrega."),
    tr("Notifications arrive by email, mixed with spam.", "Los avisos llegan por correo, mezclados con spam."),
    tr("I check the forum late at night, after my kids are asleep.", "Miro el foro por la noche, cuando mis hijos ya duermen."),
    tr("Finding the reading for each week takes me ten clicks.", "Encontrar la lectura de cada semana me lleva diez clics."),
    tr("I want to feel I'm keeping up with the group.", "Quiero sentir que voy al ritmo del grupo."),
    tr("On Sundays I download all the PDFs to read offline during the week.", "Los domingos descargo todos los PDF para leerlos sin conexión durante la semana."),
    tr("Tutors answer in different places: forum, email, chat.", "Los docentes responden en sitios distintos: foro, correo, chat."),
    tr("My internet connection at home is unreliable.", "Mi conexión a internet en casa no es fiable.")),
  ref = c("context", "goal", "frustration", "behaviour", "goal", "frustration", "context", "frustration", "goal", "behaviour", "frustration", "context")
)
persona_snippets$label <- paste0(persona_snippets$who, " · ", persona_snippets$text)

personas_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Cluster raw research notes into themes (affinity mapping).", "Agrupar notas de investigación en temas (mapa de afinidad)."),
                   tr("Build a persona whose every claim is traceable to evidence.", "Construir una persona cuyas afirmaciones se apoyen en evidencia."),
                   tr("Avoid stereotypes and decorative demographics.", "Evitar estereotipos y datos demográficos decorativos.")),
    concept = tr("A persona is a summary of research, not a character invented in a workshop. Its value comes from goals, behaviours and frustrations that real participants share, not from a stock photo and an age.",
                 "Una persona es un resumen de investigación, no un personaje inventado en un taller. Su valor está en los objetivos, comportamientos y frustraciones que comparten participantes reales, no en una foto de archivo y una edad."),
    activity = tagList(
      simulated_note(),
      h4(tr("Step 1 · Tag each note from four interviews with part-time master's students", "Paso 1 · Etiqueta cada nota de cuatro entrevistas con estudiantes de máster a tiempo parcial")),
      div(class = "snippet-grid", lapply(seq_len(nrow(persona_snippets)), function(i) div(class = "snippet",
        span(class = "chip", persona_snippets$who[i]), p(class = "my-2", persona_snippets$text[i]),
        selectInput(ns(paste0("tag_", i)), NULL, c(setNames("", tr("Tag…", "Etiqueta…")), setNames(names(persona_tags), persona_tags)), width = "100%")))),
      div(class = "d-flex flex-wrap gap-2 align-items-center",
        actionButton(ns("check_tags"), tr("Compare my tags", "Comparar mis etiquetas"), class = "btn-outline-success"), uiOutput(ns("tag_result"), inline = TRUE)),
      hr(),
      h4(tr("Step 2 · Build the persona from the evidence", "Paso 2 · Construye la persona con la evidencia")),
      layout_columns(col_widths = c(6, 6),
        div(
          textInput(ns("name"), tr("Persona name", "Nombre de la persona"), placeholder = tr("e.g. Marta, the commuting student", "p. ej. Marta, la estudiante que se desplaza")),
          textInput(ns("summary"), tr("One-line description (what defines her or him?)", "Descripción en una línea (¿qué la o lo define?)"), width = "100%"),
          selectizeInput(ns("goals"), tr("Goals · evidence", "Objetivos · evidencia"), persona_snippets$label, multiple = TRUE, width = "100%"),
          selectizeInput(ns("frustrations"), tr("Frustrations · evidence", "Frustraciones · evidencia"), persona_snippets$label, multiple = TRUE, width = "100%"),
          selectizeInput(ns("behaviours"), tr("Behaviours and context · evidence", "Comportamientos y contexto · evidencia"), persona_snippets$label, multiple = TRUE, width = "100%"),
          selectInput(ns("quote"), tr("A quote that captures the persona", "Una cita que resuma a la persona"), c(setNames("", tr("Choose a quote", "Elige una cita")), persona_snippets$text), width = "100%"),
          textAreaInput(ns("scenario"), tr("Scenario: a situation where the persona uses the product", "Escenario: una situación en la que la persona usa el producto"), rows = 3, width = "100%")),
        div(uiOutput(ns("card")), div(class = "panel-soft mt-3", span(class = "eyebrow", tr("EVIDENCE CHECKS", "COMPROBACIONES DE EVIDENCIA")), uiOutput(ns("checks")))))),
    reflection = tr("Which part of your persona is best supported by the evidence, and which part is still an assumption you would need to check?",
                    "¿Qué parte de tu persona está mejor respaldada por la evidencia y cuál sigue siendo una suposición que tendrías que comprobar?"))
}

personas_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    tags_now <- reactive(vapply(seq_len(nrow(persona_snippets)), function(i) input[[paste0("tag_", i)]] %||% "", ""))
    tag_score <- reactiveVal(NULL)
    observeEvent(input$check_tags, {
      t <- tags_now()
      tag_score(list(done = sum(nzchar(t)), right = sum(t == persona_snippets$ref)))
    })
    output$tag_result <- renderUI({
      s <- tag_score(); if (is.null(s)) return(NULL)
      if (s$done < nrow(persona_snippets)) return(span(class = "footnote", sprintf(tr("Tag all %d notes first (%d done).", "Etiqueta primero las %d notas (%d hechas)."), nrow(persona_snippets), s$done)))
      span(class = "footnote", sprintf(tr("%d of %d match the reference tagging. Disagreements are normal: can you defend yours?", "%d de %d coinciden con el etiquetado de referencia. Discrepar es normal: ¿puedes defender las tuyas?"), s$right, nrow(persona_snippets)))
    })

    evidence <- reactive(unique(c(input$goals, input$frustrations, input$behaviours)))
    checks <- reactive({
      ev <- evidence()
      who <- unique(sub(" · .*", "", ev))
      summary <- input$summary %||% ""
      list(
        list(ok = length(input$goals) >= 1, text = tr("At least one goal backed by a note", "Al menos un objetivo respaldado por una nota")),
        list(ok = length(input$frustrations) >= 1, text = tr("At least one frustration backed by a note", "Al menos una frustración respaldada por una nota")),
        list(ok = length(input$behaviours) >= 1, text = tr("Behaviours or context backed by a note", "Comportamientos o contexto respaldados por una nota")),
        list(ok = length(who) >= 3, text = sprintf(tr("Evidence from at least 3 participants (now %d): a persona summarises a pattern, not one person", "Evidencia de al menos 3 participantes (ahora %d): una persona resume un patrón, no a un individuo"), length(who))),
        list(ok = !grepl("\\b[1-9][0-9]\\b", summary), text = tr("The description is about goals and context, not age", "La descripción habla de objetivos y contexto, no de edad")),
        list(ok = nchar(trimws(input$scenario %||% "")) >= 30, text = tr("A scenario shows the persona in a situation of use", "Un escenario muestra a la persona en una situación de uso")))
    })
    output$checks <- renderUI(check_list(checks()))

    clean <- function(x) sub("^P[0-9] · ", "", x)
    output$card <- renderUI({
      section <- function(title, items) if (length(items)) div(class = "mb-2", span(class = "eyebrow", title), tags$ul(class = "mb-0", lapply(clean(items), tags$li)))
      div(class = "persona-card",
        div(class = "persona-avatar", `aria-hidden` = "true", { n <- trimws(input$name %||% ""); if (nzchar(n)) toupper(substr(n, 1, 1)) else "?" }),
        h3(class = "mt-0", if (nzchar(trimws(input$name %||% ""))) input$name else tr("Your persona", "Tu persona")),
        p(class = "muted", input$summary),
        if (nzchar(input$quote %||% "")) tags$blockquote(class = "persona-quote", paste0("“", input$quote, "”")),
        section(tr("GOALS", "OBJETIVOS"), input$goals), section(tr("FRUSTRATIONS", "FRUSTRACIONES"), input$frustrations),
        section(tr("BEHAVIOURS AND CONTEXT", "COMPORTAMIENTOS Y CONTEXTO"), input$behaviours),
        if (nzchar(trimws(input$scenario %||% ""))) div(span(class = "eyebrow", tr("SCENARIO", "ESCENARIO")), p(class = "mb-0", input$scenario)))
    })

    lines <- function() {
      t <- tags_now()
      c(sprintf(tr("Notes tagged: %d of %d (%d match the reference)", "Notas etiquetadas: %d de %d (%d coinciden con la referencia)"), sum(nzchar(t)), length(t), sum(t == persona_snippets$ref)),
        paste0(tr("Persona: ", "Persona: "), input$name %||% "", " · ", input$summary %||% ""),
        paste0(tr("Goals: ", "Objetivos: "), paste(input$goals, collapse = " | ")),
        paste0(tr("Frustrations: ", "Frustraciones: "), paste(input$frustrations, collapse = " | ")),
        paste0(tr("Behaviours: ", "Comportamientos: "), paste(input$behaviours, collapse = " | ")),
        paste0(tr("Quote: ", "Cita: "), input$quote %||% ""), paste0(tr("Scenario: ", "Escenario: "), input$scenario %||% ""), "",
        tr("Evidence checks:", "Comprobaciones:"), vapply(checks(), function(ch) paste(if (ch$ok) "[ok]" else tr("[review]", "[revisar]"), ch$text), ""))
    }
    observeEvent(input$example, {
      for (i in seq_len(nrow(persona_snippets))) updateSelectInput(session, paste0("tag_", i), selected = persona_snippets$ref[i])
      updateTextInput(session, "name", value = tr("Marta, the student who studies on the move", "Marta, la estudiante que estudia en movimiento"))
      updateTextInput(session, "summary", value = tr("Works full time and fits her master's into commutes and late evenings.", "Trabaja a tiempo completo y encaja el máster en los trayectos y las noches."))
      updateSelectizeInput(session, "goals", selected = persona_snippets$label[c(2, 5, 9)])
      updateSelectizeInput(session, "frustrations", selected = persona_snippets$label[c(3, 6, 8, 11)])
      updateSelectizeInput(session, "behaviours", selected = persona_snippets$label[c(1, 4, 7, 10, 12)])
      updateSelectInput(session, "quote", selected = persona_snippets$text[2])
      updateTextAreaInput(session, "scenario", value = tr("On the Monday morning train, Marta opens the platform on her phone to see everything due this week across all subjects, and saves the readings for offline use.",
                                                          "En el tren del lunes por la mañana, Marta abre la plataforma en el móvil para ver todo lo que vence esta semana en todas las asignaturas y guarda las lecturas para leerlas sin conexión."))
      example_reflection(session, tr("Studying on the move and losing work when switching apps are supported by several participants. That she prefers one weekly overview is from two people only: I would check it with a survey.",
                                     "Estudiar en movimiento y perder el trabajo al cambiar de app lo respaldan varios participantes. Que prefiera un resumen semanal sale solo de dos personas: lo comprobaría con una encuesta."))
    })

    reflect_server(tr("Personas", "Personas"), input, output, session, lines)
  })
}

lab_content$persona <- list(
  theory = list(
    list(title = tr("From notes to themes: affinity mapping", "De notas a temas: el mapa de afinidad"), body = c(
      tr("After interviews, write one observation per note, then cluster notes bottom-up by similarity and name each cluster. This <strong>affinity diagram</strong> (or KJ method) turns raw data into themes without forcing them into categories decided in advance. Thematic analysis (Braun &amp; Clarke, 2006) is the more formal version.",
         "Después de las entrevistas, escribe una observación por nota, agrúpalas de abajo arriba por similitud y nombra cada grupo. Este <strong>diagrama de afinidad</strong> (o método KJ) convierte los datos en temas sin forzarlos en categorías decididas de antemano. El análisis temático (Braun y Clarke, 2006) es su versión más formal."))),
    list(title = tr("What makes a good persona", "Qué hace buena a una persona"), body = c(
      tr("Alan Cooper introduced personas as <strong>archetypes built from research</strong>, focused on goals. A useful persona has goals, behaviours, frustrations and context, a short scenario, and a link to the evidence. Demographics belong only when they change behaviour.",
         "Alan Cooper introdujo las personas como <strong>arquetipos construidos a partir de la investigación</strong>, centrados en objetivos. Una persona útil tiene objetivos, comportamientos, frustraciones y contexto, un escenario breve y un vínculo con la evidencia. Los datos demográficos solo deben aparecer cuando cambian el comportamiento."),
      tr("<strong>Proto-personas</strong> are assumption-based sketches made before research. They are fine as hypotheses, as long as everyone knows they must be validated.",
         "Las <strong>proto-personas</strong> son bocetos basados en suposiciones hechos antes de investigar. Valen como hipótesis, siempre que todo el equipo sepa que hay que validarlas."))),
    list(title = tr("Jobs to be done and empathy maps", "Jobs to be done y mapas de empatía"), body = c(
      tr("<strong>Jobs to be done</strong> frames needs as ‘When [situation], I want to [motivation], so I can [outcome]’, which avoids stereotypes altogether. <strong>Empathy maps</strong> (says, thinks, does, feels) are a quick way to align a team on what a user group experiences.",
         "<strong>Jobs to be done</strong> formula las necesidades como «Cuando [situación], quiero [motivación] para [resultado]», lo que evita los estereotipos. Los <strong>mapas de empatía</strong> (dice, piensa, hace, siente) son una forma rápida de alinear al equipo sobre lo que vive un grupo de usuarios.")))),
  mistakes = c(
    tr("Inventing personas in a workshop without research and treating them as facts.", "Inventar personas en un taller sin investigación y tratarlas como hechos."),
    tr("Stock photos and hobbies that add colour but no design guidance.", "Fotos de archivo y aficiones que añaden color pero no orientan el diseño."),
    tr("Too many personas: three to five primary ones are usually enough.", "Demasiadas personas: de tres a cinco principales suelen bastar."),
    tr("Building personas on age, gender or nationality stereotypes.", "Construir personas sobre estereotipos de edad, género o nacionalidad.")),
  reading = c(
    "Cooper, A. (1999). <em>The Inmates Are Running the Asylum</em>. Sams.",
    "Pruitt, J., &amp; Adlin, T. (2006). <em>The Persona Lifecycle</em>. Morgan Kaufmann.",
    "Braun, V., &amp; Clarke, V. (2006). Using thematic analysis in psychology. <em>Qualitative Research in Psychology, 3</em>(2), 77–101.",
    "Christensen, C. M., et al. (2016). Know your customers' jobs to be done. <em>Harvard Business Review</em>."),
  quiz = list(
    list(q = tr("What should a persona be based on?", "¿En qué debe basarse una persona?"),
         options = c(tr("The team's intuition", "La intuición del equipo"), tr("Patterns found in research with real users", "Patrones encontrados en investigación con usuarios reales"), tr("Market segments by age", "Segmentos de mercado por edad")),
         answer = 2, why = tr("A persona summarises observed patterns; otherwise it is an untested assumption.", "Una persona resume patrones observados; si no, es una suposición sin comprobar.")),
    list(q = tr("In affinity mapping, categories should…", "En un mapa de afinidad, las categorías deben…"),
         options = c(tr("Be decided before reading the notes", "Decidirse antes de leer las notas"), tr("Emerge from grouping the notes", "Surgir al agrupar las notas"), tr("Follow the product's menu", "Seguir el menú del producto")),
         answer = 2, why = tr("Bottom-up clustering lets unexpected themes appear.", "La agrupación de abajo arriba deja aparecer temas inesperados.")),
    list(q = tr("When is age relevant in a persona?", "¿Cuándo es relevante la edad en una persona?"),
         options = c(tr("Always", "Siempre"), tr("When it changes behaviour or needs", "Cuando cambia el comportamiento o las necesidades"), tr("Never", "Nunca")),
         answer = 2, why = tr("Include demographics only when research shows they explain behaviour.", "Incluye datos demográficos solo cuando la investigación muestra que explican el comportamiento.")))
)
