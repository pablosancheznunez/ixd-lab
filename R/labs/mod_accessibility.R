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

colour_presets <- setNames(list(c("#9A9A9A", "#FFFFFF"), c("#FFFFFF", "#3FA34D"), c("#1D2B53", "#F2E3C6"), c("#D0312D", "#111111")),
  c(tr("Grey on white", "Gris sobre blanco"), tr("White on green", "Blanco sobre verde"), tr("Navy on sand", "Azul marino sobre arena"), tr("Red on black", "Rojo sobre negro")))

barrier_items <- list(
  list(id = "img", answer = "alt",
       example = tr("A product photo is announced by a screen reader as \"IMG_2041.jpg\".", "Un lector de pantalla anuncia la foto de un producto como «IMG_2041.jpg»."),
       why = tr("Images that carry meaning need a text alternative (WCAG 1.1.1).", "Las imágenes con significado necesitan una alternativa textual (WCAG 1.1.1).")),
  list(id = "field", answer = "label",
       example = tr("A form field shows the hint \"Email\" inside the box, which disappears as soon as you type.", "Un campo muestra la pista «Correo» dentro de la caja, que desaparece en cuanto escribes."),
       why = tr("Placeholders are not labels: once they vanish, people must remember what the field was (WCAG 3.3.2).", "Un texto de ejemplo no es una etiqueta: cuando desaparece, hay que recordar qué pedía el campo (WCAG 3.3.2).")),
  list(id = "colour", answer = "colour",
       example = tr("Required fields that were left empty are shown only with a red border.", "Los campos obligatorios que se dejaron vacíos solo se marcan con un borde rojo."),
       why = tr("Colour alone does not reach everyone; add text or an icon (WCAG 1.4.1).", "El color por sí solo no llega a todo el mundo; añade texto o un icono (WCAG 1.4.1).")),
  list(id = "focus", answer = "focus",
       example = tr("Pressing Tab moves through the page, but there is no visible sign of where you are.", "Al pulsar Tab te mueves por la página, pero no se ve dónde estás."),
       why = tr("Keyboard users need a visible focus indicator (WCAG 2.4.7).", "Quien usa el teclado necesita un indicador de foco visible (WCAG 2.4.7)."))
)
barrier_choices <- setNames(c("", "alt", "label", "colour", "focus"),
  c(tr("Choose the barrier", "Elige la barrera"), tr("Missing text alternative", "Falta alternativa textual"), tr("Missing visible label", "Falta etiqueta visible"),
    tr("Information conveyed by colour only", "Información transmitida solo con color"), tr("No visible keyboard focus", "Sin foco de teclado visible")))

accessibility_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Check text and background contrast.", "Comprobar el contraste entre texto y fondo."),
                   tr("Interpret a ratio using WCAG thresholds.", "Interpretar una ratio con los umbrales de las WCAG."),
                   tr("Recognise barriers that a contrast check cannot detect.", "Reconocer barreras que una comprobación de contraste no detecta.")),
    concept = tr("WCAG asks for a contrast ratio of at least 4.5:1 for normal text and 3:1 for large text. Passing contrast is necessary, but it is only one of many success criteria.",
                 "Las WCAG piden una ratio de contraste de al menos 4,5:1 para texto normal y 3:1 para texto grande. Superar el contraste es necesario, pero es solo uno de muchos criterios de conformidad."),
    activity = navset_underline(
      nav_panel(tr("Contrast checker", "Comprobador de contraste"),
        div(class = "pt-3",
          p(tr("Try a preset, or type two hex colours.", "Prueba una combinación predefinida o escribe dos colores hexadecimales.")),
          div(class = "d-flex flex-wrap gap-2 mb-3", lapply(names(colour_presets), function(name)
            tags$button(class = "btn btn-sm btn-outline-secondary", type = "button", name,
                        onclick = js_event(ns("preset"), sprintf("'%s'", name))))),
          layout_columns(col_widths = c(6, 6),
            div(textInput(ns("fg"), tr("Text colour (hex)", "Color del texto (hex)"), "#202522"),
                textInput(ns("bg"), tr("Background colour (hex)", "Color de fondo (hex)"), "#FFFFFF"),
                sliderInput(ns("size"), tr("Text size (pt)", "Tamaño del texto (pt)"), min = 8, max = 36, value = 16)),
            div(uiOutput(ns("result")))),
          div(class = "mt-3 p-4 border rounded", uiOutput(ns("sample"))))),
      nav_panel(tr("Spot the barrier", "Detecta la barrera"),
        div(class = "pt-3",
          p(tr("Each example passes a contrast check. Name the barrier that remains.", "Todos los ejemplos superan la comprobación de contraste. Indica la barrera que queda.")),
          lapply(barrier_items, function(item) div(class = "panel-soft mb-2",
            p(class = "mb-2", item$example),
            selectInput(ns(paste0("barrier_", item$id)), NULL, barrier_choices, width = "100%"))),
          actionButton(ns("check"), tr("Check my answers", "Comprobar mis respuestas"), class = "btn-primary"),
          uiOutput(ns("barrier_feedback"))))),
    reflection = tr("What other barriers could remain even if the contrast ratio passes? How would you find them?",
                    "¿Qué otras barreras podrían quedar aunque el contraste sea suficiente? ¿Cómo las encontrarías?"))
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
    fmt_ratio <- function(r) if (LANG == "es") paste0(formatC(r, format = "f", digits = 2, decimal.mark = ","), ":1") else sprintf("%.2f:1", r)

    output$result <- renderUI({
      if (!valid()) return(div(class = "alert alert-warning", tr("Enter colours as six-digit hex values, e.g. #202522.", "Escribe los colores como valores hexadecimales de seis dígitos, p. ej. #202522.")))
      r <- ratio()
      target <- if (large()) 3 else 4.5
      level <- if (r >= 7) tr("Passes AAA for normal text", "Cumple AAA para texto normal")
               else if (r >= 4.5) tr("Passes AA for normal text", "Cumple AA para texto normal")
               else if (r >= 3) tr("Passes AA for large text only", "Cumple AA solo para texto grande")
               else tr("Below WCAG AA thresholds", "Por debajo de los umbrales AA de las WCAG")
      suggestion <- if (r < target) {
        fix <- passing_colour(input$fg, input$bg, target)
        p(class = "mb-0 mt-2", tr("Closest passing text colour: ", "Color de texto válido más cercano: "), tags$code(fix), " ",
          tags$a(href = "#", onclick = js_event(session$ns("apply_fix"), sprintf("'%s'", fix)), tr("Use it", "Usarlo")))
      }
      div(class = if (r >= target) "alert alert-success" else "alert alert-warning", role = "status",
        tags$strong(style = "font-size:1.6rem", fmt_ratio(r)), br(), level,
        br(), span(class = "footnote", if (large()) tr("At this size the text counts as large (3:1 needed).", "A este tamaño el texto cuenta como grande (se necesita 3:1).")
                                       else tr("Normal text needs 4.5:1.", "El texto normal necesita 4,5:1.")),
        suggestion)
    })
    observeEvent(input$apply_fix, updateTextInput(session, "fg", value = input$apply_fix))

    output$sample <- renderUI({
      if (!valid()) return(tr("The preview appears when both colours are valid.", "La vista previa aparece cuando los dos colores son válidos."))
      div(style = sprintf("color:%s;background:%s;font-size:%spt;padding:1rem;border-radius:.4rem", input$fg, input$bg, input$size),
          tr("Readable interface text should remain legible across screens, lighting, and eyesight.", "El texto de una interfaz debe seguir siendo legible con distintas pantallas, luz y capacidades visuales."))
    })

    checked <- reactiveVal(FALSE)
    observeEvent(input$check, checked(TRUE))
    output$barrier_feedback <- renderUI({
      req(checked())
      answers <- vapply(barrier_items, function(item) input[[paste0("barrier_", item$id)]] %||% "", "")
      right <- answers == vapply(barrier_items, `[[`, "", "answer")
      div(class = "mt-3",
        div(class = if (all(right)) "alert alert-success" else "alert alert-info", sprintf(tr("%d of %d identified.", "%d de %d identificadas."), sum(right), length(right))),
        tags$ul(class = "check-list", lapply(seq_along(barrier_items), function(i) tags$li(class = if (right[i]) "ok" else "todo", barrier_items[[i]]$why))))
    })

    output$export_notes <- notes_handler(tr("Accessibility", "Accesibilidad"), input, function() {
      if (!valid()) return(tr("(no valid colour pair)", "(sin pareja de colores válida)"))
      sprintf(tr("Text %s on %s at %spt: contrast %s", "Texto %s sobre %s a %s pt: contraste %s"), toupper(input$fg), toupper(input$bg), input$size, fmt_ratio(ratio()))
    })
  })
}
