pattern_quiz <- list(
  list(id = "q1", situation = "Saving a draft of a forum post.", answer = "inline",
       why = "Low risk and easy to repeat: a quiet status message is enough."),
  list(id = "q2", situation = "Permanently deleting a course with 120 enrolled students.", answer = "dialog",
       why = "Severe and irreversible: interrupting with a confirmation that names the consequence is proportionate."),
  list(id = "q3", situation = "Archiving an email from the inbox.", answer = "undo",
       why = "Frequent and reversible: acting at once and offering Undo avoids needless interruptions."),
  list(id = "q4", situation = "Typing a student ID that must have 9 digits.", answer = "validation",
       why = "Telling people about a format problem as they finish the field prevents a failed submit.")
)
pattern_choices <- c("Choose a pattern" = "", "Inline status message" = "inline", "Confirmation dialog" = "dialog",
                     "Act now, offer Undo" = "undo", "Inline validation" = "validation")

interaction_patterns_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c("Notice the feedback that follows an action.", "Compare interrupting and non-interrupting patterns.", "Choose a pattern proportionate to the action's consequence."),
    concept = "Feedback should match the stakes. Interrupting people for every action trains them to click through dialogs; letting them undo is often safer and faster.",
    activity = tagList(
      navset_underline(
        nav_panel("Saving",
          div(class = "pt-3",
            p("Save the same change with two kinds of feedback."),
            layout_columns(col_widths = c(6, 6),
              div(actionButton(ns("inline"), "Save with inline status", class = "btn-primary"), uiOutput(ns("inline_msg"))),
              div(actionButton(ns("dialog"), "Save with a dialog", class = "btn-outline-success"))))),
        nav_panel("Deleting",
          div(class = "pt-3",
            p("Delete files with a confirmation dialog, or delete at once and undo."),
            uiOutput(ns("files")),
            div(class = "d-flex flex-wrap gap-2 mt-2",
              actionButton(ns("del_confirm"), "Delete last file · confirm first", class = "btn-outline-secondary"),
              actionButton(ns("del_undo"), "Delete last file · offer Undo", class = "btn-outline-secondary"),
              actionButton(ns("restore"), "Restore all files", class = "btn-link")))),
        nav_panel("Validating",
          div(class = "pt-3",
            p("Enter a 9-digit student ID. Compare feedback while typing with feedback after submitting."),
            radioButtons(ns("validation_mode"), NULL, c("Validate as I type" = "live", "Validate on submit" = "submit"), inline = TRUE),
            textInput(ns("student_id"), "Student ID", placeholder = "e.g. 100123456"),
            actionButton(ns("submit_id"), "Submit", class = "btn-primary"),
            uiOutput(ns("validation_msg"))))),
      hr(),
      h4("Choose the right pattern"),
      lapply(pattern_quiz, function(q) div(class = "panel-soft mb-2", layout_columns(col_widths = c(7, 5),
        p(class = "mb-0 mt-1", q$situation), selectInput(ns(q$id), NULL, pattern_choices, width = "100%")))),
      actionButton(ns("check"), "Check my choices", class = "btn-primary"),
      uiOutput(ns("quiz_feedback")),
      p(class = "footnote mt-3", "These controls demonstrate interface patterns locally; nothing is saved or deleted.")),
    reflection = "When would a confirmation dialog interrupt more than it helps? When is Undo not enough?")
}

interaction_patterns_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    observeEvent(input$inline, output$inline_msg <- renderUI(
      div(class = "alert alert-success mt-3 mb-0 py-2", role = "status", paste("Saved ·", format(Sys.time(), "%H:%M:%S")))))
    observeEvent(input$dialog, showModal(modalDialog(title = "Changes saved", "Your change has been saved.", easyClose = TRUE, footer = modalButton("OK"))))

    all_files <- c("brief.pdf", "persona-maria.png", "journey-map.fig", "interview-notes.docx", "sketches.zip")
    files <- reactiveVal(all_files)
    last_deleted <- reactiveVal(NULL)
    output$files <- renderUI({
      if (!length(files())) return(p(class = "muted", "No files left."))
      tags$ul(class = "check-list", lapply(files(), tags$li))
    })
    observeEvent(input$del_confirm, {
      req(length(files()))
      showModal(modalDialog(title = "Delete file?", sprintf("%s will be permanently deleted.", tail(files(), 1)),
        footer = tagList(modalButton("Cancel"), actionButton(ns("confirm_delete"), "Delete", class = "btn-danger"))))
    })
    observeEvent(input$confirm_delete, { files(head(files(), -1)); removeModal() })
    observeEvent(input$del_undo, {
      req(length(files()))
      last_deleted(tail(files(), 1)); files(head(files(), -1))
      showNotification(tagList(sprintf("%s deleted. ", last_deleted()), actionLink(ns("undo"), "Undo")), duration = 6, id = ns("undo_note"))
    })
    observeEvent(input$undo, {
      req(last_deleted())
      files(c(files(), last_deleted())); last_deleted(NULL)
      removeNotification(ns("undo_note"))
    })
    observeEvent(input$restore, files(all_files))

    submitted <- reactiveVal(FALSE)
    observeEvent(input$submit_id, submitted(TRUE))
    observeEvent(list(input$validation_mode, input$student_id), if (input$validation_mode == "submit") submitted(FALSE), ignoreInit = TRUE)
    output$validation_msg <- renderUI({
      value <- trimws(input$student_id %||% "")
      show <- if (input$validation_mode == "live") nzchar(value) else submitted()
      req(show)
      if (grepl("^[0-9]{9}$", value)) div(class = "alert alert-success mt-3 py-2", role = "status", "Looks right: 9 digits.")
      else div(class = "alert alert-warning mt-3 py-2", role = "alert", sprintf("A student ID has 9 digits; you have entered %d characters.", nchar(value)))
    })

    checked <- reactiveVal(FALSE)
    observeEvent(input$check, checked(TRUE))
    output$quiz_feedback <- renderUI({
      req(checked())
      right <- vapply(pattern_quiz, function(q) identical(input[[q$id]], q$answer), TRUE)
      div(class = "mt-3",
        div(class = if (all(right)) "alert alert-success" else "alert alert-info", sprintf("%d of %d match the suggested pattern.", sum(right), length(right))),
        tags$ul(class = "check-list", lapply(seq_along(pattern_quiz), function(i) tags$li(class = if (right[i]) "ok" else "todo", pattern_quiz[[i]]$why))))
    })

    output$export_notes <- notes_handler("Interaction patterns", input, function() {
      vapply(pattern_quiz, function(q) {
        chosen <- names(pattern_choices)[pattern_choices == (input[[q$id]] %||% "")]
        paste0(q$situation, " → ", if (length(chosen) && nzchar(input[[q$id]])) chosen else "(not answered)")
      }, "")
    })
  })
}
