heuristics <- c("Visibility of system status", "Match between system and the real world", "User control and freedom",
                "Consistency and standards", "Error prevention", "Recognition rather than recall",
                "Flexibility and efficiency of use", "Aesthetic and minimalist design",
                "Help users recognise, diagnose, and recover from errors", "Help and documentation")

severity_levels <- c("0 · Not a problem" = 0, "1 · Cosmetic" = 1, "2 · Minor" = 2, "3 · Major" = 3, "4 · Catastrophe" = 4)

usability_scenarios <- list(
  booking = list(
    title = "Room booking form",
    what = "After pressing Book, the form clears itself. No message appears and no email arrives for several minutes.",
    likely = c("Visibility of system status", "Help users recognise, diagnose, and recover from errors"),
    mock = function() div(class = "mock", div(class = "mock-bar", "library.example / book-a-room"),
      tags$label("Room"), div(class = "form-control mb-2", "Group study room 3"),
      tags$label("Date"), div(class = "form-control mb-3", "12/03"),
      span(class = "btn btn-secondary btn-sm", "Book"))),
  search = list(
    title = "Course search",
    what = "Searching for 'design' returns: 'Query yielded 0 entities (ERR_IDX_204)'. There are no suggestions or links.",
    likely = c("Match between system and the real world", "Help users recognise, diagnose, and recover from errors"),
    mock = function() div(class = "mock", div(class = "mock-bar", "university.example / courses"),
      div(class = "form-control mb-2", "design"),
      div(class = "alert alert-secondary py-2 mb-0 footnote", "Query yielded 0 entities (ERR_IDX_204)"))),
  password = list(
    title = "Password reset",
    what = "One rule is broken, so every field is cleared. The rules only appear after the error, in grey 11px text.",
    likely = c("Error prevention", "User control and freedom", "Recognition rather than recall"),
    mock = function() div(class = "mock", div(class = "mock-bar", "account.example / reset"),
      tags$label("New password"), div(class = "form-control mb-2", HTML("&nbsp;")),
      tags$label("Repeat password"), div(class = "form-control mb-2", HTML("&nbsp;")),
      p(style = "font-size:11px;color:#9a9a9a", "Password must include 12 characters, one symbol and no repeated letters."),
      span(class = "btn btn-secondary btn-sm", "Save")))
)

usability_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c("Inspect an interface against a usability heuristic.", "Describe an observable issue rather than a preference.", "Rate severity and suggest a testable change."),
    concept = "A heuristic evaluation is an expert review: it points to likely problems quickly and cheaply, but only testing with real users shows whether people actually struggle.",
    activity = tagList(
      layout_columns(col_widths = c(6, 6),
        div(
          radioButtons(ns("scenario"), "Interface to review", setNames(names(usability_scenarios), vapply(usability_scenarios, `[[`, "", "title"))),
          uiOutput(ns("mock")),
          uiOutput(ns("what"))),
        div(
          selectInput(ns("heuristic"), "Heuristic", heuristics),
          selectInput(ns("severity"), "Severity", severity_levels, selected = 2),
          textAreaInput(ns("issue"), "Issue: what happens and who it affects", rows = 3, width = "100%"),
          textAreaInput(ns("fix"), "Recommendation: a change you could test", rows = 2, width = "100%"),
          actionButton(ns("add"), "Add finding", class = "btn-primary"),
          uiOutput(ns("feedback")))),
      h4(class = "mt-4", "Findings"),
      tableOutput(ns("findings")),
      downloadButton(ns("export"), "Export findings report", class = "btn-outline-success"))
    ,
    reflection = "Which part of your findings is evidence from the interface, and which part is your interpretation?")
}

usability_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    findings <- reactiveVal(data.frame(Interface = character(), Heuristic = character(), Severity = integer(), Issue = character(), Recommendation = character()))
    feedback <- reactiveVal(NULL)

    output$mock <- renderUI(usability_scenarios[[input$scenario]]$mock())
    output$what <- renderUI(p(class = "footnote mt-2", tags$strong("What happens: "), usability_scenarios[[input$scenario]]$what))

    observeEvent(input$add, {
      issue <- trimws(input$issue); fix <- trimws(input$fix)
      if (nchar(issue) < 20 || nchar(fix) < 10) {
        return(feedback(div(class = "alert alert-warning mt-3", "Add a little more detail: describe the moment, its effect on the person, and one change.")))
      }
      sc <- usability_scenarios[[input$scenario]]
      findings(rbind(findings(), data.frame(Interface = sc$title, Heuristic = input$heuristic, Severity = as.integer(input$severity), Issue = issue, Recommendation = fix)))
      updateTextAreaInput(session, "issue", value = ""); updateTextAreaInput(session, "fix", value = "")
      feedback(if (input$heuristic %in% sc$likely) {
        div(class = "alert alert-success mt-3", tags$strong("Finding added. "), "Reviewers often link this interface to ", tolower(input$heuristic), " too.")
      } else {
        div(class = "alert alert-info mt-3", tags$strong("Finding added. "), "Reviewers often link this interface to ", paste(tolower(sc$likely), collapse = " or "),
            ". Your choice can still be valid: does your note explain the connection?")
      })
    })
    output$feedback <- renderUI(feedback())

    output$findings <- renderTable({
      x <- findings()
      if (!nrow(x)) return(data.frame(` ` = "No findings yet.", check.names = FALSE))
      x[order(-x$Severity), ]
    }, striped = TRUE, width = "100%")

    report <- function() {
      x <- findings()
      if (!nrow(x)) return("(no findings)")
      x <- x[order(-x$Severity), ]
      unlist(lapply(seq_len(nrow(x)), function(i) c(sprintf("%d. [Severity %d] %s · %s", i, x$Severity[i], x$Interface[i], x$Heuristic[i]),
                                                    paste("   Issue:", x$Issue[i]), paste("   Recommendation:", x$Recommendation[i]))))
    }
    output$export <- downloadHandler(filename = function() "ixd-usability-findings.txt",
      content = function(file) writeLines(enc2utf8(c("IxD Lab · Heuristic evaluation findings", format(Sys.Date()), "", report())), file, useBytes = TRUE))
    output$export_notes <- notes_handler("Usability", input, report)
  })
}
