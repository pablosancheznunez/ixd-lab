`%||%` <- function(x, y) if (is.null(x)) y else x

# Interface language: "en" by default; publish.R adds a lang.txt with "es" to build the Spanish site.
LANG <- if (file.exists("lang.txt")) trimws(readLines("lang.txt", warn = FALSE)[1]) else "en"
tr <- function(en, es) if (identical(LANG, "es")) es else en

site_url <- "https://pablosancheznunez.com"
app_url <- c(en = "https://pablosancheznunez.com/ixd-lab/", es = "https://pablosancheznunez.com/ixd-lab/es/")

# Shared Learn / Experiment / Reflect layout used by every lab.
lab_section <- function(ns, objectives, concept, activity, reflection) {
  tagList(
    div(class = "experiment mb-4",
      span(class = "eyebrow", tr("LEARN", "APRENDE")),
      layout_columns(col_widths = c(6, 6),
        div(h3(tr("What you will practise", "Qué vas a practicar")), tags$ul(lapply(objectives, tags$li))),
        div(class = "concept", h3(tr("Key idea", "Idea clave")), p(concept)))),
    div(class = "experiment mb-4", span(class = "eyebrow", tr("EXPERIMENT", "EXPERIMENTA")), activity),
    div(class = "experiment",
      span(class = "eyebrow", tr("REFLECT", "REFLEXIONA")),
      h3(reflection),
      textAreaInput(ns("reflection"), tr("Your notes (kept only in this browser session)", "Tus notas (solo se guardan en esta sesión del navegador)"),
                    rows = 4, width = "100%",
                    placeholder = tr("What I changed · What I expected · What I would need to test", "Qué cambié · Qué esperaba · Qué necesitaría comprobar")),
      downloadButton(ns("export_notes"), tr("Download my notes", "Descargar mis notas"), class = "btn-outline-success"))
  )
}

# Text export of a lab's experiment summary plus the learner's reflection.
notes_handler <- function(lab, input, summary = function() character()) {
  downloadHandler(
    filename = function() paste0("ixd-lab-", gsub("[^a-z]+", "-", tolower(iconv(lab, to = "ASCII//TRANSLIT"))), "-notes.txt"),
    content = function(file) {
      reflection <- trimws(input$reflection %||% "")
      writeLines(enc2utf8(c(paste("IxD Lab ·", lab), format(Sys.Date()), "", tr("EXPERIMENT", "EXPERIMENTO"), summary(), "",
                            tr("REFLECTION", "REFLEXIÓN"), if (nzchar(reflection)) reflection else tr("(empty)", "(vacío)"))), file, useBytes = TRUE)
    })
}

# Sends an event-priority input value from a client-side click.
js_event <- function(input_id, value) {
  sprintf("Shiny.setInputValue('%s', %s, {priority: 'event'}); return false;", input_id, value)
}
