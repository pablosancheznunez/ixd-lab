library(shiny)
library(bslib)

source("R/helpers.R")
for (f in list.files("R/labs", pattern = "\\.R$", full.names = TRUE)) source(f)
source("R/content_core.R")
source("R/glossary.R")

repo_url <- "https://github.com/pablosancheznunez/ixd-lab"
orcid_url <- "https://orcid.org/0000-0001-7845-9506"
cc_by_url <- tr("https://creativecommons.org/licenses/by/4.0/", "https://creativecommons.org/licenses/by/4.0/deed.es")
version <- "0.2"

ext_link <- function(href, ...) tags$a(href = href, target = "_blank", rel = "noopener", ...)

# The three modules follow a design process: understand people, design, then evaluate.
modules <- list(
  discover = list(title = tr("Discover", "Descubrir"), desc = tr("Understand people and their context before designing anything.", "Entender a las personas y su contexto antes de diseñar nada.")),
  design = list(title = tr("Design", "Diseñar"), desc = tr("Structure content, lay out screens and shape interactions and words.", "Estructurar contenidos, maquetar pantallas y dar forma a interacciones y textos.")),
  evaluate = list(title = tr("Evaluate", "Evaluar"), desc = tr("Inspect, test, measure and question your designs, ethically.", "Inspeccionar, probar, medir y cuestionar tus diseños, con ética."))
)

lab <- function(module, title, desc, ui, server, ns, short = NULL, minutes = 20) {
  list(module = module, title = title, short = short %||% title, desc = desc, ui = ui, server = server, ns = ns, minutes = minutes)
}
labs <- list(
  research_methods = lab("discover", tr("Research methods", "Métodos de investigación"),
    tr("Match research questions to methods and build a defensible research plan.", "Asocia preguntas de investigación con métodos y construye un plan defendible."), research_methods_ui, research_methods_server, "research"),
  interviews = lab("discover", tr("Interviews and surveys", "Entrevistas y encuestas"),
    tr("Diagnose biased questions and write an interview guide that gets real stories.", "Diagnostica preguntas sesgadas y escribe un guion que obtenga historias reales."), interviews_ui, interviews_server, "questions"),
  personas = lab("discover", tr("Personas", "Personas"),
    tr("Tag interview notes into themes and build a persona backed by evidence.", "Etiqueta notas de entrevista en temas y construye una persona respaldada por evidencia."), personas_ui, personas_server, "persona", minutes = 25),
  journey = lab("discover", tr("Journey mapping", "Mapas de recorrido"),
    tr("Map an end-to-end experience, find the low points and turn them into opportunities.", "Mapea una experiencia completa, encuentra los puntos bajos y conviértelos en oportunidades."), journey_ui, journey_server, "journey", short = tr("Journey maps", "Recorridos")),
  information_architecture = lab("design", tr("Information architecture", "Arquitectura de la información"),
    tr("Sort content into categories and compare your structure with a reference.", "Ordena contenidos en categorías y compara tu estructura con una de referencia."), information_architecture_ui, information_architecture_server, "ia", minutes = 15),
  wireframing = lab("design", tr("Wireframing", "Wireframing"),
    tr("Build a low-fidelity page, test it at three widths, and check its hierarchy.", "Construye una página de baja fidelidad, pruébala en tres anchos y revisa su jerarquía."), wireframing_ui, wireframing_server, "wire", minutes = 15),
  interaction_patterns = lab("design", tr("Interaction patterns", "Patrones de interacción"),
    tr("Try feedback, undo and validation patterns, then choose the right one.", "Prueba patrones de feedback, deshacer y validación, y elige el adecuado."), interaction_patterns_ui, interaction_patterns_server, "patterns", minutes = 15),
  ux_writing = lab("design", tr("UX writing", "Escritura UX"),
    tr("Rewrite errors, buttons and empty states, with readability and tone checks.", "Reescribe errores, botones y estados vacíos, con comprobaciones de legibilidad y tono."), ux_writing_ui, ux_writing_server, "writing"),
  laws_of_ux = lab("design", tr("Laws of UX", "Leyes de la UX"),
    tr("Run Fitts's and Hick's law experiments on yourself and fit the models to your data.", "Haz en ti mismo los experimentos de las leyes de Fitts y Hick y ajusta los modelos a tus datos."), laws_of_ux_ui, laws_of_ux_server, "laws"),
  usability = lab("evaluate", tr("Heuristic evaluation", "Evaluación heurística"),
    tr("Inspect three interfaces with heuristics and rate the severity of each issue.", "Inspecciona tres interfaces con heurísticas y valora la gravedad de cada problema."), usability_ui, usability_server, "use", short = tr("Heuristics", "Heurísticas")),
  ux_metrics = lab("evaluate", tr("Usability testing and metrics", "Tests de usabilidad y métricas"),
    tr("Score SUS, report success and time with confidence intervals, and size a study.", "Puntúa el SUS, presenta éxito y tiempo con intervalos de confianza y dimensiona un estudio."), ux_metrics_ui, ux_metrics_server, "metrics", short = tr("Testing and metrics", "Tests y métricas"), minutes = 25),
  accessibility = lab("evaluate", tr("Accessibility", "Accesibilidad"),
    tr("Check colour contrast, find a passing colour, and spot common barriers.", "Comprueba el contraste de color, encuentra un color válido y detecta barreras habituales."), accessibility_ui, accessibility_server, "access", minutes = 15),
  user_behaviour = lab("evaluate", tr("Behaviour analytics", "Analítica del comportamiento"),
    tr("Read simulated navigation traces and separate observations from explanations.", "Lee recorridos de navegación simulados y separa observaciones de explicaciones."), user_behaviour_ui, user_behaviour_server, "behaviour", short = tr("Analytics", "Analítica"), minutes = 15),
  ab_testing = lab("evaluate", tr("A/B testing", "Tests A/B"),
    tr("Plan a sample size, run a simulated experiment and see why peeking misleads.", "Planifica un tamaño de muestra, lanza un experimento simulado y descubre por qué mirar antes engaña."), ab_testing_ui, ab_testing_server, "ab", minutes = 25),
  dark_patterns = lab("evaluate", tr("Ethics and dark patterns", "Ética y patrones oscuros"),
    tr("Audit deceptive designs, rate their harm and propose fair alternatives under EU law.", "Audita diseños engañosos, valora su daño y propón alternativas justas según la normativa europea."), dark_patterns_ui, dark_patterns_server, "ethics", short = tr("Ethics", "Ética"))
)
for (i in seq_along(labs)) labs[[i]]$number <- sprintf("%02d", i)
n_labs <- length(labs)

goto_link <- function(target, ..., class = NULL) {
  tags$a(href = "#", class = class, onclick = js_event("goto", sprintf("'%s'", target)), ...)
}

ai_switch <- tags$a(class = "nav-link ai-switch", href = "#", `data-bs-toggle` = "modal", `data-bs-target` = "#ai-settings",
  title = tr("AI feedback and tutor settings", "Ajustes del feedback y el tutor con IA"),
  span(class = "ai-dot", `aria-hidden` = "true"), tr("✦ AI", "✦ IA"))

# Link to the same app in the other language; target _top leaves the Shinylive frame.
lang_switch <- tags$a(class = "nav-link lang-switch", target = "_top",
  href = if (LANG == "es") app_url[["en"]] else app_url[["es"]],
  hreflang = if (LANG == "es") "en" else "es",
  lang = if (LANG == "es") "en" else "es",
  `aria-label` = tr("Ver en español", "View in English"),
  tr("ES", "EN"))

lab_page <- function(id) {
  lab <- labs[[id]]
  i <- match(id, names(labs))
  prev_id <- if (i > 1) names(labs)[i - 1]
  next_id <- if (i < n_labs) names(labs)[i + 1]
  div(class = "container pb-4",
    div(class = "lab-head",
      span(class = "eyebrow", sprintf(tr("LAB %s OF %d · %s · ABOUT %d MIN", "LAB %s DE %d · %s · UNOS %d MIN"), lab$number, n_labs, toupper(modules[[lab$module]]$title), lab$minutes)),
      h1(lab$title),
      p(class = "muted mb-0", lab$desc)),
    lab$ui(lab$ns),
    div(class = "lab-pager",
      if (is.null(prev_id)) goto_link("home", tr("← All labs", "← Todos los labs")) else goto_link(prev_id, paste("←", labs[[prev_id]]$title)),
      if (is.null(next_id)) goto_link("glossary", tr("Glossary →", "Glosario →")) else goto_link(next_id, paste(labs[[next_id]]$title, "→"))))
}

lab_card <- function(id) {
  lab <- labs[[id]]
  goto_link(id, class = "lab-card",
    div(class = "d-flex justify-content-between", span(class = "lab-num", paste("LAB", lab$number)), span(class = "lab-num", paste0(lab$minutes, " min"))),
    h3(lab$title), p(lab$desc),
    div(class = "d-flex justify-content-between align-items-center gap-2", span(class = "go", tr("Open lab →", "Abrir lab →")), uiOutput(paste0("status_", id), inline = TRUE)))
}

home_page <- div(class = "container",
  div(class = "hero",
    span(class = "eyebrow", tr("AN AI-POWERED LEARNING AND EXPERIMENTATION ENVIRONMENT FOR INTERACTION DESIGN",
                               "UN ENTORNO DE APRENDIZAJE Y EXPERIMENTACIÓN CON IA PARA EL DISEÑO DE INTERACCIÓN")),
    h1(tr("Learn UX by doing it.", "Aprende UX haciéndola.")),
    p(class = "lead-text", tr(sprintf("%d hands-on labs that take you from research to evaluation: plan studies, build personas and journeys, design screens and words, run experiments on yourself, and measure usability. Each lab explains the theory, lets you practise, checks your understanding and helps you reflect.", n_labs),
                              sprintf("%d labs prácticos que te llevan de la investigación a la evaluación: planifica estudios, construye personas y recorridos, diseña pantallas y textos, haz experimentos contigo mismo y mide la usabilidad. Cada lab explica la teoría, te deja practicar, comprueba lo que has entendido y te ayuda a reflexionar.", n_labs))),
    div(class = "hero-actions",
      goto_link(names(labs)[1], tr("Start with lab 01", "Empieza por el lab 01"), class = "btn btn-primary btn-lg"),
      span(class = "muted", tr("No account · works on any device · your notes stay in your browser", "Sin registro · funciona en cualquier dispositivo · tus notas se quedan en tu navegador")))),
  div(class = "steps",
    div(class = "step", span(class = "eyebrow", tr("01 · LEARN", "01 · APRENDE")), h3(tr("Key ideas, explained", "Ideas clave, explicadas")),
        p(class = "muted", tr("Objectives, a key idea and a ‘Go deeper’ section with theory, common mistakes and references.", "Objetivos, una idea clave y una sección «Profundiza» con teoría, errores frecuentes y referencias."))),
    div(class = "step", span(class = "eyebrow", tr("02 · EXPERIMENT", "02 · EXPERIMENTA")), h3(tr("A hands-on task", "Una tarea práctica")),
        p(class = "muted", tr("Build, sort, test, measure or audit, with instant feedback and a worked example.", "Construye, ordena, prueba, mide o audita, con feedback inmediato y un ejemplo resuelto."))),
    div(class = "step", span(class = "eyebrow", tr("03 · CHECK", "03 · COMPRUEBA")), h3(tr("A quick quiz", "Un test rápido")),
        p(class = "muted", tr("Three questions with explained answers, so you know what you have understood.", "Tres preguntas con respuestas explicadas, para saber qué has entendido."))),
    div(class = "step", span(class = "eyebrow", tr("04 · REFLECT", "04 · REFLEXIONA")), h3(tr("Your reasoning, with AI", "Tu razonamiento, con IA")),
        p(class = "muted", tr("Write notes, get AI feedback, ask the AI tutor, and download a portfolio.", "Escribe notas, pide feedback a la IA, pregunta al tutor de IA y descarga un portafolio.")))),
  div(class = "progress-box",
    div(class = "d-flex flex-wrap justify-content-between align-items-center gap-3",
      div(span(class = "eyebrow", tr("YOUR PROGRESS", "TU PROGRESO")), uiOutput("progress")),
      div(class = "d-flex flex-wrap gap-2",
        downloadButton("portfolio", tr("Download my portfolio", "Descargar mi portafolio"), class = "btn-outline-success"),
        tags$button(type = "button", class = "btn btn-outline-secondary", onclick = sprintf("if (confirm('%s')) ixdClearNotes();", tr("Delete all notes saved in this browser?", "¿Borrar todas las notas guardadas en este navegador?")),
                    tr("Clear saved notes", "Borrar notas guardadas")))),
    uiOutput("progress_bar")),
  lapply(names(modules), function(m) div(class = "module",
    div(class = "module-head", span(class = "eyebrow", sprintf(tr("MODULE %d", "MÓDULO %d"), match(m, names(modules)))), h2(class = "section-title mb-1", modules[[m]]$title), p(class = "muted", modules[[m]]$desc)),
    div(class = "lab-grid", lapply(names(labs)[vapply(labs, `[[`, "", "module") == m], lab_card)))),
  div(class = "ai-box",
    span(class = "eyebrow", tr("OPTIONAL AI", "IA OPCIONAL")),
    h2(class = "section-title mt-2", tr("Bring your own AI: Claude, ChatGPT or Gemini", "Trae tu IA: Claude, ChatGPT o Gemini")),
    p(tr("Every lab can give formative feedback on your work and has an AI tutor for your questions. Choose a provider and add your own API key in ✦ AI. Your key and your text go straight from your browser to that provider, never to IxD Lab.",
         "Cada lab puede darte feedback formativo sobre tu trabajo y tiene un tutor de IA para tus preguntas. Elige un proveedor y añade tu propia clave de API en ✦ IA. Tu clave y tus textos van directamente de tu navegador a ese proveedor, nunca a IxD Lab.")),
    tags$button(type = "button", class = "btn btn-primary", `data-bs-toggle` = "modal", `data-bs-target` = "#ai-settings", tr("Set up AI", "Configurar la IA"))),
  div(class = "teacher-box",
    span(class = "eyebrow", tr("FOR TEACHERS", "PARA DOCENTES")),
    h2(class = "section-title mt-2", tr("Use it in class", "Úsalo en clase")),
    layout_columns(col_widths = c(6, 6),
      p(tr("Each lab works as a 15–25 minute studio activity, and the three modules follow a UX process, so they fit a master's course in user experience. Ask learners to keep three columns in their notes: what I changed, what I expected, and what I would need to test. They can submit the downloaded portfolio.",
           "Cada lab funciona como una actividad de taller de 15–25 minutos, y los tres módulos siguen un proceso UX, así que encajan en un máster en experiencia de usuario. Pide al alumnado que lleve tres columnas en sus notas: qué cambié, qué esperaba y qué necesitaría comprobar. Pueden entregar el portafolio descargado.")),
      p(tr("Feedback and quizzes are formative, not grades. Without an AI key, nothing learners write leaves their browser. The source, the content licence (CC BY 4.0) and the ",
           "El feedback y los tests son formativos, no notas. Sin clave de IA, nada de lo que escribe el alumnado sale de su navegador. El código, la licencia del contenido (CC BY 4.0) y la "),
        ext_link(paste0(repo_url, "/blob/main/ROADMAP.md"), tr("roadmap", "hoja de ruta")), tr(" are on GitHub.", " están en GitHub."))))
)

glossary_page <- div(class = "container hero",
  span(class = "eyebrow", tr("GLOSSARY", "GLOSARIO")),
  h1(tr("Key terms", "Términos clave")),
  p(class = "lead-text", tr("Short definitions of the concepts used in the labs, each with a link to where you can practise it.", "Definiciones breves de los conceptos de los labs, cada una con un enlace a donde puedes practicarlo.")),
  textInput("glossary_search", NULL, placeholder = tr("Search a term…", "Busca un término…"), width = "100%"),
  uiOutput("glossary_list"))

about_page <- div(class = "container hero",
  span(class = "eyebrow", tr("ABOUT THE PROJECT", "SOBRE EL PROYECTO")),
  h1(tr("A studio for thoughtful interaction.", "Un estudio para una interacción bien pensada.")),
  p(class = "lead-text", tr(sprintf("IxD Lab is an open educational resource for university teaching and independent study. It offers %d hands-on labs in three modules: Discover, Design and Evaluate. Activities are formative and illustrative, not validated assessment instruments.", n_labs),
                            sprintf("IxD Lab es un recurso educativo abierto para la docencia universitaria y el aprendizaje autónomo. Ofrece %d labs prácticos en tres módulos: Descubrir, Diseñar y Evaluar. Las actividades son formativas e ilustrativas, no instrumentos de evaluación validados.", n_labs))),
  h3(tr("Learn · Experiment · Research", "Aprende · Experimenta · Investiga")),
  p(tr("Learn introduces concepts, theory and references. Experiment offers interactive design tasks with feedback. Research is an opt-in mode in development: with informed consent, it will record anonymised interaction data to study how people learn interaction design. This version does not store participant data and reports no empirical findings.",
       "Aprende presenta conceptos, teoría y referencias. Experimenta ofrece tareas de diseño interactivas con feedback. Investiga es un modo voluntario en desarrollo: con consentimiento informado, registrará datos de interacción anonimizados para estudiar cómo se aprende diseño de interacción. Esta versión no guarda datos de participantes ni presenta resultados empíricos.")),
  h3(tr("AI and evidence", "IA y evidencia")),
  p(tr("Every lab can ask an AI model for formative feedback and has an AI tutor. You choose Claude (Anthropic), ChatGPT (OpenAI) or Gemini (Google) and use your own API key, which stays in your browser (✦ AI in the menu). AI output is always labelled with the provider, and nothing is sent until you ask. Any research with people will require their informed consent and follow the GDPR.",
       "Cada lab puede pedir feedback formativo a un modelo de IA y tiene un tutor de IA. Tú eliges Claude (Anthropic), ChatGPT (OpenAI) o Gemini (Google) y usas tu propia clave de API, que se queda en tu navegador (✦ IA en el menú). Lo que produce la IA siempre lleva el nombre del proveedor, y no se envía nada hasta que preguntas. Cualquier investigación con personas requerirá su consentimiento informado y cumplirá el RGPD.")),
  h3(tr("Privacy in this version", "Privacidad en esta versión")),
  p(tr("The app runs entirely in your browser. There are no accounts, cookies, or analytics. Your notes are saved only in this browser's local storage, on this device, so you can come back to them; you can delete them from the home page. If you use AI, the activity summary, your notes or your question for that lab go directly from your browser to the provider you chose when you ask, and nowhere else.",
       "La app funciona por completo en tu navegador. No hay cuentas, cookies ni analítica. Tus notas se guardan solo en el almacenamiento local de este navegador, en este dispositivo, para que puedas volver a ellas; puedes borrarlas desde la página de inicio. Si usas la IA, el resumen de la actividad, tus notas o tu pregunta de ese lab van directamente de tu navegador al proveedor que elegiste cuando preguntas, y a ningún otro sitio.")),
  h3(tr("Open educational resource", "Recurso educativo abierto")),
  p(tr("IxD Lab is an open educational resource (OER): you may keep, reuse, adapt, remix, and share it, in your own courses or for self-study, with attribution.",
       "IxD Lab es un recurso educativo abierto (REA): puedes conservarlo, reutilizarlo, adaptarlo, mezclarlo y compartirlo, en tus cursos o para estudiar por tu cuenta, citando la autoría.")),
  tags$ul(
    tags$li(tags$strong(tr("Educational content", "Contenido educativo")),
            tr(" (objectives, key ideas, explanations, activities, scenarios, quizzes, prompts, and feedback): ", " (objetivos, ideas clave, explicaciones, actividades, escenarios, tests, preguntas y feedback): "),
            ext_link(cc_by_url, rel = "license", tr("Creative Commons Attribution 4.0 International (CC BY 4.0)", "Creative Commons Reconocimiento 4.0 Internacional (CC BY 4.0)")), "."),
    tags$li(tags$strong("Software"), ": ", ext_link(paste0(repo_url, "/blob/main/LICENSE"), tr("MIT License", "licencia MIT")),
            tr(", source code on ", ", código fuente en "), ext_link(repo_url, "GitHub"), "."),
    tags$li(tags$strong(tr("Simulated data", "Datos simulados")), tr(": written for teaching; it does not represent real people.", ": escritos para la docencia; no representan a personas reales."))),
  h3(tr("How to cite", "Cómo citar")),
  p(class = "panel-soft", "Sánchez-Núñez, P. (2026). ", tags$em("IxD Lab: An AI-Powered Learning and Experimentation Environment for Interaction Design"),
    tr(" (Version 0.2.0) [Software and open educational resource]. Zenodo. ", " (Versión 0.2.0) [Software y recurso educativo abierto]. Zenodo. "), ext_link("https://doi.org/10.5281/zenodo.23863524", "https://doi.org/10.5281/zenodo.23863524")),
  h3(tr("Author", "Autor")),
  p("Pablo Sánchez-Núñez · ORCID ", ext_link(orcid_url, rel = "me", "0000-0001-7845-9506"), " · ", ext_link(site_url, "pablosancheznunez.com"))
)

footer <- tags$footer(class = "site-footer",
  div(class = "container d-flex flex-wrap justify-content-between gap-3 footnote",
    span(sprintf(tr("IxD Lab %s · © 2026 Pablo Sánchez-Núñez · Open educational resource. Content ", "IxD Lab %s · © 2026 Pablo Sánchez-Núñez · Recurso educativo abierto. Contenido "), version),
         ext_link(cc_by_url, rel = "license", "CC BY 4.0"),
         tr(", code MIT. IxD Lab collects no personal data.", ", código MIT. IxD Lab no recoge datos personales.")),
    span(ext_link(site_url, "pablosancheznunez.com"), " · ", ext_link(orcid_url, "ORCID"), " · ", ext_link(repo_url, "GitHub"))))

labs_menu <- do.call(nav_menu, c(list(title = tr("Labs", "Labs"), value = "labs_menu"),
  unlist(lapply(names(modules), function(m) c(list(modules[[m]]$title),
    lapply(names(labs)[vapply(labs, `[[`, "", "module") == m], function(id) nav_panel(paste(labs[[id]]$number, labs[[id]]$short), value = id, lab_page(id))),
    if (m != tail(names(modules), 1)) list("----"))), recursive = FALSE)))

ui <- page_navbar(
  title = span(span(class = "brand-mark", "IxD"), " Lab"),
  id = "main_nav",
  fillable = FALSE,
  lang = LANG,
  window_title = tr("IxD Lab · Interaction design studio", "IxD Lab · Estudio de diseño de interacción"),
  theme = bs_theme(version = 5, bg = "#f6f4ef", fg = "#202522", primary = "#276b5b", secondary = "#d4a15e", base_font = "system-ui", heading_font = "Georgia"),
  header = tagList(
    tags$head(
      tags$meta(name = "description", content = tr(sprintf("IxD Lab: an AI-powered learning and experimentation environment for interaction design and UX. %d hands-on labs. Open educational resource.", n_labs),
                                                    sprintf("IxD Lab: un entorno de aprendizaje y experimentación con IA para el diseño de interacción y la UX. %d labs prácticos. Recurso educativo abierto.", n_labs))),
      tags$meta(name = "author", content = "Pablo Sánchez-Núñez"),
      tags$link(rel = "license", href = cc_by_url),
      tags$link(rel = "author", href = orcid_url)),
    tags$a(class = "skip-link", href = "#main", tr("Skip to content", "Saltar al contenido")),
    tags$link(rel = "stylesheet", href = "styles.css"),
    tags$script(src = "ai.js"),
    tags$script(src = "labs.js"),
    ai_settings_modal(),
    tags$script(HTML(sprintf("document.documentElement.lang = '%s';", LANG))),
    tags$script(HTML("document.addEventListener('shiny:inputchanged', function(e){ if (e.name === 'main_nav') { window.scrollTo(0, 0); var m = document.getElementById('main'); if (m) m.focus({preventScroll: true}); } });"))),
  nav_panel(tr("Home", "Inicio"), value = "home", home_page),
  labs_menu,
  nav_panel(tr("Glossary", "Glosario"), value = "glossary", glossary_page),
  nav_panel(tr("About", "Sobre IxD Lab"), value = "about", about_page),
  nav_spacer(),
  nav_item(ai_switch),
  nav_item(lang_switch),
  footer = footer
)

# The page content gets an id so the skip link and tab changes can move focus to it.
ui <- tagAppendAttributes(ui, .cssSelector = ".tab-content", id = "main", tabindex = "-1")

server <- function(input, output, session) {
  observeEvent(input$goto, nav_select("main_nav", input$goto))
  results <- lapply(labs, function(lab) lab$server(lab$ns))

  for (id in names(labs)) local({
    lab_id <- id
    output[[paste0("status_", lab_id)]] <- renderUI({
      r <- results[[lab_id]]; q <- r$quiz()
      tagList(if (r$started()) span(class = "chip", tr("✓ Notes", "✓ Notas")),
              if (!is.na(q)) span(class = "chip chip-quiz", sprintf(tr("Quiz %d/%d", "Test %d/%d"), q, r$quiz_total)))
    })
  })
  done <- reactive(sum(vapply(results, function(r) r$started() || !is.na(r$quiz()), TRUE)))
  output$progress <- renderUI(span(class = "muted", sprintf(tr("%d of %d labs started (notes or quiz)", "%d de %d labs empezados (notas o test)"), done(), n_labs)))
  output$progress_bar <- renderUI(div(class = "meter mt-3", role = "progressbar", `aria-valuenow` = done(), `aria-valuemin` = 0, `aria-valuemax` = n_labs,
                                      `aria-label` = tr("Labs started", "Labs empezados"), div(class = "meter-fill", style = sprintf("width:%.0f%%", 100 * done() / n_labs))))

  output$glossary_list <- renderUI({
    q <- tolower(trimws(input$glossary_search %||% ""))
    items <- Filter(function(g) !nzchar(q) || grepl(q, tolower(paste(g[[1]], g[[2]])), fixed = TRUE), glossary)
    items <- items[order(vapply(items, function(g) tolower(g[[1]]), ""))]
    if (!length(items)) return(p(class = "muted", tr("No terms match your search.", "Ningún término coincide con tu búsqueda.")))
    tags$dl(class = "glossary", lapply(items, function(g) tagList(
      tags$dt(g[[1]]),
      tags$dd(g[[2]], " ", goto_link(g[[3]], class = "footnote", sprintf(tr("Practise in lab %s →", "Practica en el lab %s →"), labs[[g[[3]]]]$number))))))
  })

  # One file with every lab's summary, quiz and reflection: a learning portfolio to keep or submit.
  output$portfolio <- downloadHandler(
    filename = function() "ixd-lab-portfolio.txt",
    content = function(file) {
      body <- unlist(lapply(names(labs), function(id) c(
        paste0("## ", labs[[id]]$number, " · ", labs[[id]]$title), "", results[[id]]$lines(), "")))
      writeLines(enc2utf8(c(tr("IxD Lab · Learning portfolio", "IxD Lab · Portafolio de aprendizaje"), format(Sys.Date()), "",
                            "https://pablosancheznunez.com/ixd-lab/", "", body)), file, useBytes = TRUE)
    })
}

shinyApp(ui, server)
