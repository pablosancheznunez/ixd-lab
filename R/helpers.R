`%||%` <- function(x, y) if (is.null(x)) y else x
lab_section <- function(objectives, activity, reflection) {
  tagList(div(class="experiment mb-4", span(class="eyebrow", "LEARN"), h3("What you will practise", style="font-family:Georgia"), tags$ul(lapply(objectives, tags$li))),
          div(class="experiment", span(class="eyebrow", "EXPERIMENT"), activity,
              div(class="mt-4 pt-3 border-top", span(class="eyebrow", "REFLECT"), p(class="muted mb-0", reflection))))
}
download_text <- function(text, filename) {
  downloadHandler(filename = function() filename, content = function(file) writeLines(text, file, useBytes = TRUE))
}
