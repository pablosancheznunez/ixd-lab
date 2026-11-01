wire_components <- c(
  nav = tr("Navigation", "Navegación"), heading = tr("Page heading", "Título de página"), search = tr("Search field", "Campo de búsqueda"),
  text = tr("Body text", "Texto"), image = tr("Image placeholder", "Imagen"), cards = tr("Card list", "Lista de tarjetas"),
  field = tr("Form field", "Campo de formulario"), button = tr("Primary button", "Botón principal"), footer = tr("Footer", "Pie de página")
)

wire_templates <- setNames(list(
  c("nav", "heading", "text", "search", "cards", "button", "footer"),
  c("nav", "heading", "image", "text", "field", "field", "button", "footer")
), c(tr("Course finder", "Buscador de cursos"), tr("Event sign-up", "Inscripción a un evento")))

# Low-fidelity drawing of one component on the canvas.
wire_sketch <- function(key) {
  bar <- function(width = "100%") div(class = "wf-bar", style = paste0("width:", width))
  body <- switch(key,
    nav = div(class = "wf-row", bar(), bar(), bar(), bar()),
    heading = bar("70%"),
    search = div(class = "wf-field"),
    text = tagList(bar(), bar("92%"), bar("60%")),
    image = div(class = "wf-image"),
    cards = div(class = "wf-row", div(class = "wf-card"), div(class = "wf-card"), div(class = "wf-card")),
    field = tagList(bar("30%"), div(class = "wf-field")),
    button = div(class = "wf-button"),
    footer = tagList(bar("80%"), bar("50%")))
  cls <- c(nav = "wf-nav", heading = "wf-heading", cards = "wf-cards", footer = "wf-footer")[key]
  div(class = paste("wf", if (is.na(cls)) "" else cls), span(class = "wf-label", wire_components[[key]]), body)
}

# Formative checks on the current sketch.
wire_checks <- function(items, screen) {
  n_button <- sum(items == "button")
  long_mobile <- screen == "mobile" && length(items) > 7
  list(
    list(ok = "heading" %in% items, text = tr("A page heading tells visitors where they are.", "Un título de página indica dónde se encuentra la persona.")),
    list(ok = n_button == 1, text = if (n_button > 1) tr("More than one primary button competes for attention.", "Más de un botón principal compite por la atención.")
                                    else tr("One primary button makes the next step clear.", "Un único botón principal deja claro el siguiente paso.")),
    list(ok = length(items) > 0 && items[1] == "nav", text = tr("Navigation sits at the top, where people expect it.", "La navegación está arriba, donde la gente la espera.")),
    list(ok = length(items) > 0 && items[length(items)] == "footer", text = tr("A footer closes the page with secondary links.", "Un pie de página cierra la página con enlaces secundarios.")),
    list(ok = !long_mobile, text = if (long_mobile) tr("On mobile, this many blocks means a long scroll: what could you remove?", "En móvil, tantos bloques suponen mucho scroll: ¿qué podrías quitar?")
                                   else tr("The page length suits this screen width.", "La longitud de la página encaja con este ancho de pantalla."))
  )
}

wireframing_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Build a simple page hierarchy.", "Construir una jerarquía de página sencilla."),
                   tr("Compare component choices and their order.", "Comparar componentes y su orden."),
                   tr("Explain how a layout supports one task.", "Explicar cómo una maquetación apoya una tarea.")),
    concept = tr("A wireframe shows structure and priority, not visual style. Keep it grey and rough so discussion stays on what the page must do and in which order.",
                 "Un wireframe muestra estructura y prioridad, no estilo visual. Mantenlo gris y esquemático para que la conversación se centre en qué debe hacer la página y en qué orden."),
    activity = tagList(
      p(tr("Challenge · Sketch a landing page that helps a new student find a course.", "Reto · Boceta una página de inicio que ayude a un estudiante nuevo a encontrar un curso.")),
      layout_columns(col_widths = c(4, 8),
        div(
          selectInput(ns("component"), tr("Component", "Componente"), setNames(names(wire_components), wire_components)),
          actionButton(ns("add"), tr("Add to canvas", "Añadir al lienzo"), class = "btn-primary w-100 mb-3"),
          selectInput(ns("template"), tr("Or start from a template", "O empieza con una plantilla"), c(setNames("", tr("Choose a template", "Elige una plantilla")), names(wire_templates))),
          radioButtons(ns("screen"), tr("Canvas width", "Ancho del lienzo"), setNames(c("desktop", "tablet", "mobile"), c(tr("Desktop", "Escritorio"), "Tablet", tr("Mobile", "Móvil"))), inline = TRUE),
          actionButton(ns("clear"), tr("Clear canvas", "Vaciar lienzo"), class = "btn-outline-secondary w-100 mb-2"),
          downloadButton(ns("export"), tr("Export sketch", "Exportar boceto"), class = "btn-outline-success w-100"),
          div(class = "panel-soft mt-3", span(class = "eyebrow", tr("DESIGN CHECKS", "COMPROBACIONES")), uiOutput(ns("checks")))),
        uiOutput(ns("canvas")))),
    reflection = tr("Which element establishes the clearest next step? What would you change for a narrow screen?",
                    "¿Qué elemento marca el siguiente paso con más claridad? ¿Qué cambiarías para una pantalla estrecha?"))
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
        tags$button(class = "btn btn-outline-secondary", type = "button", `aria-label` = paste(label, wire_components[[x[i]]]), title = label,
                    onclick = js_event(session$ns("item_action"), sprintf("{action: '%s', i: %d}", action, i)), icon)
      }
      div(class = "wire-canvas", style = paste0("max-width:", width), `aria-label` = tr("Wireframe canvas", "Lienzo del wireframe"),
        if (!length(x)) p(class = "muted m-2", tr("Your canvas is empty. Add a component or start from a template.", "Tu lienzo está vacío. Añade un componente o empieza con una plantilla."))
        else lapply(seq_along(x), function(i) div(class = "wire-item", wire_sketch(x[i]),
          div(class = "wire-tools", tool("up", i, tr("Move up", "Subir"), "↑"), tool("down", i, tr("Move down", "Bajar"), "↓"), tool("remove", i, tr("Remove", "Quitar"), "×")))))
    })

    output$checks <- renderUI({
      if (!length(items())) return(p(class = "footnote mb-0", tr("Checks appear when you add components.", "Las comprobaciones aparecen al añadir componentes.")))
      tags$ul(class = "check-list footnote", lapply(wire_checks(items(), input$screen), function(ch) tags$li(class = if (ch$ok) "ok" else "todo", ch$text)))
    })

    sketch_lines <- function() {
      x <- items()
      c(paste0(tr("Canvas: ", "Lienzo: "), input$screen), if (length(x)) paste(seq_along(x), unname(wire_components[x]), sep = ". ") else tr("(empty)", "(vacío)"), "",
        tr("Design checks:", "Comprobaciones:"), vapply(wire_checks(x, input$screen), function(ch) paste(if (ch$ok) "[ok]" else tr("[review]", "[revisar]"), ch$text), ""))
    }
    output$export <- downloadHandler(filename = function() "ixd-wireframe.txt",
      content = function(file) writeLines(enc2utf8(c(tr("IxD Lab · Wireframing sketch", "IxD Lab · Boceto de wireframing"), "", sketch_lines())), file, useBytes = TRUE))
    reflect_server("Wireframing", input, output, session, sketch_lines)
  })
}
