# Interviews and surveys: diagnose and rewrite biased questions, with live checks on any question.
question_issues <- c(
  leading = tr("Leading", "Inductora"), double = tr("Double-barrelled", "Doble pregunta"), hypothetical = tr("Hypothetical or about the future", "Hipotética o sobre el futuro"),
  closed = tr("Closed (yes/no)", "Cerrada (sí/no)"), jargon = tr("Jargon", "Jerga"), good = tr("Good open question", "Buena pregunta abierta")
)

question_bank <- list(
  list(text = tr("Don't you think the new app is much easier to use?", "¿No crees que la nueva app es mucho más fácil de usar?"), issue = "leading",
       why = tr("It suggests the expected answer (‘much easier’) and invites agreement.", "Sugiere la respuesta esperada («mucho más fácil») e invita a estar de acuerdo.")),
  list(text = tr("How often do you use the library website and the mobile app?", "¿Con qué frecuencia usas la web de la biblioteca y la app móvil?"), issue = "double",
       why = tr("Two products in one question: the answer cannot be attributed to either.", "Dos productos en una pregunta: la respuesta no se puede atribuir a ninguno.")),
  list(text = tr("Would you pay €5 a month for a study planner?", "¿Pagarías 5 € al mes por un planificador de estudio?"), issue = "hypothetical",
       why = tr("People are poor at predicting what they would do or pay. Ask about what they do now.", "La gente predice mal lo que haría o pagaría. Pregunta por lo que hace ahora.")),
  list(text = tr("Do you like the navigation?", "¿Te gusta la navegación?"), issue = "closed",
       why = tr("A yes/no answer gives no insight, and ‘navigation’ is designer jargon.", "Un sí o un no no aporta nada, y «navegación» es jerga de diseño.")),
  list(text = tr("Tell me about the last time you prepared for an exam.", "Cuéntame la última vez que preparaste un examen."), issue = "good",
       why = tr("Open, neutral and anchored in a real past event.", "Abierta, neutral y anclada en un hecho real del pasado.")),
  list(text = tr("How satisfied are you with the onboarding funnel?", "¿Qué satisfacción te produce el embudo de onboarding?"), issue = "jargon",
       why = tr("‘Onboarding funnel’ is internal vocabulary that participants may not understand.", "«Embudo de onboarding» es vocabulario interno que los participantes quizá no entiendan.")),
  list(text = tr("Walk me through how you booked your last group study room.", "Explícame paso a paso cómo reservaste tu última sala de estudio en grupo."), issue = "good",
       why = tr("Asks for a concrete, recent story step by step.", "Pide una historia concreta y reciente, paso a paso.")),
  list(text = tr("Is the timetable clear and up to date?", "¿El horario es claro y está actualizado?"), issue = "double",
       why = tr("Clarity and currency are different qualities; it is also a yes/no question.", "La claridad y la actualización son cualidades distintas; además es una pregunta de sí o no."))
)

# Heuristic checks on a question; they suggest, they do not judge.
question_checks <- function(q) {
  x <- tolower(trimws(q))
  if (!nzchar(x)) return(list())
  has <- function(words) any(vapply(words, function(w) grepl(w, x, fixed = TRUE), TRUE))
  starts <- function(words) any(vapply(words, function(w) startsWith(sub("^[¿¡\"'«]+", "", x), w), TRUE))
  n_words <- length(strsplit(x, "\\s+")[[1]])
  out <- list(
    list(ok = !has(tr(c("don't you", "wouldn't you", "isn't it", "aren't they", "how much do you like", "how easy", "how great", "agree that", "love", "obviously", "better"),
                      c("no crees", "no te parece", "verdad", "cuánto te gusta", "qué tan fácil", "lo fácil", "estás de acuerdo en que", "encanta", "obviamente", "mejor"))),
         text = tr("No leading wording", "Sin palabras inductoras")),
    list(ok = !grepl(tr(" and | or ", " y | o | e | u "), x), text = tr("Asks one thing at a time", "Pregunta una sola cosa")),
    list(ok = !starts(tr(c("would you", "will you", "if there were", "if you could", "would it"), c("usarías", "te gustaría", "si hubiera", "si pudieras", "pagarías", "comprarías", "querrías"))),
         text = tr("About real past behaviour, not a hypothetical", "Sobre comportamiento real pasado, no hipotético")),
    list(ok = !starts(tr(c("do ", "does ", "did ", "is ", "are ", "was ", "were ", "can ", "could ", "have ", "has "), c("es ", "está", "has ", "hay ", "usas ", "te ", "puedes ", "tienes ", "sueles "))),
         text = tr("Open, not yes/no", "Abierta, no de sí o no")),
    list(ok = !has(tr(c("ux", "ui ", "interface", "navigation", "funnel", "usability", "cta", "onboarding", "workflow"),
                      c("ux", "interfaz", "navegación", "embudo", "usabilidad", "cta", "onboarding", "workflow", "flujo"))),
         text = tr("Uses everyday words", "Usa palabras cotidianas")),
    list(ok = n_words <= 25, text = tr("Short enough to say aloud (≤ 25 words)", "Lo bastante corta para decirla en voz alta (≤ 25 palabras)")))
  out
}

interviews_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Recognise leading, double-barrelled and hypothetical questions.", "Reconocer preguntas inductoras, dobles e hipotéticas."),
                   tr("Rewrite questions to be open, neutral and grounded in past behaviour.", "Reescribir preguntas para que sean abiertas, neutrales y basadas en el comportamiento pasado."),
                   tr("Know when a survey question should be closed.", "Saber cuándo una pregunta de encuesta debe ser cerrada.")),
    concept = tr("Good research questions ask about specific past experiences in the participant's own words. The question shapes the answer: a leading question gets agreement, a hypothetical one gets optimism.",
                 "Las buenas preguntas de investigación preguntan por experiencias pasadas concretas con las palabras del participante. La pregunta condiciona la respuesta: una inductora obtiene acuerdo y una hipotética, optimismo."),
    activity = tagList(
      p(tr("Challenge · Diagnose each draft question from a colleague's interview guide, then rewrite it.", "Reto · Diagnostica cada pregunta del borrador de guion de un colega y reescríbela.")),
      layout_columns(col_widths = c(6, 6),
        div(
          selectInput(ns("q"), tr("Draft question", "Pregunta del borrador"), setNames(seq_along(question_bank), vapply(question_bank, `[[`, "", "text")), width = "100%"),
          radioButtons(ns("issue"), tr("Main problem", "Problema principal"), setNames(names(question_issues), question_issues)),
          actionButton(ns("diagnose"), tr("Check diagnosis", "Comprobar diagnóstico"), class = "btn-primary"),
          uiOutput(ns("diagnosis"))),
        div(
          textAreaInput(ns("rewrite"), tr("Your rewrite (or any question you want to check)", "Tu versión (o cualquier pregunta que quieras revisar)"), rows = 3, width = "100%"),
          div(class = "panel-soft", span(class = "eyebrow", tr("LIVE CHECKS", "COMPROBACIONES EN DIRECTO")), uiOutput(ns("checks"))),
          actionButton(ns("save"), tr("Save rewrite to my guide", "Guardar en mi guion"), class = "btn-outline-success mt-2"))),
      h4(class = "mt-4", tr("My interview guide", "Mi guion de entrevista")),
      uiOutput(ns("guide"))),
    reflection = tr("Which bias was hardest to remove from your own questions? How would you notice it during a live interview?",
                    "¿Qué sesgo te costó más quitar de tus preguntas? ¿Cómo lo notarías durante una entrevista en directo?"))
}

interviews_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    guide <- reactiveVal(data.frame(original = character(), rewrite = character()))
    diag <- reactiveVal(NULL)
    diagnosed <- reactiveVal(0L)

    observeEvent(input$diagnose, {
      item <- question_bank[[as.integer(input$q)]]
      right <- input$issue == item$issue
      if (right) diagnosed(diagnosed() + 1L)
      diag(div(class = paste("alert mt-3", if (right) "alert-success" else "alert-info"),
        tags$strong(if (right) tr("Yes. ", "Sí. ") else paste0(tr("Look again: the main problem is ", "Míralo otra vez: el problema principal es "), tolower(question_issues[[item$issue]]), ". ")),
        item$why))
    })
    observeEvent(input$q, diag(NULL))
    output$diagnosis <- renderUI(diag())

    output$checks <- renderUI({
      ch <- question_checks(input$rewrite %||% "")
      if (!length(ch)) return(p(class = "footnote mb-0", tr("Type a question to see the checks.", "Escribe una pregunta para ver las comprobaciones.")))
      tagList(check_list(ch), p(class = "footnote mb-0 mt-2", tr("Checks are rules of thumb: a closed question is right for a survey item, for example.",
                                                                   "Son reglas generales: por ejemplo, una pregunta cerrada es correcta en un ítem de encuesta.")))
    })

    observeEvent(input$save, {
      r <- trimws(input$rewrite %||% "")
      req(nzchar(r))
      guide(rbind(guide(), data.frame(original = question_bank[[as.integer(input$q)]]$text, rewrite = r)))
      updateTextAreaInput(session, "rewrite", value = "")
    })
    output$guide <- renderUI({
      g <- guide()
      if (!nrow(g)) return(p(class = "muted", tr("Saved rewrites appear here as an interview guide you can download with your notes.", "Las versiones guardadas aparecen aquí como un guion que puedes descargar con tus notas.")))
      tags$ol(lapply(seq_len(nrow(g)), function(i) tags$li(tags$strong(g$rewrite[i]), br(), span(class = "footnote", tr("was: ", "antes: "), g$original[i]))))
    })

    lines <- function() {
      g <- guide()
      c(sprintf(tr("Correct diagnoses: %d", "Diagnósticos correctos: %d"), diagnosed()),
        tr("Interview guide:", "Guion de entrevista:"),
        if (nrow(g)) paste0(seq_len(nrow(g)), ". ", g$rewrite, tr("  (was: ", "  (antes: "), g$original, ")") else tr("(empty)", "(vacío)"))
    }
    observeEvent(input$example, {
      guide(data.frame(original = vapply(question_bank[c(1, 3, 8)], `[[`, "", "text"),
        rewrite = c(tr("How did you find using the new app the last time you opened it?", "¿Cómo fue usar la nueva app la última vez que la abriste?"),
                    tr("Tell me about how you plan your study week now.", "Cuéntame cómo planificas ahora tu semana de estudio."),
                    tr("Tell me about the last time you checked the timetable.", "Cuéntame la última vez que consultaste el horario."))))
      updateTextAreaInput(session, "rewrite", value = tr("Tell me about the last time you checked the timetable.", "Cuéntame la última vez que consultaste el horario."))
      example_reflection(session, tr("The hypothetical price question was hardest: I wanted to know about willingness to pay. Asking how they plan now, and what they already pay for, gives real evidence instead.",
                                     "La pregunta hipotética del precio fue la más difícil: quería saber la disposición a pagar. Preguntar cómo planifican ahora y por qué pagan ya da evidencia real."))
    })

    reflect_server(tr("Interviews and surveys", "Entrevistas y encuestas"), input, output, session, lines)
  })
}

lab_content$questions <- list(
  theory = list(
    list(title = tr("Interviewing: stories, not opinions", "Entrevistar: historias, no opiniones"), body = c(
      tr("Steve Portigal recommends asking for <strong>specific past stories</strong> (‘Tell me about the last time…’) and following up with neutral probes: ‘What happened next?’, ‘Why was that?’, ‘Can you show me?’. Silence is a tool: wait a few seconds before the next question.",
         "Steve Portigal recomienda pedir <strong>historias concretas del pasado</strong> («Cuéntame la última vez que…») y seguir con preguntas neutras: «¿Qué pasó después?», «¿Por qué?», «¿Me lo enseñas?». El silencio es una herramienta: espera unos segundos antes de la siguiente pregunta."),
      tr("<em>The Mom Test</em> (Fitzpatrick, 2013) summarises it: talk about their life, not your idea; ask about specifics in the past, not opinions about the future.",
         "<em>The Mom Test</em> (Fitzpatrick, 2013) lo resume: habla de su vida, no de tu idea; pregunta por hechos concretos del pasado, no por opiniones sobre el futuro."))),
    list(title = tr("Common question biases", "Sesgos habituales en las preguntas"), body = c(
      tr("<strong>Leading</strong> questions suggest the answer. <strong>Double-barrelled</strong> questions ask two things at once. <strong>Hypothetical</strong> questions ask people to predict, which they do badly. <strong>Loaded</strong> wording carries assumptions (‘Why is the app so slow?’). <strong>Acquiescence bias</strong> makes people agree with statements, especially in person.",
         "Las preguntas <strong>inductoras</strong> sugieren la respuesta. Las <strong>dobles</strong> preguntan dos cosas a la vez. Las <strong>hipotéticas</strong> piden predecir, algo que la gente hace mal. Las preguntas <strong>cargadas</strong> llevan supuestos («¿Por qué es tan lenta la app?»). El <strong>sesgo de aquiescencia</strong> lleva a estar de acuerdo con las afirmaciones, sobre todo en persona."))),
    list(title = tr("Survey questions are different", "Las preguntas de encuesta son distintas"), body = c(
      tr("Surveys need mostly <strong>closed</strong> questions so answers can be counted. Use balanced Likert scales (for example 1 Strongly disagree – 5 Strongly agree), include a neutral point and ‘not applicable’ when relevant, and keep one idea per item. Pilot the survey with a few people before sending it.",
         "Las encuestas necesitan sobre todo preguntas <strong>cerradas</strong> para poder contar las respuestas. Usa escalas Likert equilibradas (por ejemplo, 1 Muy en desacuerdo – 5 Muy de acuerdo), incluye un punto neutro y «no aplica» cuando proceda, y una sola idea por ítem. Haz una prueba piloto con unas pocas personas antes de enviarla."),
      tr("Standardised questionnaires such as SUS or UMUX-Lite (lab 11) have known reliability and benchmarks; prefer them to home-made satisfaction items.",
         "Los cuestionarios estandarizados como SUS o UMUX-Lite (lab 11) tienen fiabilidad y valores de referencia conocidos; prefiérelos a ítems de satisfacción caseros.")))),
  mistakes = c(
    tr("Pitching your idea during the interview, then asking whether they like it.", "Presentar tu idea durante la entrevista y después preguntar si les gusta."),
    tr("Reading the guide like a script instead of following the participant's story.", "Leer el guion como un texto cerrado en vez de seguir la historia del participante."),
    tr("Filling silences with suggestions.", "Llenar los silencios con sugerencias."),
    tr("Asking ‘Why?’ repeatedly in a way that sounds like an accusation; try ‘What made you…?’", "Preguntar «¿Por qué?» una y otra vez de forma que suena a reproche; prueba «¿Qué te llevó a…?».")),
  reading = c(
    "Portigal, S. (2023). <em>Interviewing Users</em> (2nd ed.). Rosenfeld Media.",
    "Fitzpatrick, R. (2013). <em>The Mom Test</em>. CreateSpace.",
    "Sauro, J., &amp; Lewis, J. R. (2016). <em>Quantifying the User Experience</em> (2nd ed.), ch. 8. Morgan Kaufmann.",
    "Dillman, D. A., Smyth, J. D., &amp; Christian, L. M. (2014). <em>Internet, Phone, Mail, and Mixed-Mode Surveys</em> (4th ed.). Wiley."),
  quiz = list(
    list(q = tr("Which question is the best opener for a discovery interview?", "¿Qué pregunta es mejor para abrir una entrevista exploratoria?"),
         options = c(tr("Would you use an app that reminds you of deadlines?", "¿Usarías una app que te recuerde las fechas de entrega?"), tr("Tell me about the last deadline you nearly missed.", "Cuéntame la última fecha de entrega que casi se te pasa."), tr("Do you find deadlines stressful?", "¿Te estresan las fechas de entrega?")),
         answer = 2, why = tr("It is open, neutral and grounded in a real past experience.", "Es abierta, neutral y está anclada en una experiencia real pasada.")),
    list(q = tr("‘How fast and reliable is the app?’ is a problem because it is…", "«¿Qué tan rápida y fiable es la app?» es un problema porque es…"),
         options = c(tr("Double-barrelled", "Doble"), tr("Hypothetical", "Hipotética"), tr("Too short", "Demasiado corta")),
         answer = 1, why = tr("Speed and reliability are two attributes; split them.", "Velocidad y fiabilidad son dos atributos; sepáralos.")),
    list(q = tr("When is a closed question the right choice?", "¿Cuándo es correcta una pregunta cerrada?"),
         options = c(tr("To open an interview", "Para abrir una entrevista"), tr("In a survey item you will count", "En un ítem de encuesta que vas a contar"), tr("To explore motivations", "Para explorar motivaciones")),
         answer = 2, why = tr("Closed questions give comparable answers that can be quantified.", "Las preguntas cerradas dan respuestas comparables que se pueden cuantificar.")))
)
