contrast_ratio <- function(fg, bg) {
  lum <- function(hex) {
    rgb <- col2rgb(hex) / 255
    rgb <- ifelse(rgb <= .04045, rgb / 12.92, ((rgb + .055) / 1.055)^2.4)
    sum(rgb * c(.2126, .7152, .0722))
  }
  vals <- sort(c(lum(fg), lum(bg)))
  (vals[2] + .05) / (vals[1] + .05)
}

# Closest colour to `fg` (mixing towards black or white) that reaches `target` against `bg`.
passing_colour <- function(fg, bg, target = 4.5) {
  if (contrast_ratio(fg, bg) >= target) return(toupper(fg))
  base <- col2rgb(fg)[, 1]
  for (step in seq(0.05, 1, by = 0.05)) {
    for (towards in list(c(0, 0, 0), c(255, 255, 255))) {
      mixed <- rgb(t(round(base + (towards - base) * step)), maxColorValue = 255)
      if (contrast_ratio(mixed, bg) >= target) return(mixed)
    }
  }
  "#000000"
}

valid_hex <- function(x) grepl("^#[0-9A-Fa-f]{6}$", x %||% "")

colour_presets <- list(
  "Grey on white" = c("#9A9A9A", "#FFFFFF"),
  "White on green" = c("#FFFFFF", "#3FA34D"),
  "Navy on sand" = c("#1D2B53", "#F2E3C6"),
  "Red on black" = c("#D0312D", "#111111")
)

barrier_items <- list(
  list(id = "img", example = "A product photo is announced by a screen reader as \"IMG_2041.jpg\".", answer = "alt",
       why = "Images that carry meaning need a text alternative (WCAG 1.1.1)."),
  list(id = "field", example = "A form field shows the hint \"Email\" inside the box, which disappears as soon as you type.", answer = "label",
       why = "Placeholders are not labels: once they vanish, people must remember what the field was (WCAG 3.3.2)."),
  list(id = "colour", example = "Required fields that were left empty are shown only with a red border.", answer = "colour",
       why = "Colour alone does not reach everyone; add text or an icon (WCAG 1.4.1)."),
  list(id = "focus", example = "Pressing Tab moves through the page, but there is no visible sign of where you are.", answer = "focus",
       why = "Keyboard users need a visible focus indicator (WCAG 2.4.7).")
)
barrier_choices <- c("Choose the barrier" = "", "Missing text alternative" = "alt", "Missing visible label" = "label",
                     "Information conveyed by colour only" = "colour", "No visible keyboard focus" = "focus")

accessibility_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c("Check text and background contrast.", "Interpret a ratio using WCAG thresholds.", "Recognise barriers that a contrast check cannot detect."),
    concept = "WCAG asks for a contrast ratio of at least 4.5:1 for normal text and 3:1 for large text. Passing contrast is necessary, but it is only one of many success criteria.",
    activity = navset_underline(
      nav_panel("Contrast checker",
        div(class = "pt-3",
          p("Try a preset, or type two hex colours."),
          div(class = "d-flex flex-wrap gap-2 mb-3", lapply(names(colour_presets), function(name)
            tags$button(class = "btn btn-sm btn-outline-secondary", type = "button", name,
                        onclick = js_event(ns("preset"), sprintf("'%s'", name))))),
          layout_columns(col_widths = c(6, 6),
            div(textInput(ns("fg"), "Text colour (hex)", "#202522"),
                textInput(ns("bg"), "Background colour (hex)", "#FFFFFF"),
                sliderInput(ns("size"), "Text size (pt)", min = 8, max = 36, value = 16)),
            div(uiOutput(ns("result")))),
          div(class = "mt-3 p-4 border rounded", uiOutput(ns("sample"))))),
      nav_panel("Spot the barrier",
        div(class = "pt-3",
          p("Each example passes a contrast check. Name the barrier that remains."),
          lapply(barrier_items, function(item) div(class = "panel-soft mb-2",
            p(class = "mb-2", item$example),
            selectInput(ns(paste0("barrier_", item$id)), NULL, barrier_choices, width = "100%"))),
          actionButton(ns("check"), "Check my answers", class = "btn-primary"),
          uiOutput(ns("barrier_feedback"))))),
    reflection = "What other barriers could remain even if the contrast ratio passes? How would you find them?")
}

accessibility_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    observeEvent(input$preset, {
      pair <- colour_presets[[input$preset]]
      updateTextInput(session, "fg", value = pair[1]); updateTextInput(session, "bg", value = pair[2])
    })
    valid <- reactive(valid_hex(input$fg) && valid_hex(input$bg))
    ratio <- reactive({ req(valid()); contrast_ratio(input$fg, input$bg) })
    large <- reactive(input$size >= 18)

    output$result <- renderUI({
      if (!valid()) return(div(class = "alert alert-warning", "Enter colours as six-digit hex values, e.g. #202522."))
      r <- ratio()
      target <- if (large()) 3 else 4.5
      level <- if (r >= 7) "Passes AAA for normal text" else if (r >= 4.5) "Passes AA for normal text" else if (r >= 3) "Passes AA for large text only" else "Below WCAG AA thresholds"
      suggestion <- if (r < target) {
        fix <- passing_colour(input$fg, input$bg, target)
        p(class = "mb-0 mt-2", "Closest passing text colour: ", tags$code(fix), " ",
          tags$a(href = "#", onclick = js_event(session$ns("apply_fix"), sprintf("'%s'", fix)), "Use it"))
      }
      div(class = if (r >= target) "alert alert-success" else "alert alert-warning", role = "status",
        tags$strong(style = "font-size:1.6rem", sprintf("%.2f:1", r)), br(), level,
        br(), span(class = "footnote", if (large()) "At this size the text counts as large (3:1 needed)." else "Normal text needs 4.5:1."),
        suggestion)
    })
    observeEvent(input$apply_fix, updateTextInput(session, "fg", value = input$apply_fix))

    output$sample <- renderUI({
      if (!valid()) return("The preview appears when both colours are valid.")
      div(style = sprintf("color:%s;background:%s;font-size:%spt;padding:1rem;border-radius:.4rem", input$fg, input$bg, input$size),
          "Readable interface text should remain legible across screens, lighting, and eyesight.")
    })

    checked <- reactiveVal(FALSE)
    observeEvent(input$check, checked(TRUE))
    output$barrier_feedback <- renderUI({
      req(checked())
      answers <- vapply(barrier_items, function(item) input[[paste0("barrier_", item$id)]] %||% "", "")
      right <- answers == vapply(barrier_items, `[[`, "", "answer")
      div(class = "mt-3",
        div(class = if (all(right)) "alert alert-success" else "alert alert-info", sprintf("%d of %d identified.", sum(right), length(right))),
        tags$ul(class = "check-list", lapply(seq_along(barrier_items), function(i) tags$li(class = if (right[i]) "ok" else "todo", barrier_items[[i]]$why))))
    })

    output$export_notes <- notes_handler("Accessibility", input, function() {
      if (!valid()) return("(no valid colour pair)")
      sprintf("Text %s on %s at %spt: contrast %.2f:1", toupper(input$fg), toupper(input$bg), input$size, ratio())
    })
  })
}
