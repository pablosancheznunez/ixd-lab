library(shiny)
library(bslib)

source("R/helpers.R")
source("R/labs/mod_wireframing.R")
source("R/labs/mod_information_architecture.R")
source("R/labs/mod_usability.R")
source("R/labs/mod_accessibility.R")
source("R/labs/mod_interaction_patterns.R")
source("R/labs/mod_user_behaviour.R")

labs <- list(
  wireframing = list(title = "Wireframing", number = "01", desc = "Build and review a low-fidelity interface.", status = "Operational"),
  information_architecture = list(title = "Information architecture", number = "02", desc = "Organise content and test a navigation structure.", status = "Starter activity"),
  usability = list(title = "Usability", number = "03", desc = "Apply a formative heuristic review.", status = "Starter activity"),
  accessibility = list(title = "Accessibility", number = "04", desc = "Explore text contrast and legibility.", status = "Starter activity"),
  interaction_patterns = list(title = "Interaction patterns", number = "05", desc = "Compare feedback across interface patterns.", status = "Starter activity"),
  user_behaviour = list(title = "User behaviour", number = "06", desc = "Interpret a simulated interaction sequence.", status = "Starter activity")
)

font_link <- tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@500&display=swap")
style_tag <- tags$style(HTML("body{font-family:system-ui,sans-serif}.navbar{border-bottom:1px solid #dedbd2}.brand-mark{font-family:monospace;color:#276b5b;font-weight:500}.hero{padding:4.5rem 0 3.5rem;max-width:850px}.eyebrow,.lab-num{font:500 .75rem monospace;letter-spacing:.1em;text-transform:uppercase;color:#71766f}.hero h1{font:400 clamp(2.8rem,7vw,5.5rem)/.98 Georgia,serif;letter-spacing:-.05em;margin:1.2rem 0}.hero p{font-size:1.15rem;max-width:620px;color:#5c625d}.lab-card{height:100%;padding:1.5rem;background:#fff;border:1px solid #e7e4dc;border-radius:1rem;transition:transform .2s,border-color .2s}.lab-card:hover{transform:translateY(-3px);border-color:#276b5b}.lab-card h3{font:400 1.6rem Georgia,serif;margin:.9rem 0}.lab-card p{color:#666d66;min-height:3rem}.status{font:500 .7rem monospace;color:#276b5b;text-transform:uppercase;letter-spacing:.04em}.lab-head{padding:2rem 0 1.2rem}.lab-head h1{font:400 3rem Georgia,serif}.experiment{background:white;border:1px solid #e7e4dc;padding:1.5rem;border-radius:1rem}.wire-canvas{min-height:390px;background:#eeece6;border:1px dashed #c9c6bd;padding:1rem;border-radius:.6rem}.wire-item{background:white;padding:1rem;margin:.6rem 0;border:1px solid #dedbd2;border-radius:.4rem}.muted{color:#747a73}.footnote{font-size:.82rem;color:#747a73}.btn-primary{--bs-btn-bg:#276b5b;--bs-btn-border-color:#276b5b;--bs-btn-hover-bg:#20594b}.nav-link{font-size:.92rem}"))
lab_panels <- lapply(names(labs), function(id) nav_panel(labs[[id]]$title, value = id, uiOutput(paste0("page_", id))))
ui <- do.call(page_navbar, c(list(title = div(span(class = "brand-mark", "IxD"), " Lab"), id = "main_nav", fillable = FALSE, theme = bs_theme(version = 5, bg = "#f6f4ef", fg = "#202522", primary = "#276b5b", secondary = "#d4a15e", base_font = "system-ui", heading_font = "Georgia"), header = tagList(font_link, style_tag)),
  list(nav_panel("Home", value = "home", uiOutput("page_home"))), lab_panels,
  list(nav_panel("About", value = "about", uiOutput("page_about")), footer = tags$footer(class = "container py-5 footnote", "IxD Lab · Open educational resource · Simulated activities are labelled. No personal data are collected by this prototype."))))

server <- function(input, output, session) {
  for (id in names(labs)) {
    local({ lab_id <- id; output[[paste0("page_", lab_id)]] <- renderUI({
      module <- switch(lab_id,
        wireframing = wireframing_ui("wire"), information_architecture = information_architecture_ui("ia"),
        usability = usability_ui("use"), accessibility = accessibility_ui("access"),
        interaction_patterns = interaction_patterns_ui("patterns"), user_behaviour = user_behaviour_ui("behaviour"))
      tagList(div(class="container lab-head", span(class="eyebrow", paste("LAB", labs[[lab_id]]$number, "·", labs[[lab_id]]$status)), h1(labs[[lab_id]]$title), p(class="muted", labs[[lab_id]]$desc)), div(class="container pb-5", module))
    }) })
  }
  output$page_home <- renderUI({
    cards <- lapply(names(labs), function(id) { lab <- labs[[id]]; column(4, div(class="lab-card mb-4", span(class="lab-num", paste(lab$number, " /", lab$status)), h3(lab$title), p(lab$desc), actionLink(paste0("open_", id), "Explore lab →", class="link-success"))) })
    tagList(div(class="container hero", span(class="eyebrow", "AN OPEN LEARNING ENVIRONMENT FOR INTERACTION DESIGN"), h1("Learn by making, testing, and reflecting."), p("IxD Lab is a modular studio for exploring how people interact with digital systems. Try a small experiment, compare choices, and make your reasoning visible."), actionButton("start_lab", "Start exploring", class="btn-primary"), span("  Six connected labs · No account required", class="muted ms-3")), div(class="container pb-5", div(class="row", cards)))
  })
  output$page_about <- renderUI(div(class="container hero", span(class="eyebrow", "ABOUT THE PROJECT"), h1("A studio for thoughtful interaction."), p("IxD Lab is an open educational resource for university teaching and independent study. This first prototype provides one working activity in every lab. Activities are formative and illustrative, not validated instruments."), h3("Learn · Experiment · Research", style="font-family:Georgia"), p("Learn introduces concepts and guided questions. Experiment offers small, interactive design tasks. Research is a future optional mode: this prototype stores no participant data and reports no empirical findings."), h3("AI and evidence", style="font-family:Georgia"), p("No AI provider is required. Any future generated scenario must be clearly labelled as synthetic. Human participant research requires appropriate consent and institutional review.")))
  observeEvent(input$start_lab, updateNavbarPage(session, "main_nav", "wireframing"))
  for (id in names(labs)) local({ lab_id <- id; observeEvent(input[[paste0("open_", lab_id)]], updateNavbarPage(session, "main_nav", lab_id), ignoreInit=TRUE) })
  wireframing_server("wire"); information_architecture_server("ia"); usability_server("use"); accessibility_server("access"); interaction_patterns_server("patterns"); user_behaviour_server("behaviour")
}
shinyApp(ui, server)
