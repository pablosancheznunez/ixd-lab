pattern_quiz <- list(
  list(id = "q1", answer = "inline",
       situation = tr("Saving a draft of a forum post.", "Guardar el borrador de un mensaje del foro."),
       why = tr("Low risk and easy to repeat: a quiet status message is enough.", "Poco riesgo y fácil de repetir: basta con un mensaje de estado discreto.")),
  list(id = "q2", answer = "dialog",
       situation = tr("Permanently deleting a course with 120 enrolled students.", "Eliminar para siempre una asignatura con 120 estudiantes matriculados."),
       why = tr("Severe and irreversible: interrupting with a confirmation that names the consequence is proportionate.", "Grave e irreversible: interrumpir con una confirmación que nombre la consecuencia es proporcionado.")),
  list(id = "q3", answer = "undo",
       situation = tr("Archiving an email from the inbox.", "Archivar un correo de la bandeja de entrada."),
       why = tr("Frequent and reversible: acting at once and offering Undo avoids needless interruptions.", "Frecuente y reversible: actuar de inmediato y ofrecer Deshacer evita interrupciones innecesarias.")),
  list(id = "q4", answer = "validation",
       situation = tr("Typing a student ID that must have 9 digits.", "Escribir un número de estudiante que debe tener 9 dígitos."),
       why = tr("Telling people about a format problem as they finish the field prevents a failed submit.", "Avisar de un problema de formato al terminar el campo evita un envío fallido."))
)
pattern_choices <- setNames(c("", "inline", "dialog", "undo", "validation"),
  c(tr("Choose a pattern", "Elige un patrón"), tr("Inline status message", "Mensaje de estado en línea"), tr("Confirmation dialog", "Diálogo de confirmación"),
    tr("Act now, offer Undo", "Actuar ya y ofrecer Deshacer"), tr("Inline validation", "Validación en línea")))

interaction_patterns_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Notice the feedback that follows an action.", "Fijarse en el feedback que sigue a una acción."),
                   tr("Compare interrupting and non-interrupting patterns.", "Comparar patrones que interrumpen y que no interrumpen."),
                   tr("Choose a pattern proportionate to the action's consequence.", "Elegir un patrón proporcionado a la consecuencia de la acción.")),
    concept = tr("Feedback should match the stakes. Interrupting people for every action trains them to click through dialogs; letting them undo is often safer and faster.",
                 "El feedback debe estar a la altura de lo que está en juego. Interrumpir en cada acción acostumbra a la gente a aceptar diálogos sin leerlos; permitir deshacer suele ser más seguro y rápido."),
    activity = tagList(
      navset_underline(
        nav_panel(tr("Saving", "Guardar"),
          div(class = "pt-3",
            p(tr("Save the same change with two kinds of feedback.", "Guarda el mismo cambio con dos tipos de feedback.")),
            layout_columns(col_widths = c(6, 6),
              div(actionButton(ns("inline"), tr("Save with inline status", "Guardar con estado en línea"), class = "btn-primary"), uiOutput(ns("inline_msg"))),
              div(actionButton(ns("dialog"), tr("Save with a dialog", "Guardar con un diálogo"), class = "btn-outline-success"))))),
        nav_panel(tr("Deleting", "Eliminar"),
          div(class = "pt-3",
            p(tr("Delete files with a confirmation dialog, or delete at once and undo.", "Elimina archivos con un diálogo de confirmación, o elimínalos al momento y deshaz.")),
            uiOutput(ns("files")),
            div(class = "d-flex flex-wrap gap-2 mt-2",
              actionButton(ns("del_confirm"), tr("Delete last file · confirm first", "Eliminar el último · confirmar antes"), class = "btn-outline-secondary"),
              actionButton(ns("del_undo"), tr("Delete last file · offer Undo", "Eliminar el último · ofrecer Deshacer"), class = "btn-outline-secondary"),
              actionButton(ns("restore"), tr("Restore all files", "Restaurar todos"), class = "btn-link")))),
        nav_panel(tr("Validating", "Validar"),
          div(class = "pt-3",
            p(tr("Enter a 9-digit student ID. Compare feedback while typing with feedback after submitting.", "Escribe un número de estudiante de 9 dígitos. Compara el feedback mientras escribes con el feedback tras enviar.")),
            radioButtons(ns("validation_mode"), NULL, setNames(c("live", "submit"), c(tr("Validate as I type", "Validar mientras escribo"), tr("Validate on submit", "Validar al enviar"))), inline = TRUE),
            textInput(ns("student_id"), tr("Student ID", "Número de estudiante"), placeholder = tr("e.g. 100123456", "p. ej. 100123456")),
            actionButton(ns("submit_id"), tr("Submit", "Enviar"), class = "btn-primary"),
            uiOutput(ns("validation_msg"))))),
      hr(),
      h4(tr("Choose the right pattern", "Elige el patrón adecuado")),
      lapply(pattern_quiz, function(q) div(class = "panel-soft mb-2", layout_columns(col_widths = c(7, 5),
        p(class = "mb-0 mt-1", q$situation), selectInput(ns(q$id), NULL, pattern_choices, width = "100%")))),
      actionButton(ns("check"), tr("Check my choices", "Comprobar mis elecciones"), class = "btn-primary"),
      uiOutput(ns("quiz_feedback")),
      p(class = "footnote mt-3", tr("These controls demonstrate interface patterns locally; nothing is saved or deleted.", "Estos controles muestran patrones de interfaz en local; no se guarda ni se elimina nada."))),
    reflection = tr("When would a confirmation dialog interrupt more than it helps? When is Undo not enough?",
                    "¿Cuándo interrumpe un diálogo de confirmación más de lo que ayuda? ¿Cuándo no basta con Deshacer?"))
}

interaction_patterns_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    observeEvent(input$inline, output$inline_msg <- renderUI(
      div(class = "alert alert-success mt-3 mb-0 py-2", role = "status", paste(tr("Saved ·", "Guardado ·"), format(Sys.time(), "%H:%M:%S")))))
    observeEvent(input$dialog, showModal(modalDialog(title = tr("Changes saved", "Cambios guardados"), tr("Your change has been saved.", "Tu cambio se ha guardado."),
                                                     easyClose = TRUE, footer = modalButton(tr("OK", "Aceptar")))))

    all_files <- c("brief.pdf", "persona-maria.png", "journey-map.fig", "interview-notes.docx", "sketches.zip")
    files <- reactiveVal(all_files)
    last_deleted <- reactiveVal(NULL)
    output$files <- renderUI({
      if (!length(files())) return(p(class = "muted", tr("No files left.", "No quedan archivos.")))
      tags$ul(class = "check-list", lapply(files(), tags$li))
    })
    observeEvent(input$del_confirm, {
      req(length(files()))
      showModal(modalDialog(title = tr("Delete file?", "¿Eliminar archivo?"),
        sprintf(tr("%s will be permanently deleted.", "%s se eliminará para siempre."), tail(files(), 1)),
        footer = tagList(modalButton(tr("Cancel", "Cancelar")), actionButton(ns("confirm_delete"), tr("Delete", "Eliminar"), class = "btn-danger"))))
    })
    observeEvent(input$confirm_delete, { files(head(files(), -1)); removeModal() })
    observeEvent(input$del_undo, {
      req(length(files()))
      last_deleted(tail(files(), 1)); files(head(files(), -1))
      showNotification(tagList(sprintf(tr("%s deleted. ", "%s eliminado. "), last_deleted()), actionLink(ns("undo"), tr("Undo", "Deshacer"))), duration = 6, id = ns("undo_note"))
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
      if (grepl("^[0-9]{9}$", value)) div(class = "alert alert-success mt-3 py-2", role = "status", tr("Looks right: 9 digits.", "Parece correcto: 9 dígitos."))
      else div(class = "alert alert-warning mt-3 py-2", role = "alert",
               sprintf(tr("A student ID has 9 digits; you have entered %d characters.", "Un número de estudiante tiene 9 dígitos; has escrito %d caracteres."), nchar(value)))
    })

    checked <- reactiveVal(FALSE)
    observeEvent(input$check, checked(TRUE))
    output$quiz_feedback <- renderUI({
      req(checked())
      right <- vapply(pattern_quiz, function(q) identical(input[[q$id]], q$answer), TRUE)
      div(class = "mt-3",
        div(class = if (all(right)) "alert alert-success" else "alert alert-info",
            sprintf(tr("%d of %d match the suggested pattern.", "%d de %d coinciden con el patrón sugerido."), sum(right), length(right))),
        tags$ul(class = "check-list", lapply(seq_along(pattern_quiz), function(i) tags$li(class = if (right[i]) "ok" else "todo", pattern_quiz[[i]]$why))))
    })

    reflect_server(tr("Interaction patterns", "Patrones de interacción"), input, output, session, function() {
      vapply(pattern_quiz, function(q) {
        chosen <- names(pattern_choices)[pattern_choices == (input[[q$id]] %||% "")]
        paste0(q$situation, " → ", if (length(chosen) && nzchar(input[[q$id]])) chosen else tr("(not answered)", "(sin responder)"))
      }, "")
    })
  })
}
