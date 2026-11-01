library(shiny)
library(bslib)

source("R/helpers.R")
source("R/labs/mod_wireframing.R")
source("R/labs/mod_information_architecture.R")
source("R/labs/mod_usability.R")
source("R/labs/mod_accessibility.R")
source("R/labs/mod_interaction_patterns.R")
source("R/labs/mod_user_behaviour.R")

site_url <- "https://pablosancheznunez.com"
repo_url <- "https://github.com/pablosancheznunez/ixd-lab"
orcid_url <- "https://orcid.org/0000-0001-7845-9506"
cc_by_url <- "https://creativecommons.org/licenses/by/4.0/"

ext_link <- function(href, ...) tags$a(href = href, target = "_blank", rel = "noopener", ...)

labs <- list(
  wireframing = list(title = "Wireframing", number = "01", desc = "Build a low-fidelity page, test it at three widths, and check its hierarchy.", ui = wireframing_ui, server = wireframing_server, ns = "wire"),
  information_architecture = list(title = "Information architecture", number = "02", desc = "Sort content into categories and compare your structure with a reference.", ui = information_architecture_ui, server = information_architecture_server, ns = "ia"),
  usability = list(title = "Usability", number = "03", desc = "Inspect three interfaces with heuristics and rate the severity of each issue.", ui = usability_ui, server = usability_server, ns = "use"),
  accessibility = list(title = "Accessibility", number = "04", desc = "Check colour contrast, find a passing colour, and spot common barriers.", ui = accessibility_ui, server = accessibility_server, ns = "access"),
  interaction_patterns = list(title = "Interaction patterns", number = "05", desc = "Try feedback, undo and validation patterns, then choose the right one.", ui = interaction_patterns_ui, server = interaction_patterns_server, ns = "patterns"),
  user_behaviour = list(title = "User behaviour", number = "06", desc = "Read a simulated navigation trace and separate observations from explanations.", ui = user_behaviour_ui, server = user_behaviour_server, ns = "behaviour")
)

goto_link <- function(target, ..., class = NULL) {
  tags$a(href = "#", class = class, onclick = js_event("goto", sprintf("'%s'", target)), ...)
}

lab_page <- function(id) {
  lab <- labs[[id]]
  i <- match(id, names(labs))
  prev_id <- if (i > 1) names(labs)[i - 1]
  next_id <- if (i < length(labs)) names(labs)[i + 1]
  div(class = "container pb-4",
    div(class = "lab-head",
      span(class = "eyebrow", paste("LAB", lab$number, "of 06")),
      h1(lab$title),
      p(class = "muted mb-0", lab$desc)),
    lab$ui(lab$ns),
    div(class = "lab-pager",
      if (is.null(prev_id)) goto_link("home", "← All labs") else goto_link(prev_id, paste("←", labs[[prev_id]]$title)),
      if (is.null(next_id)) goto_link("about", "About the project →") else goto_link(next_id, paste(labs[[next_id]]$title, "→"))))
}

home_page <- div(class = "container",
  div(class = "hero",
    span(class = "eyebrow", "AN AI-POWERED LEARNING AND EXPERIMENTATION ENVIRONMENT FOR INTERACTION DESIGN"),
    h1("Learn by making, testing, and reflecting."),
    p(class = "lead-text", "IxD Lab is a studio for exploring how people interact with digital systems. Try a small experiment, compare design choices, and make your reasoning visible."),
    div(class = "hero-actions",
      goto_link("wireframing", "Start with lab 01", class = "btn btn-primary btn-lg"),
      span(class = "muted", "Six labs · about 15 minutes each · no account needed"))),
  h2(class = "section-title", "How every lab works"),
  div(class = "steps",
    div(class = "step", span(class = "eyebrow", "01 · LEARN"), h3("A key idea"), p(class = "muted", "Short objectives and one concept to keep in mind.")),
    div(class = "step", span(class = "eyebrow", "02 · EXPERIMENT"), h3("A hands-on task"), p(class = "muted", "Build, sort, inspect, or compare, with formative feedback as you go.")),
    div(class = "step", span(class = "eyebrow", "03 · REFLECT"), h3("Your reasoning"), p(class = "muted", "Write notes and download them with a summary of your experiment."))),
  h2(class = "section-title", "The labs"),
  div(class = "lab-grid",
    lapply(names(labs), function(id) {
      lab <- labs[[id]]
      goto_link(id, class = "lab-card",
        span(class = "lab-num", paste("LAB", lab$number)), h3(lab$title), p(lab$desc), span(class = "go", "Open lab →"))
    })),
  div(class = "teacher-box",
    span(class = "eyebrow", "FOR TEACHERS"),
    h2(class = "section-title mt-2", "Use it in class"),
    layout_columns(col_widths = c(6, 6),
      p("Each lab works as a 15-minute studio activity. Ask learners to keep three columns in their notes: what I changed, what I expected, and what I would need to test. Learners can download their notes at the end of each lab to share or submit."),
      p("Feedback in the labs is formative, not a grade. Nothing learners write leaves their browser in this version. AI-supported feedback and an opt-in research mode are in development; see the ", tags$a(href = paste0(repo_url, "/blob/main/ROADMAP.md"), target = "_blank", "roadmap"), ".")))
)

about_page <- div(class = "container hero",
  span(class = "eyebrow", "ABOUT THE PROJECT"),
  h1("A studio for thoughtful interaction."),
  p(class = "lead-text", "IxD Lab is an open educational resource for university teaching and independent study. It offers six hands-on labs. Activities are formative and illustrative, not validated assessment instruments."),
  h3("Learn · Experiment · Research"),
  p("Learn introduces concepts and guided questions. Experiment offers small, interactive design tasks. Research is an opt-in mode in development: with informed consent, it will record anonymised interaction data to study how people learn interaction design. This version does not store participant data yet and reports no empirical findings."),
  h3("AI and evidence"),
  p("AI-supported activities are in development: formative feedback on learner work and generated scenarios to experiment with. AI output will always be labelled, and learner text will only be sent to an AI provider when this is explained beforehand. Any research with people will require their informed consent and follow the GDPR."),
  h3("Privacy in this version"),
  p("The app runs entirely in your browser. There are no accounts, cookies, analytics, or AI calls, and your notes disappear when you close the page unless you download them."),
  h3("Open educational resource"),
  p("IxD Lab is an open educational resource (OER): you may keep, reuse, adapt, remix, and share it, in your own courses or for self-study, with attribution."),
  tags$ul(
    tags$li(tags$strong("Educational content"), " (objectives, key ideas, activities, scenarios, prompts, and feedback): ", ext_link(cc_by_url, rel = "license", "Creative Commons Attribution 4.0 International (CC BY 4.0)"), "."),
    tags$li(tags$strong("Software"), ": ", ext_link(paste0(repo_url, "/blob/main/LICENSE"), "MIT License"), ", source code on ", ext_link(repo_url, "GitHub"), "."),
    tags$li(tags$strong("Simulated data"), ": written for teaching; it does not represent real people.")),
  h3("How to cite"),
  p(class = "panel-soft", "Sánchez-Núñez, P. (2026). ", tags$em("IxD Lab: An AI-Powered Learning and Experimentation Environment for Interaction Design"), " (Version 0.1.0) [Software and open educational resource]. https://pablosancheznunez.com/ixd-lab/"),
  h3("Author"),
  p("Pablo Sánchez-Núñez · ORCID ", ext_link(orcid_url, rel = "me", "0000-0001-7845-9506"), " · ", ext_link(site_url, "pablosancheznunez.com"))
)

footer <- tags$footer(class = "site-footer",
  div(class = "container d-flex flex-wrap justify-content-between gap-3 footnote",
    span("IxD Lab 0.1 · © 2026 Pablo Sánchez-Núñez · Open educational resource. Content ", ext_link(cc_by_url, rel = "license", "CC BY 4.0"), ", code MIT. No personal data are collected in this version."),
    span(ext_link(site_url, "pablosancheznunez.com"), " · ", ext_link(orcid_url, "ORCID"), " · ", ext_link(repo_url, "GitHub"))))

ui <- page_navbar(
  title = span(span(class = "brand-mark", "IxD"), " Lab"),
  id = "main_nav",
  fillable = FALSE,
  lang = "en",
  window_title = "IxD Lab · Interaction design studio",
  theme = bs_theme(version = 5, bg = "#f6f4ef", fg = "#202522", primary = "#276b5b", secondary = "#d4a15e", base_font = "system-ui", heading_font = "Georgia"),
  header = tagList(
    tags$a(class = "skip-link", href = "#main", "Skip to content"),
    tags$head(
      tags$meta(name = "description", content = "IxD Lab: an AI-powered learning and experimentation environment for interaction design. Six hands-on labs. Open educational resource."),
      tags$meta(name = "author", content = "Pablo Sánchez-Núñez"),
      tags$link(rel = "license", href = cc_by_url),
      tags$link(rel = "author", href = orcid_url)),
    tags$link(rel = "stylesheet", href = "styles.css"),
    tags$script(HTML("document.addEventListener('shiny:inputchanged', function(e){ if (e.name === 'main_nav') { window.scrollTo(0, 0); var m = document.getElementById('main'); if (m) m.focus({preventScroll: true}); } });"))),
  nav_panel("Home", value = "home", home_page),
  !!!lapply(names(labs), function(id) nav_panel(labs[[id]]$title, value = id, lab_page(id))),
  nav_panel("About", value = "about", about_page),
  footer = footer
)

# The page content gets an id so the skip link and tab changes can move focus to it.
ui <- tagAppendAttributes(ui, .cssSelector = ".tab-content", id = "main", tabindex = "-1")

server <- function(input, output, session) {
  observeEvent(input$goto, nav_select("main_nav", input$goto))
  for (lab in labs) lab$server(lab$ns)
}

shinyApp(ui, server)
