library(shiny)
library(bslib)

source("R/helpers.R")
source("R/labs/mod_wireframing.R")
source("R/labs/mod_information_architecture.R")
source("R/labs/mod_usability.R")
source("R/labs/mod_accessibility.R")
source("R/labs/mod_interaction_patterns.R")
source("R/labs/mod_user_behaviour.R")

repo_url <- "https://github.com/pablosancheznunez/ixd-lab"
orcid_url <- "https://orcid.org/0000-0001-7845-9506"
cc_by_url <- tr("https://creativecommons.org/licenses/by/4.0/", "https://creativecommons.org/licenses/by/4.0/deed.es")

ext_link <- function(href, ...) tags$a(href = href, target = "_blank", rel = "noopener", ...)

labs <- list(
  wireframing = list(title = tr("Wireframing", "Wireframing"), number = "01",
    desc = tr("Build a low-fidelity page, test it at three widths, and check its hierarchy.", "Construye una página de baja fidelidad, pruébala en tres anchos y revisa su jerarquía."),
    ui = wireframing_ui, server = wireframing_server, ns = "wire"),
  information_architecture = list(title = tr("Information architecture", "Arquitectura de la información"), short = tr("Information architecture", "Arquitectura"), number = "02",
    desc = tr("Sort content into categories and compare your structure with a reference.", "Ordena contenidos en categorías y compara tu estructura con una de referencia."),
    ui = information_architecture_ui, server = information_architecture_server, ns = "ia"),
  usability = list(title = tr("Usability", "Usabilidad"), number = "03",
    desc = tr("Inspect three interfaces with heuristics and rate the severity of each issue.", "Inspecciona tres interfaces con heurísticas y valora la gravedad de cada problema."),
    ui = usability_ui, server = usability_server, ns = "use"),
  accessibility = list(title = tr("Accessibility", "Accesibilidad"), number = "04",
    desc = tr("Check colour contrast, find a passing colour, and spot common barriers.", "Comprueba el contraste de color, encuentra un color válido y detecta barreras habituales."),
    ui = accessibility_ui, server = accessibility_server, ns = "access"),
  interaction_patterns = list(title = tr("Interaction patterns", "Patrones de interacción"), short = tr("Interaction patterns", "Patrones"), number = "05",
    desc = tr("Try feedback, undo and validation patterns, then choose the right one.", "Prueba patrones de feedback, deshacer y validación, y elige el adecuado."),
    ui = interaction_patterns_ui, server = interaction_patterns_server, ns = "patterns"),
  user_behaviour = list(title = tr("User behaviour", "Comportamiento del usuario"), short = tr("User behaviour", "Comportamiento"), number = "06",
    desc = tr("Read a simulated navigation trace and separate observations from explanations.", "Lee un recorrido de navegación simulado y separa observaciones de explicaciones."),
    ui = user_behaviour_ui, server = user_behaviour_server, ns = "behaviour")
)

goto_link <- function(target, ..., class = NULL) {
  tags$a(href = "#", class = class, onclick = js_event("goto", sprintf("'%s'", target)), ...)
}

# Link to the same app in the other language; target _top leaves the Shinylive frame.
ai_switch <- tags$a(class = "nav-link ai-switch", href = "#", `data-bs-toggle` = "modal", `data-bs-target` = "#ai-settings",
  title = tr("AI feedback settings", "Ajustes del feedback con IA"),
  span(class = "ai-dot", `aria-hidden` = "true"), tr("✦ AI", "✦ IA"))

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
  next_id <- if (i < length(labs)) names(labs)[i + 1]
  div(class = "container pb-4",
    div(class = "lab-head",
      span(class = "eyebrow", paste(tr("LAB", "LAB"), lab$number, tr("of 06", "de 06"))),
      h1(lab$title),
      p(class = "muted mb-0", lab$desc)),
    lab$ui(lab$ns),
    div(class = "lab-pager",
      if (is.null(prev_id)) goto_link("home", tr("← All labs", "← Todos los labs")) else goto_link(prev_id, paste("←", labs[[prev_id]]$title)),
      if (is.null(next_id)) goto_link("about", tr("About the project →", "Sobre el proyecto →")) else goto_link(next_id, paste(labs[[next_id]]$title, "→"))))
}

home_page <- div(class = "container",
  div(class = "hero",
    span(class = "eyebrow", tr("AN AI-POWERED LEARNING AND EXPERIMENTATION ENVIRONMENT FOR INTERACTION DESIGN",
                               "UN ENTORNO DE APRENDIZAJE Y EXPERIMENTACIÓN CON IA PARA EL DISEÑO DE INTERACCIÓN")),
    h1(tr("Learn by making, testing, and reflecting.", "Aprende haciendo, probando y reflexionando.")),
    p(class = "lead-text", tr("IxD Lab is a studio for exploring how people interact with digital systems. Try a small experiment, compare design choices, and make your reasoning visible.",
                              "IxD Lab es un estudio para explorar cómo interactúan las personas con los sistemas digitales. Haz un pequeño experimento, compara decisiones de diseño y haz visible tu razonamiento.")),
    div(class = "hero-actions",
      goto_link("wireframing", tr("Start with lab 01", "Empieza por el lab 01"), class = "btn btn-primary btn-lg"),
      span(class = "muted", tr("Six labs · about 15 minutes each · no account needed", "Seis labs · unos 15 minutos cada uno · sin registro")))),
  h2(class = "section-title", tr("How every lab works", "Cómo funciona cada lab")),
  div(class = "steps",
    div(class = "step", span(class = "eyebrow", tr("01 · LEARN", "01 · APRENDE")), h3(tr("A key idea", "Una idea clave")),
        p(class = "muted", tr("Short objectives and one concept to keep in mind.", "Objetivos breves y un concepto que tener presente."))),
    div(class = "step", span(class = "eyebrow", tr("02 · EXPERIMENT", "02 · EXPERIMENTA")), h3(tr("A hands-on task", "Una tarea práctica")),
        p(class = "muted", tr("Build, sort, inspect, or compare, with formative feedback as you go.", "Construye, ordena, inspecciona o compara, con feedback formativo sobre la marcha."))),
    div(class = "step", span(class = "eyebrow", tr("03 · REFLECT", "03 · REFLEXIONA")), h3(tr("Your reasoning", "Tu razonamiento")),
        p(class = "muted", tr("Write notes and download them with a summary of your experiment.", "Escribe notas y descárgalas con un resumen de tu experimento.")))),
  h2(class = "section-title", tr("The labs", "Los labs")),
  div(class = "lab-grid",
    lapply(names(labs), function(id) {
      lab <- labs[[id]]
      goto_link(id, class = "lab-card",
        span(class = "lab-num", paste("LAB", lab$number)), h3(lab$title), p(lab$desc),
        div(class = "d-flex justify-content-between align-items-center", span(class = "go", tr("Open lab →", "Abrir lab →")), uiOutput(paste0("status_", id), inline = TRUE)))
    })),
  div(class = "teacher-box",
    span(class = "eyebrow", tr("FOR TEACHERS", "PARA DOCENTES")),
    h2(class = "section-title mt-2", tr("Use it in class", "Úsalo en clase")),
    layout_columns(col_widths = c(6, 6),
      p(tr("Each lab works as a 15-minute studio activity. Ask learners to keep three columns in their notes: what I changed, what I expected, and what I would need to test. Learners can download their notes at the end of each lab to share or submit.",
           "Cada lab funciona como una actividad de taller de 15 minutos. Pide al alumnado que lleve tres columnas en sus notas: qué cambié, qué esperaba y qué necesitaría comprobar. Al final de cada lab pueden descargar sus notas para compartirlas o entregarlas.")),
      p(tr("Feedback in the labs is formative, not a grade. Optional AI feedback works with your own Anthropic API key (✦ AI in the menu); without it, nothing learners write leaves their browser. An opt-in research mode is in development; see the ",
           "El feedback de los labs es formativo, no una nota. El feedback con IA es opcional y funciona con tu propia clave de API de Anthropic (✦ IA en el menú); sin ella, nada de lo que escribe el alumnado sale de su navegador. Un modo de investigación voluntario está en desarrollo; consulta la "),
        ext_link(paste0(repo_url, "/blob/main/ROADMAP.md"), tr("roadmap", "hoja de ruta")), ".")),
    div(class = "portfolio-row",
      uiOutput("progress", inline = TRUE),
      downloadButton("portfolio", tr("Download all my notes", "Descargar todas mis notas"), class = "btn-outline-success")))
)

about_page <- div(class = "container hero",
  span(class = "eyebrow", tr("ABOUT THE PROJECT", "SOBRE EL PROYECTO")),
  h1(tr("A studio for thoughtful interaction.", "Un estudio para una interacción bien pensada.")),
  p(class = "lead-text", tr("IxD Lab is an open educational resource for university teaching and independent study. It offers six hands-on labs. Activities are formative and illustrative, not validated assessment instruments.",
                            "IxD Lab es un recurso educativo abierto para la docencia universitaria y el aprendizaje autónomo. Ofrece seis labs prácticos. Las actividades son formativas e ilustrativas, no instrumentos de evaluación validados.")),
  h3(tr("Learn · Experiment · Research", "Aprende · Experimenta · Investiga")),
  p(tr("Learn introduces concepts and guided questions. Experiment offers small, interactive design tasks. Research is an opt-in mode in development: with informed consent, it will record anonymised interaction data to study how people learn interaction design. This version does not store participant data yet and reports no empirical findings.",
       "Aprende presenta conceptos y preguntas guiadas. Experimenta ofrece pequeñas tareas interactivas de diseño. Investiga es un modo voluntario en desarrollo: con consentimiento informado, registrará datos de interacción anonimizados para estudiar cómo se aprende diseño de interacción. Esta versión todavía no guarda datos de participantes ni presenta resultados empíricos.")),
  h3(tr("AI and evidence", "IA y evidencia")),
  p(tr("Every lab can ask Claude, an AI model by Anthropic, for formative feedback on the learner's work and reflection. It is optional and uses your own Anthropic API key, which stays in your browser (✦ AI in the menu). AI output is always labelled, and nothing is sent until you ask for feedback. AI-generated scenarios are in development. Any research with people will require their informed consent and follow the GDPR.",
       "Cada lab puede pedir a Claude, un modelo de IA de Anthropic, feedback formativo sobre el trabajo y la reflexión del alumnado. Es opcional y usa tu propia clave de API de Anthropic, que se queda en tu navegador (✦ IA en el menú). Lo que produce la IA siempre está señalado, y no se envía nada hasta que pides feedback. Los escenarios generados con IA están en desarrollo. Cualquier investigación con personas requerirá su consentimiento informado y cumplirá el RGPD.")),
  h3(tr("Privacy in this version", "Privacidad en esta versión")),
  p(tr("The app runs entirely in your browser. There are no accounts, cookies, or analytics, and your notes disappear when you close the page unless you download them. If you turn on AI feedback, the activity summary and your notes for that lab go directly from your browser to Anthropic when you ask for feedback, and nowhere else.",
       "La app funciona por completo en tu navegador. No hay cuentas, cookies ni analítica, y tus notas desaparecen al cerrar la página salvo que las descargues. Si activas el feedback con IA, el resumen de la actividad y tus notas de ese lab van directamente de tu navegador a Anthropic cuando pides feedback, y a ningún otro sitio.")),
  h3(tr("Open educational resource", "Recurso educativo abierto")),
  p(tr("IxD Lab is an open educational resource (OER): you may keep, reuse, adapt, remix, and share it, in your own courses or for self-study, with attribution.",
       "IxD Lab es un recurso educativo abierto (REA): puedes conservarlo, reutilizarlo, adaptarlo, mezclarlo y compartirlo, en tus cursos o para estudiar por tu cuenta, citando la autoría.")),
  tags$ul(
    tags$li(tags$strong(tr("Educational content", "Contenido educativo")),
            tr(" (objectives, key ideas, activities, scenarios, prompts, and feedback): ", " (objetivos, ideas clave, actividades, escenarios, preguntas y feedback): "),
            ext_link(cc_by_url, rel = "license", tr("Creative Commons Attribution 4.0 International (CC BY 4.0)", "Creative Commons Reconocimiento 4.0 Internacional (CC BY 4.0)")), "."),
    tags$li(tags$strong("Software"), ": ", ext_link(paste0(repo_url, "/blob/main/LICENSE"), tr("MIT License", "licencia MIT")),
            tr(", source code on ", ", código fuente en "), ext_link(repo_url, "GitHub"), "."),
    tags$li(tags$strong(tr("Simulated data", "Datos simulados")), tr(": written for teaching; it does not represent real people.", ": escritos para la docencia; no representan a personas reales."))),
  h3(tr("How to cite", "Cómo citar")),
  p(class = "panel-soft", "Sánchez-Núñez, P. (2026). ", tags$em("IxD Lab: An AI-Powered Learning and Experimentation Environment for Interaction Design"),
    tr(" (Version 0.1.0) [Software and open educational resource]. Zenodo. ", " (Versión 0.1.0) [Software y recurso educativo abierto]. Zenodo. "), ext_link("https://doi.org/10.5281/zenodo.23863524", "https://doi.org/10.5281/zenodo.23863524")),
  h3(tr("Author", "Autor")),
  p("Pablo Sánchez-Núñez · ORCID ", ext_link(orcid_url, rel = "me", "0000-0001-7845-9506"), " · ", ext_link(site_url, "pablosancheznunez.com"))
)

footer <- tags$footer(class = "site-footer",
  div(class = "container d-flex flex-wrap justify-content-between gap-3 footnote",
    span(tr("IxD Lab 0.1 · © 2026 Pablo Sánchez-Núñez · Open educational resource. Content ", "IxD Lab 0.1 · © 2026 Pablo Sánchez-Núñez · Recurso educativo abierto. Contenido "),
         ext_link(cc_by_url, rel = "license", "CC BY 4.0"),
         tr(", code MIT. IxD Lab collects no personal data.", ", código MIT. IxD Lab no recoge datos personales.")),
    span(ext_link(site_url, "pablosancheznunez.com"), " · ", ext_link(orcid_url, "ORCID"), " · ", ext_link(repo_url, "GitHub"))))

ui <- page_navbar(
  title = span(span(class = "brand-mark", "IxD"), " Lab"),
  id = "main_nav",
  fillable = FALSE,
  lang = LANG,
  window_title = tr("IxD Lab · Interaction design studio", "IxD Lab · Estudio de diseño de interacción"),
  theme = bs_theme(version = 5, bg = "#f6f4ef", fg = "#202522", primary = "#276b5b", secondary = "#d4a15e", base_font = "system-ui", heading_font = "Georgia"),
  header = tagList(
    tags$head(
      tags$meta(name = "description", content = tr("IxD Lab: an AI-powered learning and experimentation environment for interaction design. Six hands-on labs. Open educational resource.",
                                                    "IxD Lab: un entorno de aprendizaje y experimentación con IA para el diseño de interacción. Seis labs prácticos. Recurso educativo abierto.")),
      tags$meta(name = "author", content = "Pablo Sánchez-Núñez"),
      tags$link(rel = "license", href = cc_by_url),
      tags$link(rel = "author", href = orcid_url)),
    tags$a(class = "skip-link", href = "#main", tr("Skip to content", "Saltar al contenido")),
    tags$link(rel = "stylesheet", href = "styles.css"),
    tags$script(src = "ai.js"),
    ai_settings_modal(),
    tags$script(HTML(sprintf("document.documentElement.lang = '%s';", LANG))),
    tags$script(HTML("document.addEventListener('shiny:inputchanged', function(e){ if (e.name === 'main_nav') { window.scrollTo(0, 0); var m = document.getElementById('main'); if (m) m.focus({preventScroll: true}); } });"))),
  nav_panel(tr("Home", "Inicio"), value = "home", home_page),
  !!!lapply(names(labs), function(id) nav_panel(labs[[id]]$short %||% labs[[id]]$title, value = id, lab_page(id))),
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
    output[[paste0("status_", lab_id)]] <- renderUI(
      if (results[[lab_id]]$started()) span(class = "chip", tr("✓ Notes", "✓ Notas")))
  })
  output$progress <- renderUI({
    done <- sum(vapply(results, function(r) r$started(), TRUE))
    span(class = "muted", sprintf(tr("%d of %d labs with notes", "%d de %d labs con notas"), done, length(results)))
  })

  # One file with every lab's summary and reflection: a learning portfolio to keep or submit.
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
