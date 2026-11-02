# UX writing: rewrite microcopy and compare readability and tone checks before and after.
writing_samples <- list(
  error = list(type = "error", title = tr("Error message", "Mensaje de error"),
               context = tr("Shown when someone types a phone number with spaces.", "Aparece cuando alguien escribe un teléfono con espacios."),
               text = "Error 403: Invalid input. Operation failed."),
  button = list(type = "button", title = tr("Button label", "Etiqueta de botón"),
                context = tr("Last button of a scholarship application form.", "Último botón de un formulario de solicitud de beca."),
                text = tr("Submit", "Enviar")),
  empty = list(type = "empty", title = tr("Empty state", "Estado vacío"),
               context = tr("A student opens ‘My courses’ before enrolling in any.", "Un estudiante abre «Mis cursos» antes de matricularse en alguno."),
               text = tr("No data.", "No hay datos.")),
  confirm = list(type = "confirm", title = tr("Confirmation dialog", "Diálogo de confirmación"),
                 context = tr("Before deleting a saved search.", "Antes de eliminar una búsqueda guardada."),
                 text = tr("Are you sure? Yes / No", "¿Está seguro? Sí / No")),
  hint = list(type = "hint", title = tr("Field hint", "Ayuda de campo"),
              context = tr("Under the password field when creating an account.", "Bajo el campo de contraseña al crear una cuenta."),
              text = tr("Password must comply with the security policy.", "La contraseña debe cumplir la política de seguridad."))
)

count_syllables <- function(word) {
  w <- tolower(gsub("[^[:alpha:]]", "", word))
  if (!nzchar(w)) return(0)
  if (identical(LANG, "es")) return(max(1, lengths(regmatches(w, gregexpr("[aeiouáéíóúü]+", w)))))
  w <- sub("(?:[^laeiouy]es|ed|[^laeiouy]e)$", "", w, perl = TRUE)
  max(1, lengths(regmatches(w, gregexpr("[aeiouy]+", w))))
}

# Flesch reading ease (English) or Fernández-Huerta (Spanish): higher is easier, 60–80 is plain language.
readability <- function(text) {
  words <- regmatches(text, gregexpr("[[:alpha:]áéíóúüñÁÉÍÓÚÜÑ']+", text))[[1]]
  if (!length(words)) return(list(words = 0, ease = NA_real_))
  sentences <- max(1, lengths(regmatches(text, gregexpr("[.!?]+", text))))
  syl <- sum(vapply(words, count_syllables, 1))
  n <- length(words)
  ease <- if (identical(LANG, "es")) 206.84 - 0.60 * (100 * syl / n) - 1.02 * (100 * sentences / n)
          else 206.835 - 1.015 * (n / sentences) - 84.6 * (syl / n)
  list(words = n, ease = round(max(0, min(100, ease))))
}

writing_checks <- function(text, type) {
  x <- tolower(text)
  has <- function(words) any(vapply(words, function(w) grepl(paste0("\\b", w, "\\b"), x, perl = TRUE), TRUE))
  n <- readability(text)$words
  out <- list(
    list(ok = !has(tr(c("invalid", "illegal", "wrong", "failed", "error", "must", "forbidden", "denied"), c("inválido", "inválida", "incorrecto", "incorrecta", "error", "fallo", "debe", "prohibido", "denegado"))),
         text = tr("No blaming or alarming words (invalid, failed, must…)", "Sin palabras culpabilizadoras o alarmantes (inválido, error, debe…)")),
    list(ok = !grepl("[0-9]{3}", x) && !has(tr(c("input", "operation", "execute", "null", "exception", "data", "policy"), c("input", "operación", "ejecutar", "null", "excepción", "datos", "política"))),
         text = tr("No codes or system jargon", "Sin códigos ni jerga del sistema")),
    list(ok = !grepl("[A-Z]{4,}", text) && !grepl("!", text, fixed = TRUE), text = tr("Calm tone: no shouting capitals or exclamation marks", "Tono tranquilo: sin mayúsculas gritonas ni exclamaciones")))
  extra <- switch(type,
    error = list(list(ok = has(tr(c("use", "try", "enter", "check", "add", "remove", "type", "choose"), c("usa", "prueba", "escribe", "revisa", "añade", "quita", "elige", "introduce", "comprueba"))),
                      text = tr("Says how to fix it, with a verb such as ‘enter’ or ‘remove’", "Dice cómo solucionarlo, con un verbo como «escribe» o «quita»"))),
    button = list(list(ok = n >= 1 && n <= 4, text = tr("Button label is 1–4 words", "La etiqueta del botón tiene 1–4 palabras")),
                  list(ok = !has(tr(c("ok", "yes", "no", "submit", "click here", "continue"), c("aceptar", "sí", "no", "enviar", "haga clic", "continuar"))),
                       text = tr("Specific action, not a generic label (OK, Submit, Yes)", "Acción concreta, no una etiqueta genérica (Aceptar, Enviar, Sí)"))),
    empty = list(list(ok = n >= 6, text = tr("Explains why it is empty and what to do next", "Explica por qué está vacío y qué hacer a continuación"))),
    confirm = list(list(ok = !has(tr(c("are you sure", "yes", "no"), c("está seguro", "estás seguro", "sí", "no"))),
                        text = tr("Names the consequence and the action instead of ‘Are you sure? Yes/No’", "Nombra la consecuencia y la acción en lugar de «¿Está seguro? Sí/No»"))),
    hint = list(list(ok = grepl("[0-9]", x), text = tr("States the actual rules (for example a number of characters)", "Indica las reglas concretas (por ejemplo, un número de caracteres)"))),
    list())
  c(out, extra)
}

ux_writing_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Write microcopy that is clear, concise and useful.", "Escribir microtextos claros, concisos y útiles."),
                   tr("Turn system messages into human guidance.", "Convertir mensajes del sistema en orientación humana."),
                   tr("Use readability and tone checks as evidence, not as goals.", "Usar las métricas de legibilidad y tono como evidencia, no como objetivos.")),
    concept = tr("Interface words are interface design. Good microcopy tells people where they are, what will happen, and how to recover, in their own vocabulary and in as few words as needed.",
                 "Las palabras de la interfaz son diseño de interfaz. Un buen microtexto dice a la gente dónde está, qué va a pasar y cómo recuperarse, con su vocabulario y con las palabras justas."),
    activity = tagList(
      p(tr("Challenge · Rewrite five pieces of microcopy from a university portal.", "Reto · Reescribe cinco microtextos de un portal universitario.")),
      layout_columns(col_widths = c(6, 6),
        div(
          radioButtons(ns("sample"), tr("Microcopy", "Microtexto"), setNames(names(writing_samples), vapply(writing_samples, `[[`, "", "title")), inline = TRUE),
          uiOutput(ns("original")),
          textAreaInput(ns("rewrite"), tr("Your rewrite", "Tu versión"), rows = 3, width = "100%"),
          actionButton(ns("save"), tr("Save rewrite", "Guardar versión"), class = "btn-primary")),
        div(
          h4(class = "h6", tr("Before and after", "Antes y después")),
          tableOutput(ns("compare")),
          div(class = "panel-soft", span(class = "eyebrow", tr("CHECKS ON YOUR REWRITE", "COMPROBACIONES DE TU VERSIÓN")), uiOutput(ns("checks"))))),
      h4(class = "mt-4", tr("My rewrites", "Mis versiones")),
      tableOutput(ns("saved"))),
    reflection = tr("Which rewrite was hardest, and what did you have to know about the user or the system to write it well?",
                    "¿Qué versión te costó más y qué necesitabas saber del usuario o del sistema para escribirla bien?"))
}

ux_writing_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    saved <- reactiveVal(setNames(rep("", length(writing_samples)), names(writing_samples)))
    sample <- reactive(writing_samples[[input$sample]])

    output$original <- renderUI(div(class = "mock mb-3",
      div(class = "mock-bar", sample()$title), p(class = "footnote", sample()$context),
      p(class = "mb-0", tags$strong(sample()$text))))
    observeEvent(input$sample, updateTextAreaInput(session, "rewrite", value = saved()[[input$sample]]))

    metrics_row <- function(label, text) {
      r <- readability(text); ch <- writing_checks(text, sample()$type)
      data.frame(a = label, b = r$words, c = if (is.na(r$ease)) "–" else as.character(r$ease), d = sprintf("%d/%d", sum(vapply(ch, `[[`, TRUE, "ok")), length(ch)))
    }
    output$compare <- renderTable({
      x <- metrics_row(tr("Original", "Original"), sample()$text)
      if (nzchar(trimws(input$rewrite %||% ""))) x <- rbind(x, metrics_row(tr("Yours", "Tuya"), input$rewrite))
      setNames(x, c("", tr("Words", "Palabras"), tr("Reading ease", "Facilidad de lectura"), tr("Checks passed", "Comprobaciones")))
    }, width = "100%")
    output$checks <- renderUI({
      t <- trimws(input$rewrite %||% "")
      if (!nzchar(t)) return(p(class = "footnote mb-0", tr("Write a rewrite to see the checks.", "Escribe una versión para ver las comprobaciones.")))
      tagList(check_list(writing_checks(t, sample()$type)),
              p(class = "footnote mb-0 mt-2", tr("Reading ease: Flesch (0–100, higher is easier; 60+ is plain language). Short texts give unstable scores.",
                                                  "Facilidad de lectura: Fernández-Huerta (0–100, más alto es más fácil; 60+ es lenguaje claro). Los textos cortos dan puntuaciones inestables.")))
    })
    observeEvent(input$save, {
      s <- saved(); s[[input$sample]] <- trimws(input$rewrite %||% ""); saved(s)
    })
    output$saved <- renderTable({
      s <- saved(); keep <- nzchar(s)
      if (!any(keep)) return(setNames(data.frame(tr("No rewrites saved yet.", "Todavía no has guardado versiones.")), " "))
      data.frame(check.names = FALSE,
        `Type` = vapply(writing_samples[keep], `[[`, "", "title"), Before = vapply(writing_samples[keep], `[[`, "", "text"), After = unname(s[keep])) |>
        setNames(c(tr("Type", "Tipo"), tr("Before", "Antes"), tr("After", "Después")))
    }, striped = TRUE, width = "100%")

    lines <- function() {
      s <- saved()
      unlist(lapply(names(writing_samples), function(k) {
        if (!nzchar(s[[k]])) return(NULL)
        ch <- writing_checks(s[[k]], writing_samples[[k]]$type)
        c(paste0(writing_samples[[k]]$title, ":"), paste0(tr("   Before: ", "   Antes: "), writing_samples[[k]]$text), paste0(tr("   After: ", "   Después: "), s[[k]]),
          sprintf(tr("   Checks passed: %d/%d", "   Comprobaciones: %d/%d"), sum(vapply(ch, `[[`, TRUE, "ok")), length(ch)))
      })) %||% tr("(no rewrites)", "(sin versiones)")
    }
    observeEvent(input$example, {
      saved(c(error = tr("Enter the phone number without spaces, for example 612345678.", "Escribe el teléfono sin espacios, por ejemplo 612345678."),
              button = tr("Send application", "Enviar solicitud"),
              empty = tr("You are not enrolled in any course yet. Browse this term's courses to get started.", "Todavía no estás matriculado en ningún curso. Consulta los cursos de este semestre para empezar."),
              confirm = tr("Delete the saved search ‘UX jobs Madrid’? You can't undo this. Delete · Keep it", "¿Eliminar la búsqueda guardada «Empleo UX Madrid»? No se puede deshacer. Eliminar · Conservarla"),
              hint = tr("Use 12 or more characters. Spaces and symbols are fine.", "Usa 12 caracteres o más. Puedes usar espacios y símbolos.")))
      updateRadioButtons(session, "sample", selected = "error")
      updateTextAreaInput(session, "rewrite", value = tr("Enter the phone number without spaces, for example 612345678.", "Escribe el teléfono sin espacios, por ejemplo 612345678."))
      example_reflection(session, tr("The password hint was hardest: I had to find out the real rules from the security team. Writing good copy often means fixing the policy, not only the words.",
                                     "La ayuda de la contraseña fue la más difícil: tuve que averiguar las reglas reales con el equipo de seguridad. Escribir bien a menudo implica cambiar la política, no solo las palabras."))
    })

    reflect_server(tr("UX writing", "Escritura UX"), input, output, session, lines)
  })
}

lab_content$writing <- list(
  theory = list(
    list(title = tr("Clear, concise, useful", "Claro, conciso, útil"), body = c(
      tr("Torrey Podmajersky summarises UX writing in three qualities: <strong>purposeful</strong> (it serves the user's goal and the organisation's), <strong>concise</strong> (no more words than needed) and <strong>conversational</strong> (it sounds like a helpful person). People do not read interfaces, they scan them: front-load the key words.",
         "Torrey Podmajersky resume la escritura UX en tres cualidades: <strong>con propósito</strong> (sirve al objetivo del usuario y al de la organización), <strong>concisa</strong> (sin más palabras de las necesarias) y <strong>conversacional</strong> (suena como una persona que ayuda). La gente no lee las interfaces, las escanea: pon delante las palabras clave."))),
    list(title = tr("Error messages that help", "Mensajes de error que ayudan"), body = c(
      tr("A helpful error message says <strong>what happened</strong>, <strong>why</strong> (if useful) and <strong>how to fix it</strong>, without blaming the person. Place it next to the problem, keep what was typed, and never show internal codes alone. Better still, prevent the error: accept phone numbers with spaces.",
         "Un mensaje de error útil dice <strong>qué ha pasado</strong>, <strong>por qué</strong> (si sirve) y <strong>cómo solucionarlo</strong>, sin culpar a la persona. Colócalo junto al problema, conserva lo escrito y no muestres nunca solo códigos internos. Mejor aún, evita el error: acepta teléfonos con espacios."))),
    list(title = tr("Buttons, voice and tone", "Botones, voz y tono"), body = c(
      tr("Button labels should name the action and its object (‘Send application’, ‘Delete search’), so they make sense out of context, for example when a screen reader lists them. <strong>Voice</strong> is the product's consistent personality; <strong>tone</strong> adapts it to the moment: lighter in a success message, plain and calm in an error.",
         "Las etiquetas de los botones deben nombrar la acción y su objeto («Enviar solicitud», «Eliminar búsqueda»), para que tengan sentido fuera de contexto, por ejemplo cuando un lector de pantalla las enumera. La <strong>voz</strong> es la personalidad constante del producto; el <strong>tono</strong> la adapta al momento: más ligero en un mensaje de éxito, sencillo y tranquilo en un error."),
      tr("Readability formulas such as Flesch or Fernández-Huerta estimate difficulty from sentence and word length. They are a quick signal, not a goal: test important copy with users, for example with a highlighter test or comprehension questions.",
         "Las fórmulas de legibilidad como Flesch o Fernández-Huerta estiman la dificultad a partir de la longitud de frases y palabras. Son una señal rápida, no un objetivo: prueba los textos importantes con usuarios, por ejemplo con un test del rotulador o preguntas de comprensión.")))),
  mistakes = c(
    tr("Generic buttons (‘OK’, ‘Submit’, ‘Yes/No’) that force people to read the whole dialog.", "Botones genéricos («Aceptar», «Enviar», «Sí/No») que obligan a leer todo el diálogo."),
    tr("Humour in error messages, when people are already frustrated.", "Humor en los mensajes de error, cuando la gente ya está frustrada."),
    tr("Writing the copy last, after the layout is fixed.", "Escribir los textos al final, cuando la maquetación ya está cerrada."),
    tr("Inconsistent terms for the same thing (‘course’, ‘module’, ‘subject’).", "Términos distintos para lo mismo («curso», «módulo», «asignatura»).")),
  reading = c(
    "Podmajersky, T. (2019). <em>Strategic Writing for UX</em>. O'Reilly.",
    "Yifrah, K. (2017). <em>Microcopy: The Complete Guide</em>. Nemala.",
    "Richards, S. (2017). <em>Content Design</em>. Content Design London.",
    "GOV.UK Design System. <em>Error message</em>. design-system.service.gov.uk"),
  quiz = list(
    list(q = tr("Which error message is best?", "¿Qué mensaje de error es mejor?"),
         options = c(tr("Invalid date.", "Fecha no válida."), tr("Enter the date as day/month/year, for example 21/03/2027.", "Escribe la fecha como día/mes/año, por ejemplo 21/03/2027."), tr("ERROR: DATE_FORMAT", "ERROR: DATE_FORMAT")),
         answer = 2, why = tr("It says how to fix the problem, with an example, in plain words.", "Dice cómo solucionar el problema, con un ejemplo, en palabras sencillas.")),
    list(q = tr("Why prefer ‘Delete search’ to ‘Yes’ in a confirmation dialog?", "¿Por qué es mejor «Eliminar búsqueda» que «Sí» en un diálogo de confirmación?"),
         options = c(tr("It is shorter", "Es más corto"), tr("It names the action, so it is clear without reading the question", "Nombra la acción, así que se entiende sin leer la pregunta"), tr("It is more polite", "Es más educado")),
         answer = 2, why = tr("Specific labels reduce errors and work better with screen readers.", "Las etiquetas concretas reducen errores y funcionan mejor con lectores de pantalla.")),
    list(q = tr("What is the difference between voice and tone?", "¿Qué diferencia hay entre voz y tono?"),
         options = c(tr("There is none", "Ninguna"), tr("Voice is constant personality; tone adapts to the situation", "La voz es una personalidad constante; el tono se adapta a la situación"), tr("Tone is for marketing, voice for the interface", "El tono es para marketing y la voz para la interfaz")),
         answer = 2, why = tr("A product keeps one voice but changes tone between a success, a warning and an error.", "Un producto mantiene una voz pero cambia el tono entre un éxito, un aviso y un error.")))
)
