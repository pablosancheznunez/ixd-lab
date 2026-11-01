ia_cards <- c(tr("Course overview", "Presentación del curso"), tr("Weekly readings", "Lecturas semanales"), tr("Lecture recordings", "Grabaciones de clase"),
              tr("Assessment dates", "Fechas de evaluación"), tr("Submit assignment", "Entregar trabajo"), tr("Grades", "Calificaciones"),
              tr("Class forum", "Foro de la clase"), tr("Contact tutor", "Contactar con el docente"), tr("Office hours", "Tutorías"),
              tr("Accessibility support", "Apoyo a la accesibilidad"))

ia_reference <- setNames(list(ia_cards[1:3], ia_cards[4:6], ia_cards[8:10], ia_cards[7]),
                         c(tr("Learn", "Aprender"), tr("Assessment", "Evaluación"), tr("Get help", "Ayuda"), tr("Community", "Comunidad")))

# Share of card pairs grouped together in the reference that the learner also grouped together.
ia_agreement <- function(placed) {
  pairs <- do.call(rbind, lapply(ia_reference, function(g) if (length(g) > 1) t(combn(g, 2))))
  group_of <- setNames(placed$category, placed$card)
  together <- apply(pairs, 1, function(p) all(p %in% names(group_of)) && group_of[[p[1]]] == group_of[[p[2]]])
  list(share = mean(together), missed = pairs[!together, , drop = FALSE])
}

information_architecture_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Group content by meaning.", "Agrupar contenidos por significado."),
                   tr("Write labels a visitor would recognise.", "Escribir etiquetas que un visitante reconozca."),
                   tr("Compare your structure with another and explain the differences.", "Comparar tu estructura con otra y explicar las diferencias.")),
    concept = tr("Card sorting reveals how people expect content to be grouped. There is rarely one right answer; good structures use labels that match the words visitors already use.",
                 "La ordenación de tarjetas (card sorting) revela cómo espera la gente que se agrupen los contenidos. Rara vez hay una única respuesta correcta; las buenas estructuras usan etiquetas con las palabras que los visitantes ya emplean."),
    activity = tagList(
      p(tr("Challenge · Organise ten pages for a university course site. Place every card, then compare.", "Reto · Organiza diez páginas del sitio web de una asignatura. Coloca todas las tarjetas y después compara.")),
      layout_columns(col_widths = c(5, 7),
        div(
          selectInput(ns("card"), tr("Content card", "Tarjeta de contenido"), ia_cards),
          selectizeInput(ns("category"), tr("Category label", "Etiqueta de categoría"), choices = NULL,
                         options = list(create = TRUE, placeholder = tr("Type a new label or choose one", "Escribe una etiqueta nueva o elige una"))),
          actionButton(ns("place"), tr("Place card", "Colocar tarjeta"), class = "btn-primary w-100 mb-3"),
          div(class = "panel-soft", span(class = "eyebrow", tr("NOT YET PLACED", "SIN COLOCAR")), uiOutput(ns("unsorted")))),
        div(
          h4(tr("Your draft sitemap", "Tu borrador de mapa del sitio")),
          uiOutput(ns("map")),
          div(class = "d-flex flex-wrap gap-2 mt-3",
            actionButton(ns("compare"), tr("Compare with a reference", "Comparar con una referencia"), class = "btn-outline-success"),
            actionButton(ns("reset"), tr("Reset activity", "Reiniciar actividad"), class = "btn-outline-secondary")),
          uiOutput(ns("comparison"))))),
    reflection = tr("Would a first-time student predict these labels? Which card could fit in more than one place?",
                    "¿Adivinaría estas etiquetas un estudiante que entra por primera vez? ¿Qué tarjeta podría encajar en más de un sitio?"))
}

information_architecture_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    empty <- data.frame(card = character(), category = character())
    placed <- reactiveVal(empty)
    compared <- reactiveVal(FALSE)
    remaining <- reactive(setdiff(ia_cards, placed()$card))

    observeEvent(input$place, {
      label <- trimws(input$category %||% "")
      if (!nzchar(label)) return(showNotification(tr("Type or choose a category label first.", "Primero escribe o elige una etiqueta de categoría."), type = "warning"))
      x <- placed()
      x <- rbind(x[x$card != input$card, ], data.frame(card = input$card, category = label))
      placed(x)
      updateSelectizeInput(session, "category", choices = unique(x$category), selected = label)
    })
    observeEvent(remaining(), {
      left <- remaining()
      updateSelectInput(session, "card", choices = if (length(left)) left else ia_cards)
    })
    observeEvent(input$unplace, placed(placed()[placed()$card != input$unplace, ]))
    observeEvent(input$reset, { placed(empty); compared(FALSE); updateSelectizeInput(session, "category", choices = character()) })
    observeEvent(input$compare, compared(TRUE))

    output$unsorted <- renderUI({
      left <- remaining()
      if (!length(left)) return(p(class = "footnote mb-0", tr("All cards placed. Compare your sitemap with the reference.", "Todas las tarjetas colocadas. Compara tu mapa con la referencia.")))
      tags$ul(class = "footnote mb-0", lapply(left, tags$li))
    })

    output$map <- renderUI({
      x <- placed()
      if (!nrow(x)) return(p(class = "muted", tr("Choose a card, give it a category label, and place it.", "Elige una tarjeta, ponle una etiqueta de categoría y colócala.")))
      groups <- split(x$card, x$category)
      layout_column_wrap(width = "200px", gap = ".8rem",
        !!!lapply(names(groups), function(g) div(class = "panel-soft",
          tags$strong(g),
          tags$ul(class = "mb-0 mt-1", lapply(groups[[g]], function(card) tags$li(card, " ",
            tags$a(href = "#", class = "footnote", `aria-label` = paste(tr("Remove", "Quitar"), card), onclick = js_event(session$ns("unplace"), sprintf("'%s'", card)), "×")))))))
    })

    output$comparison <- renderUI({
      req(compared())
      if (length(remaining())) return(div(class = "alert alert-warning mt-3", tr("Place all ten cards before comparing.", "Coloca las diez tarjetas antes de comparar.")))
      result <- ia_agreement(placed())
      ref <- tags$ul(lapply(names(ia_reference), function(g) tags$li(tags$strong(g), ": ", paste(ia_reference[[g]], collapse = ", "))))
      div(class = "alert alert-success mt-3",
        tags$strong(sprintf(tr("%d%% of the reference groupings also appear in your sitemap.", "El %d%% de las agrupaciones de referencia también aparecen en tu mapa."), round(100 * result$share))),
        p(class = "mt-2 mb-1", tr("One reference structure, not the correct answer:", "Una estructura de referencia, no la respuesta correcta:")), ref,
        if (nrow(result$missed)) p(class = "mb-0", tr("Pairs you placed apart: ", "Parejas que separaste: "), paste(apply(result$missed, 1, paste, collapse = " + "), collapse = "; "),
                                   tr(". Was that a deliberate choice?", ". ¿Fue una decisión deliberada?")))
    })

    observeEvent(input$example, {
      labels <- c(tr("Study", "Estudiar"), tr("Assessment", "Evaluación"), tr("Help", "Ayuda"))
      placed(data.frame(card = ia_cards, category = labels[c(1, 1, 1, 2, 2, 2, 3, 3, 3, 3)]))
      updateSelectizeInput(session, "category", choices = labels)
      compared(TRUE)
      example_reflection(session, tr(
        "I grouped the class forum with Help because students use it to ask questions. The reference puts it under Community: a quick card sort with students would show which label they expect.",
        "Puse el foro con Ayuda porque el alumnado lo usa para preguntar. La referencia lo pone en Comunidad: una ordenación de tarjetas rápida con estudiantes mostraría qué etiqueta esperan."))
    })

    reflect_server(tr("Information architecture", "Arquitectura de la información"), input, output, session, function() {
      x <- placed()
      if (!nrow(x)) return(tr("(no cards placed)", "(sin tarjetas colocadas)"))
      groups <- split(x$card, x$category)
      c(vapply(names(groups), function(g) paste0(g, ": ", paste(groups[[g]], collapse = ", ")), ""),
        if (!length(remaining())) sprintf(tr("Agreement with reference: %d%%", "Coincidencia con la referencia: %d%%"), round(100 * ia_agreement(x)$share)))
    })
  })
}
