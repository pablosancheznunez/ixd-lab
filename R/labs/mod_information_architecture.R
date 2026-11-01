ia_cards <- c("Course overview", "Weekly readings", "Lecture recordings", "Assessment dates", "Submit assignment",
              "Grades", "Class forum", "Contact tutor", "Office hours", "Accessibility support")

ia_reference <- list(
  "Learn" = c("Course overview", "Weekly readings", "Lecture recordings"),
  "Assessment" = c("Assessment dates", "Submit assignment", "Grades"),
  "Get help" = c("Contact tutor", "Office hours", "Accessibility support"),
  "Community" = c("Class forum")
)

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
    objectives = c("Group content by meaning.", "Write labels a visitor would recognise.", "Compare your structure with another and explain the differences."),
    concept = "Card sorting reveals how people expect content to be grouped. There is rarely one right answer; good structures use labels that match the words visitors already use.",
    activity = tagList(
      p("Challenge · Organise ten pages for a university course site. Place every card, then compare."),
      layout_columns(col_widths = c(5, 7),
        div(
          selectInput(ns("card"), "Content card", ia_cards),
          selectizeInput(ns("category"), "Category label", choices = NULL,
                         options = list(create = TRUE, placeholder = "Type a new label or choose one")),
          actionButton(ns("place"), "Place card", class = "btn-primary w-100 mb-3"),
          div(class = "panel-soft", span(class = "eyebrow", "NOT YET PLACED"), uiOutput(ns("unsorted")))),
        div(
          h4("Your draft sitemap"),
          uiOutput(ns("map")),
          div(class = "d-flex flex-wrap gap-2 mt-3",
            actionButton(ns("compare"), "Compare with a reference", class = "btn-outline-success"),
            actionButton(ns("reset"), "Reset activity", class = "btn-outline-secondary")),
          uiOutput(ns("comparison")))))
    ,
    reflection = "Would a first-time student predict these labels? Which card could fit in more than one place?")
}

information_architecture_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    empty <- data.frame(card = character(), category = character())
    placed <- reactiveVal(empty)
    compared <- reactiveVal(FALSE)
    remaining <- reactive(setdiff(ia_cards, placed()$card))

    observeEvent(input$place, {
      label <- trimws(input$category %||% "")
      if (!nzchar(label)) return(showNotification("Type or choose a category label first.", type = "warning"))
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
      if (!length(left)) return(p(class = "footnote mb-0", "All cards placed. Compare your sitemap with the reference."))
      tags$ul(class = "footnote mb-0", lapply(left, tags$li))
    })

    output$map <- renderUI({
      x <- placed()
      if (!nrow(x)) return(p(class = "muted", "Choose a card, give it a category label, and place it."))
      groups <- split(x$card, x$category)
      layout_column_wrap(width = "200px", gap = ".8rem",
        !!!lapply(names(groups), function(g) div(class = "panel-soft",
          tags$strong(g),
          tags$ul(class = "mb-0 mt-1", lapply(groups[[g]], function(card) tags$li(card, " ",
            tags$a(href = "#", class = "footnote", `aria-label` = paste("Remove", card), onclick = js_event(session$ns("unplace"), sprintf("'%s'", card)), "×")))))))
    })

    output$comparison <- renderUI({
      req(compared())
      if (length(remaining())) return(div(class = "alert alert-warning mt-3", "Place all ten cards before comparing."))
      result <- ia_agreement(placed())
      ref <- tags$ul(lapply(names(ia_reference), function(g) tags$li(tags$strong(g), ": ", paste(ia_reference[[g]], collapse = ", "))))
      div(class = "alert alert-success mt-3",
        tags$strong(sprintf("%d%% of the reference groupings also appear in your sitemap.", round(100 * result$share))),
        p(class = "mt-2 mb-1", "One reference structure, not the correct answer:"), ref,
        if (nrow(result$missed)) p(class = "mb-0", "Pairs you placed apart: ", paste(apply(result$missed, 1, paste, collapse = " + "), collapse = "; "), ". Was that a deliberate choice?"))
    })

    output$export_notes <- notes_handler("Information architecture", input, function() {
      x <- placed()
      if (!nrow(x)) return("(no cards placed)")
      groups <- split(x$card, x$category)
      c(vapply(names(groups), function(g) paste0(g, ": ", paste(groups[[g]], collapse = ", ")), ""),
        if (!length(remaining())) sprintf("Agreement with reference: %d%%", round(100 * ia_agreement(x)$share)))
    })
  })
}
