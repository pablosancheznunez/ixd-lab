wire_components <- c("Navigation", "Page heading", "Search field", "Body text", "Image placeholder", "Card list", "Form field", "Primary button", "Footer")

wire_templates <- list(
  "Course finder" = c("Navigation", "Page heading", "Body text", "Search field", "Card list", "Primary button", "Footer"),
  "Event sign-up" = c("Navigation", "Page heading", "Image placeholder", "Body text", "Form field", "Form field", "Primary button", "Footer")
)

# Low-fidelity drawing of one component on the canvas.
wire_sketch <- function(component) {
  bar <- function(width = "100%") div(class = "wf-bar", style = paste0("width:", width))
  body <- switch(component,
    "Navigation" = div(class = "wf-row", bar(), bar(), bar(), bar()),
    "Page heading" = bar("70%"),
    "Search field" = div(class = "wf-field"),
    "Body text" = tagList(bar(), bar("92%"), bar("60%")),
    "Image placeholder" = div(class = "wf-image"),
    "Card list" = div(class = "wf-row", div(class = "wf-card"), div(class = "wf-card"), div(class = "wf-card")),
    "Form field" = tagList(bar("30%"), div(class = "wf-field")),
    "Primary button" = div(class = "wf-button"),
    "Footer" = tagList(bar("80%"), bar("50%")))
  cls <- c("Navigation" = "wf-nav", "Page heading" = "wf-heading", "Card list" = "wf-cards", "Footer" = "wf-footer")[component]
  div(class = paste("wf", if (is.na(cls)) "" else cls), span(class = "wf-label", component), body)
}

# Formative checks on the current sketch.
wire_checks <- function(items, screen) {
  n_button <- sum(items == "Primary button")
  list(
    list(ok = "Page heading" %in% items, text = "A page heading tells visitors where they are."),
    list(ok = n_button == 1, text = if (n_button > 1) "More than one primary button competes for attention." else "One primary button makes the next step clear."),
    list(ok = length(items) > 0 && items[1] == "Navigation", text = "Navigation sits at the top, where people expect it."),
    list(ok = length(items) > 0 && items[length(items)] == "Footer", text = "A footer closes the page with secondary links."),
    list(ok = !(screen == "mobile" && length(items) > 7), text = if (screen == "mobile" && length(items) > 7) "On mobile, this many blocks means a long scroll: what could you remove?" else "The page length suits this screen width.")
  )
}

wireframing_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c("Build a simple page hierarchy.", "Compare component choices and their order.", "Explain how a layout supports one task."),
    concept = "A wireframe shows structure and priority, not visual style. Keep it grey and rough so discussion stays on what the page must do and in which order.",
    activity = tagList(
      p("Challenge · Sketch a landing page that helps a new student find a course."),
      layout_columns(col_widths = c(4, 8),
        div(
          selectInput(ns("component"), "Component", wire_components),
          actionButton(ns("add"), "Add to canvas", class = "btn-primary w-100 mb-3"),
          selectInput(ns("template"), "Or start from a template", c("Choose a template" = "", names(wire_templates))),
          radioButtons(ns("screen"), "Canvas width", c("Desktop" = "desktop", "Tablet" = "tablet", "Mobile" = "mobile"), inline = TRUE),
          actionButton(ns("clear"), "Clear canvas", class = "btn-outline-secondary w-100 mb-2"),
          downloadButton(ns("export"), "Export sketch", class = "btn-outline-success w-100"),
          div(class = "panel-soft mt-3", span(class = "eyebrow", "DESIGN CHECKS"), uiOutput(ns("checks")))),
        uiOutput(ns("canvas"))))
    ,
    reflection = "Which element establishes the clearest next step? What would you change for a narrow screen?")
}

wireframing_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    items <- reactiveVal(character())
    observeEvent(input$add, items(c(items(), input$component)))
    observeEvent(input$clear, items(character()))
    observeEvent(input$template, {
      req(nzchar(input$template))
      items(wire_templates[[input$template]])
      updateSelectInput(session, "template", selected = "")
    })
    observeEvent(input$item_action, {
      x <- items(); i <- input$item_action$i
      req(i >= 1, i <= length(x))
      j <- switch(input$item_action$action, up = i - 1, down = i + 1, NA)
      if (input$item_action$action == "remove") x <- x[-i]
      else if (!is.na(j) && j >= 1 && j <= length(x)) x[c(i, j)] <- x[c(j, i)]
      items(x)
    })

    output$canvas <- renderUI({
      x <- items()
      width <- switch(input$screen %||% "desktop", desktop = "100%", tablet = "560px", mobile = "320px")
      tool <- function(action, i, label, icon) {
        tags$button(class = "btn btn-outline-secondary", type = "button", `aria-label` = paste(label, x[i]), title = label,
                    onclick = js_event(session$ns("item_action"), sprintf("{action: '%s', i: %d}", action, i)), icon)
      }
      div(class = "wire-canvas", style = paste0("max-width:", width), `aria-label` = "Wireframe canvas",
        if (!length(x)) p(class = "muted m-2", "Your canvas is empty. Add a component or start from a template.")
        else lapply(seq_along(x), function(i) div(class = "wire-item", wire_sketch(x[i]),
          div(class = "wire-tools", tool("up", i, "Move up", "↑"), tool("down", i, "Move down", "↓"), tool("remove", i, "Remove", "×")))))
    })

    output$checks <- renderUI({
      if (!length(items())) return(p(class = "footnote mb-0", "Checks appear when you add components."))
      tags$ul(class = "check-list footnote", lapply(wire_checks(items(), input$screen), function(ch) tags$li(class = if (ch$ok) "ok" else "todo", ch$text)))
    })

    sketch_lines <- function() {
      x <- items()
      c(paste0("Canvas: ", input$screen), if (length(x)) paste(seq_along(x), x, sep = ". ") else "(empty)", "",
        "Design checks:", vapply(wire_checks(x, input$screen), function(ch) paste(if (ch$ok) "[ok]" else "[review]", ch$text), ""))
    }
    output$export <- downloadHandler(filename = function() "ixd-wireframe.txt",
      content = function(file) writeLines(enc2utf8(c("IxD Lab · Wireframing sketch", "", sketch_lines())), file, useBytes = TRUE))
    output$export_notes <- notes_handler("Wireframing", input, sketch_lines)
  })
}
