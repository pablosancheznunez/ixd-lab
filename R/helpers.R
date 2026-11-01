`%||%` <- function(x, y) if (is.null(x)) y else x

# Shared Learn / Experiment / Reflect layout used by every lab.
lab_section <- function(ns, objectives, concept, activity, reflection) {
  tagList(
    div(class = "experiment mb-4",
      span(class = "eyebrow", "LEARN"),
      layout_columns(col_widths = c(6, 6),
        div(h3("What you will practise"), tags$ul(lapply(objectives, tags$li))),
        div(class = "concept", h3("Key idea"), p(concept)))),
    div(class = "experiment mb-4", span(class = "eyebrow", "EXPERIMENT"), activity),
    div(class = "experiment",
      span(class = "eyebrow", "REFLECT"),
      h3(reflection),
      textAreaInput(ns("reflection"), "Your notes (kept only in this browser session)", rows = 4, width = "100%",
                    placeholder = "What I changed · What I expected · What I would need to test"),
      downloadButton(ns("export_notes"), "Download my notes", class = "btn-outline-success"))
  )
}

# Text export of a lab's experiment summary plus the learner's reflection.
notes_handler <- function(lab, input, summary = function() character()) {
  downloadHandler(
    filename = function() paste0("ixd-lab-", gsub("[^a-z]+", "-", tolower(lab)), "-notes.txt"),
    content = function(file) {
      reflection <- trimws(input$reflection %||% "")
      writeLines(enc2utf8(c(paste("IxD Lab ·", lab), format(Sys.Date()), "", "EXPERIMENT", summary(), "",
                            "REFLECTION", if (nzchar(reflection)) reflection else "(empty)")), file, useBytes = TRUE)
    })
}

# Sends an event-priority input value from a client-side click.
js_event <- function(input_id, value) {
  sprintf("Shiny.setInputValue('%s', %s, {priority: 'event'}); return false;", input_id, value)
}
