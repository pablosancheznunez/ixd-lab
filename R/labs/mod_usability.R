heuristics <- c(
  tr("Visibility of system status", "Visibilidad del estado del sistema"),
  tr("Match between system and the real world", "Relación entre el sistema y el mundo real"),
  tr("User control and freedom", "Control y libertad del usuario"),
  tr("Consistency and standards", "Consistencia y estándares"),
  tr("Error prevention", "Prevención de errores"),
  tr("Recognition rather than recall", "Reconocer mejor que recordar"),
  tr("Flexibility and efficiency of use", "Flexibilidad y eficiencia de uso"),
  tr("Aesthetic and minimalist design", "Diseño estético y minimalista"),
  tr("Help users recognise, diagnose, and recover from errors", "Ayudar a reconocer, diagnosticar y recuperarse de errores"),
  tr("Help and documentation", "Ayuda y documentación")
)

severity_levels <- setNames(0:4, c(tr("0 · Not a problem", "0 · No es un problema"), tr("1 · Cosmetic", "1 · Estético"),
                                   tr("2 · Minor", "2 · Menor"), tr("3 · Major", "3 · Grave"), tr("4 · Catastrophe", "4 · Catastrófico")))

usability_scenarios <- list(
  booking = list(
    title = tr("Room booking form", "Formulario de reserva de sala"),
    what = tr("After pressing Book, the form clears itself. No message appears and no email arrives for several minutes.",
              "Al pulsar Reservar, el formulario se vacía. No aparece ningún mensaje y no llega ningún correo durante varios minutos."),
    likely = heuristics[c(1, 9)],
    mock = function() div(class = "mock", div(class = "mock-bar", tr("library.example / book-a-room", "biblioteca.example / reservar-sala")),
      tags$label(tr("Room", "Sala")), div(class = "form-control mb-2", tr("Group study room 3", "Sala de trabajo en grupo 3")),
      tags$label(tr("Date", "Fecha")), div(class = "form-control mb-3", "12/03"),
      span(class = "btn btn-secondary btn-sm", tr("Book", "Reservar")))),
  search = list(
    title = tr("Course search", "Búsqueda de cursos"),
    what = tr("Searching for 'design' returns: 'Query yielded 0 entities (ERR_IDX_204)'. There are no suggestions or links.",
              "Al buscar «diseño» aparece: «Query yielded 0 entities (ERR_IDX_204)». No hay sugerencias ni enlaces."),
    likely = heuristics[c(2, 9)],
    mock = function() div(class = "mock", div(class = "mock-bar", tr("university.example / courses", "universidad.example / cursos")),
      div(class = "form-control mb-2", tr("design", "diseño")),
      div(class = "alert alert-secondary py-2 mb-0 footnote", "Query yielded 0 entities (ERR_IDX_204)"))),
  password = list(
    title = tr("Password reset", "Cambio de contraseña"),
    what = tr("One rule is broken, so every field is cleared. The rules only appear after the error, in grey 11px text.",
              "Si se incumple una regla, se borran todos los campos. Las reglas solo aparecen después del error, en texto gris de 11 px."),
    likely = heuristics[c(5, 3, 6)],
    mock = function() div(class = "mock", div(class = "mock-bar", tr("account.example / reset", "cuenta.example / cambiar")),
      tags$label(tr("New password", "Nueva contraseña")), div(class = "form-control mb-2", HTML("&nbsp;")),
      tags$label(tr("Repeat password", "Repite la contraseña")), div(class = "form-control mb-2", HTML("&nbsp;")),
      p(style = "font-size:11px;color:#9a9a9a", tr("Password must include 12 characters, one symbol and no repeated letters.", "La contraseña debe tener 12 caracteres, un símbolo y ninguna letra repetida.")),
      span(class = "btn btn-secondary btn-sm", tr("Save", "Guardar"))))
)

usability_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Inspect an interface against a usability heuristic.", "Inspeccionar una interfaz con una heurística de usabilidad."),
                   tr("Describe an observable issue rather than a preference.", "Describir un problema observable, no una preferencia."),
                   tr("Rate severity and suggest a testable change.", "Valorar la gravedad y proponer un cambio que se pueda probar.")),
    concept = tr("A heuristic evaluation is an expert review: it points to likely problems quickly and cheaply, but only testing with real users shows whether people actually struggle.",
                 "Una evaluación heurística es una revisión experta: señala problemas probables de forma rápida y barata, pero solo las pruebas con usuarios reales muestran si la gente tiene dificultades de verdad."),
    activity = tagList(
      layout_columns(col_widths = c(6, 6),
        div(
          radioButtons(ns("scenario"), tr("Interface to review", "Interfaz que revisar"), setNames(names(usability_scenarios), vapply(usability_scenarios, `[[`, "", "title"))),
          uiOutput(ns("mock")),
          uiOutput(ns("what"))),
        div(
          selectInput(ns("heuristic"), tr("Heuristic", "Heurística"), heuristics),
          selectInput(ns("severity"), tr("Severity", "Gravedad"), severity_levels, selected = 2),
          textAreaInput(ns("issue"), tr("Issue: what happens and who it affects", "Problema: qué ocurre y a quién afecta"), rows = 3, width = "100%"),
          textAreaInput(ns("fix"), tr("Recommendation: a change you could test", "Recomendación: un cambio que podrías probar"), rows = 2, width = "100%"),
          actionButton(ns("add"), tr("Add finding", "Añadir hallazgo"), class = "btn-primary"),
          uiOutput(ns("feedback")))),
      h4(class = "mt-4", tr("Findings", "Hallazgos")),
      tableOutput(ns("findings")),
      downloadButton(ns("export"), tr("Export findings report", "Exportar informe de hallazgos"), class = "btn-outline-success")),
    reflection = tr("Which part of your findings is evidence from the interface, and which part is your interpretation?",
                    "¿Qué parte de tus hallazgos es evidencia de la interfaz y qué parte es tu interpretación?"))
}

usability_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    findings <- reactiveVal(data.frame(interface = character(), heuristic = character(), severity = integer(), issue = character(), fix = character()))
    feedback <- reactiveVal(NULL)

    output$mock <- renderUI(usability_scenarios[[input$scenario]]$mock())
    output$what <- renderUI(p(class = "footnote mt-2", tags$strong(tr("What happens: ", "Qué ocurre: ")), usability_scenarios[[input$scenario]]$what))

    observeEvent(input$add, {
      issue <- trimws(input$issue); fix <- trimws(input$fix)
      if (nchar(issue) < 20 || nchar(fix) < 10) {
        return(feedback(div(class = "alert alert-warning mt-3", tr("Add a little more detail: describe the moment, its effect on the person, and one change.",
                                                                   "Añade algo más de detalle: describe el momento, su efecto en la persona y un cambio."))))
      }
      sc <- usability_scenarios[[input$scenario]]
      findings(rbind(findings(), data.frame(interface = sc$title, heuristic = input$heuristic, severity = as.integer(input$severity), issue = issue, fix = fix)))
      updateTextAreaInput(session, "issue", value = ""); updateTextAreaInput(session, "fix", value = "")
      feedback(if (input$heuristic %in% sc$likely) {
        div(class = "alert alert-success mt-3", tags$strong(tr("Finding added. ", "Hallazgo añadido. ")),
            tr("Reviewers often link this interface to ", "Los revisores suelen relacionar esta interfaz con "), tolower(input$heuristic), tr(" too.", " también."))
      } else {
        div(class = "alert alert-info mt-3", tags$strong(tr("Finding added. ", "Hallazgo añadido. ")),
            tr("Reviewers often link this interface to ", "Los revisores suelen relacionar esta interfaz con "), paste(tolower(sc$likely), collapse = tr(" or ", " o ")),
            tr(". Your choice can still be valid: does your note explain the connection?", ". Tu elección puede ser válida igualmente: ¿explica tu nota la relación?"))
      })
    })
    output$feedback <- renderUI(feedback())

    output$findings <- renderTable({
      x <- findings()
      if (!nrow(x)) return(setNames(data.frame(tr("No findings yet.", "Todavía no hay hallazgos.")), " "))
      x <- x[order(-x$severity), ]
      setNames(x, c(tr("Interface", "Interfaz"), tr("Heuristic", "Heurística"), tr("Severity", "Gravedad"), tr("Issue", "Problema"), tr("Recommendation", "Recomendación")))
    }, striped = TRUE, width = "100%")

    report <- function() {
      x <- findings()
      if (!nrow(x)) return(tr("(no findings)", "(sin hallazgos)"))
      x <- x[order(-x$severity), ]
      unlist(lapply(seq_len(nrow(x)), function(i) c(sprintf(tr("%d. [Severity %d] %s · %s", "%d. [Gravedad %d] %s · %s"), i, x$severity[i], x$interface[i], x$heuristic[i]),
                                                    paste(tr("   Issue:", "   Problema:"), x$issue[i]), paste(tr("   Recommendation:", "   Recomendación:"), x$fix[i]))))
    }
    output$export <- downloadHandler(filename = function() "ixd-usability-findings.txt",
      content = function(file) writeLines(enc2utf8(c(tr("IxD Lab · Heuristic evaluation findings", "IxD Lab · Hallazgos de la evaluación heurística"), format(Sys.Date()), "", report())), file, useBytes = TRUE))
    reflect_server(tr("Usability", "Usabilidad"), input, output, session, report)
  })
}
