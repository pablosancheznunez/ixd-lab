# Research methods: choose a method that fits the research question, on the
# attitudinal–behavioural and qualitative–quantitative landscape (after Rohrer, NN/g).
research_methods <- data.frame(
  id = c("interviews", "contextual", "diary", "usability", "survey", "cardsort", "treetest", "analytics", "abtest", "focus"),
  name = c(tr("User interviews", "Entrevistas con usuarios"), tr("Contextual inquiry", "Indagación contextual"), tr("Diary study", "Estudio de diario"),
           tr("Usability test", "Test de usabilidad"), tr("Survey", "Encuesta"), tr("Card sorting", "Card sorting"), tr("Tree testing", "Tree testing"),
           tr("Analytics", "Analítica"), tr("A/B test", "Test A/B"), tr("Focus group", "Grupo focal")),
  x = c(.12, .62, .42, .78, .1, .32, .7, .95, .9, .06),
  y = c(.14, .2, .32, .26, .86, .55, .72, .95, .84, .06)
)

research_scenarios <- list(
  enrol = list(text = tr("Students drop out of the online enrolment form at step 3. You need to understand why.", "El alumnado abandona el formulario de matrícula en el paso 3. Necesitas entender por qué."),
               best = c("usability"), good = c("interviews", "analytics", "contextual"),
               why = tr("You need to see people struggle and hear their reasoning: a think-aloud usability test of step 3 does both. Analytics can confirm where they drop out, but not why.",
                        "Necesitas ver a la gente atascarse y escuchar su razonamiento: un test de usabilidad con pensamiento en voz alta del paso 3 hace ambas cosas. La analítica confirma dónde abandonan, pero no por qué.")),
  alumni = list(text = tr("Estimate how many of 20,000 alumni would join a mentoring programme, and why they would or would not.", "Estimar cuántos de 20.000 antiguos alumnos se apuntarían a un programa de mentoría, y por qué sí o no."),
                best = c("survey"), good = c("interviews"),
                why = tr("‘How many’ across a large population is a quantitative, attitudinal question: a survey with a representative sample. A few interviews first help you write good survey questions.",
                         "«Cuántos» en una población grande es una pregunta cuantitativa y actitudinal: una encuesta con una muestra representativa. Unas pocas entrevistas antes ayudan a redactar buenas preguntas.")),
  button = list(text = tr("Decide which of two checkout button wordings leads to more completed purchases.", "Decidir cuál de dos textos del botón de pago lleva a más compras completadas."),
                best = c("abtest"), good = c("analytics"),
                why = tr("A causal question about behaviour at scale: a randomised A/B test with enough traffic (lab 14).", "Una pregunta causal sobre comportamiento a escala: un test A/B aleatorizado con tráfico suficiente (lab 14).")),
  nurses = list(text = tr("Understand how nurses plan their shifts across a whole week, at work and at home.", "Entender cómo planifican las enfermeras sus turnos a lo largo de una semana, en el trabajo y en casa."),
                best = c("diary", "contextual"), good = c("interviews"),
                why = tr("Behaviour that unfolds over days and in context: a diary study captures it over time, and contextual inquiry shows the real environment.",
                         "Un comportamiento que se despliega durante días y en contexto: un estudio de diario lo recoge en el tiempo, y la indagación contextual muestra el entorno real.")),
  help = list(text = tr("Group 60 help articles for a new support centre in a way that makes sense to customers.", "Agrupar 60 artículos de ayuda de un nuevo centro de soporte de forma que tenga sentido para la clientela."),
              best = c("cardsort"), good = c("treetest", "interviews"),
              why = tr("Card sorting reveals how people group content; then tree-test the resulting structure.", "El card sorting revela cómo agrupa la gente el contenido; después, valida la estructura resultante con un tree test.")),
  menu = list(text = tr("Check whether people can find ‘Change payment method’ in a proposed menu, before any visual design exists.", "Comprobar si la gente encuentra «Cambiar método de pago» en un menú propuesto, antes de que exista el diseño visual."),
              best = c("treetest"), good = c("usability"),
              why = tr("Findability in a hierarchy without visual design is exactly what tree testing measures.", "La encontrabilidad en una jerarquía sin diseño visual es justo lo que mide el tree testing."))
)

research_methods_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Match a research question to a suitable method.", "Asociar una pregunta de investigación con un método adecuado."),
                   tr("Place methods on the attitudinal–behavioural and qualitative–quantitative axes.", "Situar los métodos en los ejes actitudinal–conductual y cualitativo–cuantitativo."),
                   tr("Write a short, defensible research plan.", "Redactar un plan de investigación breve y defendible.")),
    concept = tr("Start from the question, not the method. What people say (attitudes) and what they do (behaviour) often differ, and ‘why’ questions need qualitative methods while ‘how many’ questions need quantitative ones.",
                 "Empieza por la pregunta, no por el método. Lo que la gente dice (actitudes) y lo que hace (comportamiento) a menudo difieren, y las preguntas «por qué» requieren métodos cualitativos mientras que las de «cuántos» requieren cuantitativos."),
    activity = tagList(
      p(tr("Challenge · For each research question, choose the method you would use first and say why.", "Reto · Para cada pregunta de investigación, elige el método que usarías primero y explica por qué.")),
      layout_columns(col_widths = c(6, 6),
        div(
          radioButtons(ns("scenario"), tr("Research question", "Pregunta de investigación"), width = "100%",
                       setNames(names(research_scenarios), vapply(research_scenarios, `[[`, "", "text"))),
          selectInput(ns("method"), tr("Method you would use first", "Método que usarías primero"), setNames(research_methods$id, research_methods$name)),
          textAreaInput(ns("reason"), tr("Why this method? What will it tell you, and what not?", "¿Por qué este método? ¿Qué te dirá y qué no?"), rows = 3, width = "100%"),
          numericInput(ns("participants"), tr("Planned participants", "Participantes previstos"), 5, min = 1, max = 5000),
          actionButton(ns("check"), tr("Add to my plan", "Añadir a mi plan"), class = "btn-primary"),
          uiOutput(ns("feedback"))),
        div(
          plotOutput(ns("landscape"), height = "380px"),
          p(class = "footnote", tr("Green: your choice · Ring: methods that fit this question best.", "Verde: tu elección · Anillo: métodos que mejor encajan con esta pregunta.")))),
      h4(class = "mt-4", tr("My research plan", "Mi plan de investigación")),
      tableOutput(ns("plan"))),
    reflection = tr("Which of your questions needed more than one method? In what order would you run them, and why?",
                    "¿Cuál de tus preguntas necesitaba más de un método? ¿En qué orden los aplicarías y por qué?"))
}

research_methods_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    plan <- reactiveVal(data.frame(question = character(), method = character(), fit = character(), n = integer(), reason = character()))
    feedback <- reactiveVal(NULL)
    method_name <- function(ids) research_methods$name[match(ids, research_methods$id)]

    output$landscape <- renderPlot({
      sc <- research_scenarios[[input$scenario]]
      ixd_par()
      plot(NA, xlim = c(-.05, 1.12), ylim = c(-.05, 1.08), xaxt = "n", yaxt = "n",
           xlab = tr("Attitudinal (what people say)  →  Behavioural (what people do)", "Actitudinal (lo que dicen)  →  Conductual (lo que hacen)"),
           ylab = tr("Qualitative (why, how)  →  Quantitative (how many)", "Cualitativo (por qué, cómo)  →  Cuantitativo (cuántos)"))
      abline(h = .5, v = .5, col = "#e3e0d7", lty = 2)
      best <- research_methods$id %in% sc$best
      points(research_methods$x[best], research_methods$y[best], cex = 4.2, col = ixd_sand, lwd = 3)
      chosen <- research_methods$id == input$method
      points(research_methods$x, research_methods$y, pch = 19, cex = 1.6, col = ifelse(chosen, ixd_green, "#9a9a9a"))
      text(research_methods$x, research_methods$y, research_methods$name, pos = ifelse(research_methods$x > .8, 2, 4), cex = .85, col = ifelse(chosen, ixd_green, "#5f665f"))
    }, res = 96)

    observeEvent(input$check, {
      sc <- research_scenarios[[input$scenario]]
      reason <- trimws(input$reason)
      if (nchar(reason) < 15) return(feedback(div(class = "alert alert-warning mt-3", tr("Say in a sentence why this method fits: what will it tell you?", "Explica en una frase por qué encaja este método: ¿qué te dirá?"))))
      fit <- if (input$method %in% sc$best) "best" else if (input$method %in% sc$good) "good" else "weak"
      plan(rbind(plan(), data.frame(question = sc$text, method = method_name(input$method),
                                    fit = c(best = tr("Strong fit", "Encaje fuerte"), good = tr("Useful complement", "Complemento útil"), weak = tr("Weak fit", "Encaje débil"))[[fit]],
                                    n = as.integer(input$participants %||% NA), reason = reason)))
      updateTextAreaInput(session, "reason", value = "")
      n_note <- if (input$method %in% c("survey", "abtest", "analytics") && isTRUE(input$participants < 100))
        tr(" For a quantitative method, a handful of participants is far too few: plan for hundreds.", " Para un método cuantitativo, unos pocos participantes son demasiado pocos: planifica cientos.")
      else if (input$method %in% c("usability", "interviews", "contextual", "diary") && isTRUE(input$participants > 30))
        tr(" For a qualitative method, 5–12 participants per user group is usually enough; more adds cost but little new insight.", " Para un método cualitativo, 5–12 participantes por grupo de usuarios suelen bastar; más añade coste pero pocas ideas nuevas.")
      else ""
      cls <- c(best = "alert-success", good = "alert-info", weak = "alert-warning")[[fit]]
      feedback(div(class = paste("alert mt-3", cls),
        tags$strong(c(best = tr("Strong fit. ", "Encaje fuerte. "), good = tr("Useful, but not the best first step. ", "Útil, pero no el mejor primer paso. "), weak = tr("Weak fit. ", "Encaje débil. "))[[fit]]),
        sc$why, n_note))
    })
    output$feedback <- renderUI(feedback())
    output$plan <- renderTable({
      x <- plan()
      if (!nrow(x)) return(setNames(data.frame(tr("Nothing in your plan yet.", "Tu plan todavía está vacío.")), " "))
      setNames(x, c(tr("Question", "Pregunta"), tr("Method", "Método"), tr("Fit", "Encaje"), "n", tr("Why", "Por qué")))
    }, striped = TRUE, width = "100%")

    lines <- function() {
      x <- plan()
      if (!nrow(x)) return(tr("(no plan yet)", "(sin plan todavía)"))
      unlist(lapply(seq_len(nrow(x)), function(i) c(paste0(i, ". ", x$question[i]), paste0("   ", x$method[i], " · ", x$fit[i], " · n = ", x$n[i]), paste0("   ", x$reason[i]))))
    }
    observeEvent(input$example, {
      plan(data.frame(question = c(research_scenarios$enrol$text, research_scenarios$help$text), method = method_name(c("usability", "cardsort")),
                      fit = tr("Strong fit", "Encaje fuerte"), n = c(6L, 15L),
                      reason = c(tr("I need to watch people at step 3 and hear what confuses them.", "Necesito ver a la gente en el paso 3 y oír qué le confunde."),
                                 tr("An open sort shows how customers group the topics; I would tree-test afterwards.", "Un card sorting abierto muestra cómo agrupa la clientela los temas; después haría un tree test."))))
      example_reflection(session, tr("The enrolment question needs two methods: analytics to locate the drop-off precisely, then a usability test to understand why. I would run analytics first because it is cheap and focuses the test.",
                                     "La pregunta de la matrícula necesita dos métodos: analítica para localizar el abandono con precisión y después un test de usabilidad para entender por qué. Empezaría por la analítica porque es barata y enfoca el test."))
    })

    reflect_server(tr("Research methods", "Métodos de investigación"), input, output, session, lines)
  })
}

lab_content$research <- list(
  theory = list(
    list(title = tr("The landscape of UX research methods", "El mapa de métodos de investigación UX"), body = c(
      tr("Christian Rohrer's landscape places methods on three dimensions: <strong>attitudinal vs behavioural</strong> (what people say vs what they do), <strong>qualitative vs quantitative</strong> (why and how vs how many and how much), and the <strong>context of use</strong> (natural, scripted, decontextualised).",
         "El mapa de Christian Rohrer sitúa los métodos en tres dimensiones: <strong>actitudinal frente a conductual</strong> (lo que la gente dice frente a lo que hace), <strong>cualitativo frente a cuantitativo</strong> (por qué y cómo frente a cuántos y cuánto) y el <strong>contexto de uso</strong> (natural, guionizado o descontextualizado)."),
      tr("Self-report is useful for motivations and perceptions, but people are poor predictors of their own future behaviour. When the question is about behaviour, observe behaviour.",
         "El autoinforme sirve para motivaciones y percepciones, pero la gente predice mal su propio comportamiento futuro. Cuando la pregunta es sobre comportamiento, observa el comportamiento."))),
    list(title = tr("Generative vs evaluative research", "Investigación generativa frente a evaluativa"), body = c(
      tr("<strong>Generative</strong> (or exploratory) research discovers needs and opportunities before a solution exists: interviews, contextual inquiry, diary studies. <strong>Evaluative</strong> research tests a solution: usability tests, tree tests, A/B tests. In the double diamond, generative work dominates the first diamond and evaluative work the second.",
         "La investigación <strong>generativa</strong> (o exploratoria) descubre necesidades y oportunidades antes de que exista una solución: entrevistas, indagación contextual, estudios de diario. La investigación <strong>evaluativa</strong> pone a prueba una solución: tests de usabilidad, tree tests, tests A/B. En el doble diamante, el trabajo generativo domina el primer diamante y el evaluativo el segundo."))),
    list(title = tr("Sample sizes and triangulation", "Tamaño de muestra y triangulación"), body = c(
      tr("Qualitative studies aim at saturation, often reached with 5–12 participants per distinct user group. Quantitative studies need samples large enough for the precision you want: often hundreds for surveys and thousands per variant for A/B tests.",
         "Los estudios cualitativos buscan la saturación, que suele alcanzarse con 5–12 participantes por grupo de usuarios. Los cuantitativos necesitan muestras suficientes para la precisión deseada: a menudo cientos en encuestas y miles por variante en tests A/B."),
      tr("<strong>Triangulation</strong> combines methods so that the weakness of one is covered by another: analytics shows where, testing shows why, a survey shows how widespread.",
         "La <strong>triangulación</strong> combina métodos para que la debilidad de uno quede cubierta por otro: la analítica muestra dónde, el test muestra por qué y la encuesta muestra cuánto se extiende."))),
    list(title = tr("Research ethics", "Ética de la investigación"), body = c(
      tr("Informed consent, the right to withdraw, data minimisation and secure storage apply to every study with people. In the EU, personal data falls under the GDPR. See RESEARCH_ETHICS.md in the IxD Lab repository for a checklist.",
         "El consentimiento informado, el derecho a retirarse, la minimización de datos y el almacenamiento seguro se aplican a todo estudio con personas. En la UE, los datos personales están sujetos al RGPD. Consulta RESEARCH_ETHICS.md en el repositorio de IxD Lab para ver una lista de comprobación.")))),
  mistakes = c(
    tr("Asking people whether they would use a feature, and treating the answer as a forecast.", "Preguntar a la gente si usaría una función y tomar la respuesta como una previsión."),
    tr("Using focus groups to evaluate usability: group dynamics hide individual behaviour.", "Usar grupos focales para evaluar la usabilidad: la dinámica de grupo oculta el comportamiento individual."),
    tr("Running a survey with 12 respondents and reporting percentages.", "Hacer una encuesta con 12 respuestas y presentar porcentajes."),
    tr("Choosing the method you know best rather than the one the question needs.", "Elegir el método que mejor conoces en lugar del que necesita la pregunta.")),
  reading = c(
    "Rohrer, C. (2022). <em>When to Use Which User-Experience Research Methods</em>. Nielsen Norman Group.",
    "Hall, E. (2019). <em>Just Enough Research</em> (2nd ed.). A Book Apart.",
    "Goodman, E., Kuniavsky, M., &amp; Moed, A. (2012). <em>Observing the User Experience</em> (2nd ed.). Morgan Kaufmann.",
    "Lazar, J., Feng, J. H., &amp; Hochheiser, H. (2017). <em>Research Methods in Human-Computer Interaction</em> (2nd ed.). Morgan Kaufmann."),
  quiz = list(
    list(q = tr("‘Why do people abandon the cart?’ is mainly a…", "«¿Por qué abandona la gente el carrito?» es sobre todo una pregunta…"),
         options = c(tr("Quantitative question", "Cuantitativa"), tr("Qualitative question", "Cualitativa"), tr("Question for an A/B test", "Para un test A/B")),
         answer = 2, why = tr("‘Why’ asks for reasons and context, which qualitative methods such as testing and interviews provide.", "El «por qué» pide razones y contexto, que aportan métodos cualitativos como los tests y las entrevistas.")),
    list(q = tr("Which method is behavioural and quantitative?", "¿Qué método es conductual y cuantitativo?"),
         options = c(tr("Survey", "Encuesta"), tr("Analytics", "Analítica"), tr("User interview", "Entrevista")),
         answer = 2, why = tr("Analytics records what large numbers of people actually do.", "La analítica registra lo que hace realmente un gran número de personas.")),
    list(q = tr("What is triangulation?", "¿Qué es la triangulación?"),
         options = c(tr("Using three participants per study", "Usar tres participantes por estudio"), tr("Combining methods so their weaknesses offset each other", "Combinar métodos para que sus debilidades se compensen"), tr("Testing three design variants", "Probar tres variantes de diseño")),
         answer = 2, why = tr("Different methods answer different parts of a question; together they give stronger evidence.", "Cada método responde a una parte de la pregunta; juntos dan una evidencia más sólida.")))
)
