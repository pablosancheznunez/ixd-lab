behaviour_traces <- list(
  "Course search" = data.frame(
    page = c("Home", "Search", "Results", "Search", "Results", "Course detail"),
    seconds = c(3, 8, 14, 6, 22, 25),
    kind = c("view", "view", "view", "back", "view", "view")),
  "Event registration" = data.frame(
    page = c("Event page", "Registration form", "Help: payment", "Registration form", "Confirmation"),
    seconds = c(4, 11, 17, 31, 3),
    kind = c("view", "view", "help", "view", "view")),
  "Library checkout" = data.frame(
    page = c("Catalogue", "Book detail", "Sign in", "Book detail", "Sign in", "Reserve", "Reserve"),
    seconds = c(9, 12, 20, 5, 28, 15, 4),
    kind = c("view", "view", "view", "back", "view", "view", "view"))
)

methods_choices <- c("Think-aloud usability test", "Short follow-up interview", "Consented, anonymised analytics",
                     "Survey with open questions", "A/B test of a redesigned step")

user_behaviour_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c("Read an interaction sequence.", "Separate observations from explanations.", "Plan how to collect evidence ethically."),
    concept = "A log shows what happened, never why. A long pause could be confusion, careful reading, or a phone call. Explanations become evidence only when you test them with people.",
    activity = tagList(
      div(class = "alert alert-warning", tags$strong("SIMULATED DATA · "), "Illustrative traces written for this exercise; no participants were observed."),
      layout_columns(col_widths = c(4, 8),
        div(
          radioButtons(ns("scenario"), "Scenario", names(behaviour_traces)),
          div(class = "panel-soft", span(class = "eyebrow", "SUMMARY"), uiOutput(ns("summary")))),
        div(
          uiOutput(ns("trace")),
          div(class = "legend mt-2", span(tags$i(style = "background:#276b5b;opacity:.75"), "Page view"),
              span(tags$i(style = "background:#a35b4f"), "Went back"), span(tags$i(style = "background:#d4a15e"), "Opened help")))),
      hr(),
      layout_columns(col_widths = c(6, 6),
        textAreaInput(ns("observation"), "What I observe (only what the trace shows)", rows = 3, width = "100%",
                      placeholder = "e.g. The person returned to Search after 14 seconds on Results."),
        textAreaInput(ns("explanation"), "Possible explanations (at least two)", rows = 3, width = "100%",
                      placeholder = "e.g. The results did not match the query; or the person refined it on purpose.")),
      checkboxGroupInput(ns("methods"), "How would you test your explanations?", methods_choices),
      uiOutput(ns("method_feedback"))),
    reflection = "What alternative explanation could account for the longest pause? What would you need consent for?")
}

user_behaviour_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    trace <- reactive(behaviour_traces[[input$scenario]])

    output$trace <- renderUI({
      x <- trace()
      longest <- max(x$seconds)
      tagList(lapply(seq_len(nrow(x)), function(i) div(class = "trace-row",
        span(paste0(i, ". ", x$page[i])),
        div(class = paste("trace-bar", x$kind[i]), style = sprintf("width:%.0f%%", 100 * x$seconds[i] / longest),
            role = "img", `aria-label` = sprintf("%s, %d seconds", x$page[i], x$seconds[i])),
        span(class = "footnote", paste(x$seconds[i], "s")))))
    })

    output$summary <- renderUI({
      x <- trace()
      tags$ul(class = "check-list footnote",
        tags$li(sprintf("%d steps · %d s in total", nrow(x), sum(x$seconds))),
        tags$li(sprintf("Longest step: %s (%d s)", x$page[which.max(x$seconds)], max(x$seconds))),
        tags$li(sprintf("Went back: %d · Opened help: %d", sum(x$kind == "back"), sum(x$kind == "help"))),
        tags$li("Durations are illustrative, not measured."))
    })

    output$method_feedback <- renderUI({
      m <- input$methods
      req(length(m))
      notes <- c(
        if ("Think-aloud usability test" %in% m) "Think-aloud shows why people pause, but needs informed consent and recording rules.",
        if ("Consented, anonymised analytics" %in% m) "Analytics tell you how often a pattern happens, not why; collect only the fields your question needs.",
        if ("A/B test of a redesigned step" %in% m) "An A/B test compares outcomes, but needs enough participants and a clear success measure.",
        if (length(m) == 1) "Combining a behavioural method with one that asks people directly makes your explanation stronger.")
      div(class = "alert alert-info mt-2", tags$ul(class = "mb-0", lapply(notes, tags$li)))
    })

    output$export_notes <- notes_handler("User behaviour", input, function() c(
      paste("Scenario (simulated):", input$scenario),
      paste("Observation:", trimws(input$observation %||% "")),
      paste("Explanations:", trimws(input$explanation %||% "")),
      paste("Methods:", if (length(input$methods)) paste(input$methods, collapse = "; ") else "(none)")))
  })
}
