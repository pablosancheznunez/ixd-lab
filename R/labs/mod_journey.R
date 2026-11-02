# Journey mapping: stages, emotional curve, pain points and opportunities for one scenario.
journey_stages <- c(tr("Discover", "Descubrir"), tr("Apply", "Solicitar"), tr("Get accepted", "Ser admitido"), tr("Pay and enrol", "Pagar y matricularse"), tr("First week", "Primera semana"))
journey_example <- list(
  emotion = c(1, -1, 2, -2, 0),
  touch = c(tr("Search engine, programme web page", "Buscador, web del programa"), tr("Online application portal", "Portal de solicitud"), tr("Email with admission letter", "Correo con la carta de admisión"),
            tr("Payment gateway, enrolment form", "Pasarela de pago, formulario de matrícula"), tr("Campus, virtual classroom", "Campus, aula virtual")),
  pain = c("", tr("Asked to upload the same documents twice.", "Le piden subir los mismos documentos dos veces."), "",
           tr("International card rejected; no one answers the phone in her time zone.", "Rechazan su tarjeta internacional; nadie contesta al teléfono en su franja horaria."),
           tr("Cannot find where the first class is or which readings to do.", "No encuentra dónde es la primera clase ni qué lecturas hacer.")),
  opportunity = c("", tr("Reuse documents from the profile.", "Reutilizar los documentos del perfil."), "",
                  tr("Offer bank transfer and a chat in several time zones.", "Ofrecer transferencia y un chat en varias franjas horarias."),
                  tr("A personalised ‘first week’ page with timetable, rooms and readings.", "Una página personalizada de «primera semana» con horario, aulas y lecturas."))
)

journey_ui <- function(id) {
  ns <- NS(id)
  stage_card <- function(i) div(class = "journey-stage",
    span(class = "eyebrow", paste0(i, " · ", journey_stages[i])),
    sliderInput(ns(paste0("emotion_", i)), tr("How does she feel?", "¿Cómo se siente?"), min = -2, max = 2, value = 0, step = 1, ticks = FALSE, width = "100%"),
    textInput(ns(paste0("touch_", i)), tr("Touchpoints", "Puntos de contacto"), width = "100%"),
    textAreaInput(ns(paste0("pain_", i)), tr("Pain point", "Punto de dolor"), rows = 2, width = "100%"),
    textAreaInput(ns(paste0("opp_", i)), tr("Opportunity", "Oportunidad"), rows = 2, width = "100%"))
  lab_section(ns,
    objectives = c(tr("Map an end-to-end experience across stages and channels.", "Mapear una experiencia completa a través de etapas y canales."),
                   tr("Locate the moments that matter on an emotional curve.", "Localizar los momentos clave en una curva emocional."),
                   tr("Turn pain points into design opportunities.", "Convertir puntos de dolor en oportunidades de diseño.")),
    concept = tr("A journey map shows the whole experience from the person's point of view, across every channel the organisation owns or not. Its lowest points are where design can make the biggest difference.",
                 "Un mapa de recorrido muestra toda la experiencia desde el punto de vista de la persona, en todos los canales, sean o no de la organización. Sus puntos más bajos son donde el diseño puede marcar más la diferencia."),
    activity = tagList(
      p(tr("Challenge · Map the journey of Aisha, an international student, from discovering a master's programme to her first week. Use the research notes below.",
           "Reto · Mapea el recorrido de Aisha, una estudiante internacional, desde que descubre un máster hasta su primera semana. Usa las notas de investigación de abajo.")),
      div(class = "panel-soft footnote mb-3",
        tags$strong(tr("Research notes (simulated): ", "Notas de investigación (simuladas): ")),
        tr("Found the programme through a ranking and liked the course page. Had to upload her degree certificate twice. Was thrilled to receive the admission email. Her card was rejected by the payment page and the helpline was closed in her time zone. In the first week she did not know where her classes were.",
           "Encontró el programa en un ranking y le gustó la página del máster. Tuvo que subir dos veces su título. Le hizo mucha ilusión recibir el correo de admisión. La pasarela de pago rechazó su tarjeta y el teléfono de ayuda estaba cerrado en su franja horaria. En la primera semana no sabía dónde eran sus clases.")),
      div(class = "journey-grid", lapply(seq_along(journey_stages), stage_card)),
      layout_columns(col_widths = c(8, 4),
        plotOutput(ns("curve"), height = "300px"),
        div(class = "panel-soft", span(class = "eyebrow", tr("MAP CHECKS", "COMPROBACIONES")), uiOutput(ns("checks"))))),
    reflection = tr("Which single opportunity would you prioritise, and what evidence would you collect to confirm it matters most?",
                    "¿Qué oportunidad priorizarías y qué evidencia recogerías para confirmar que es la más importante?"))
}

journey_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    n <- length(journey_stages)
    emotions <- reactive(vapply(seq_len(n), function(i) as.numeric(input[[paste0("emotion_", i)]] %||% 0), 0))
    pains <- reactive(vapply(seq_len(n), function(i) trimws(input[[paste0("pain_", i)]] %||% ""), ""))
    opps <- reactive(vapply(seq_len(n), function(i) trimws(input[[paste0("opp_", i)]] %||% ""), ""))

    output$curve <- renderPlot({
      e <- emotions(); p <- pains()
      ixd_par()
      plot(seq_len(n), e, type = "n", ylim = c(-2.4, 2.4), xlim = c(.7, n + .3), xaxt = "n", yaxt = "n", xlab = "", ylab = tr("Emotion", "Emoción"))
      axis(1, at = seq_len(n), labels = journey_stages, tick = FALSE, cex.axis = .85)
      axis(2, at = c(-2, 0, 2), labels = c("-2", "0", "+2"), tick = FALSE)
      abline(h = 0, col = "#e3e0d7", lty = 2)
      xs <- seq(1, n, length.out = 200)
      graphics::lines(spline(seq_len(n), e, xout = xs), col = ixd_green, lwd = 3)
      points(seq_len(n), e, pch = 21, cex = 2.2, bg = ifelse(e < 0, ixd_red, ifelse(e > 0, ixd_green, "#bdb9ae")), col = "white", lwd = 2)
      has_pain <- nzchar(p)
      if (any(has_pain)) text(which(has_pain), e[has_pain] - .45, tr("pain", "dolor"), col = ixd_red, cex = .8, font = 2)
    }, res = 96)

    checks <- reactive({
      e <- emotions(); p <- pains(); o <- opps()
      low <- which(e == min(e))
      list(
        list(ok = length(unique(e)) > 2, text = tr("The curve has ups and downs: a flat line hides the moments that matter", "La curva tiene subidas y bajadas: una línea plana oculta los momentos clave")),
        list(ok = min(e) < 0 && all(nzchar(p[low])), text = tr("The lowest moment has a pain point", "El momento más bajo tiene un punto de dolor")),
        list(ok = sum(nzchar(p)) >= 2, text = tr("At least two pain points identified", "Al menos dos puntos de dolor identificados")),
        list(ok = sum(nzchar(p)) > 0 && all(nzchar(o[nzchar(p)])), text = tr("Every pain point has an opportunity", "Cada punto de dolor tiene una oportunidad")),
        list(ok = any(e > 0), text = tr("A positive moment to protect (a ‘moment of delight’)", "Un momento positivo que proteger (un «momento de deleite»)")))
    })
    output$checks <- renderUI(check_list(checks()))

    lines <- function() {
      e <- emotions(); p <- pains(); o <- opps()
      c(unlist(lapply(seq_len(n), function(i) c(sprintf("%d. %s (%+d)", i, journey_stages[i], as.integer(e[i])),
          paste0(tr("   Touchpoints: ", "   Puntos de contacto: "), input[[paste0("touch_", i)]] %||% ""),
          paste0(tr("   Pain point: ", "   Punto de dolor: "), p[i]), paste0(tr("   Opportunity: ", "   Oportunidad: "), o[i])))), "",
        tr("Map checks:", "Comprobaciones:"), vapply(checks(), function(ch) paste(if (ch$ok) "[ok]" else tr("[review]", "[revisar]"), ch$text), ""))
    }
    observeEvent(input$example, {
      for (i in seq_len(n)) {
        updateSliderInput(session, paste0("emotion_", i), value = journey_example$emotion[i])
        updateTextInput(session, paste0("touch_", i), value = journey_example$touch[i])
        updateTextAreaInput(session, paste0("pain_", i), value = journey_example$pain[i])
        updateTextAreaInput(session, paste0("opp_", i), value = journey_example$opportunity[i])
      }
      example_reflection(session, tr("Payment is the lowest point and can stop the enrolment altogether, so I would fix it first. I would check payment failure rates by country and interview a few international students who enrolled late.",
                                     "El pago es el punto más bajo y puede frenar la matrícula por completo, así que lo resolvería primero. Revisaría la tasa de pagos fallidos por país y entrevistaría a algunos estudiantes internacionales que se matricularon tarde."))
    })

    reflect_server(tr("Journey mapping", "Mapas de recorrido"), input, output, session, lines)
  })
}

lab_content$journey <- list(
  theory = list(
    list(title = tr("Anatomy of a journey map", "Anatomía de un mapa de recorrido"), body = c(
      tr("A journey map has a <strong>persona</strong> and a <strong>scenario</strong> with a goal, a sequence of <strong>stages</strong>, and lanes for actions, touchpoints, thoughts, emotions, pain points and opportunities. It is drawn from the person's perspective and should be based on research, like a persona.",
         "Un mapa de recorrido tiene una <strong>persona</strong> y un <strong>escenario</strong> con un objetivo, una secuencia de <strong>etapas</strong> y carriles para acciones, puntos de contacto, pensamientos, emociones, puntos de dolor y oportunidades. Se dibuja desde la perspectiva de la persona y, como una persona, debe basarse en investigación."))),
    list(title = tr("Current state vs future state", "Estado actual frente a estado futuro"), body = c(
      tr("A <strong>current-state</strong> map documents the experience as it is today, to find problems. A <strong>future-state</strong> map imagines the improved experience, to align a team around a vision. Do the first before the second.",
         "Un mapa del <strong>estado actual</strong> documenta la experiencia tal como es hoy, para encontrar problemas. Uno del <strong>estado futuro</strong> imagina la experiencia mejorada, para alinear al equipo en torno a una visión. Haz el primero antes que el segundo."))),
    list(title = tr("Service blueprints: what happens backstage", "Service blueprints: lo que pasa entre bambalinas"), body = c(
      tr("A <strong>service blueprint</strong> (Shostack, 1984) adds what the organisation does below the ‘line of visibility’: frontstage staff, backstage processes and support systems. Many pain points, like a rejected card, are caused backstage, so the fix is often a process, not a screen.",
         "Un <strong>service blueprint</strong> (Shostack, 1984) añade lo que hace la organización por debajo de la «línea de visibilidad»: personal de cara al público, procesos internos y sistemas de apoyo. Muchos puntos de dolor, como una tarjeta rechazada, se originan entre bambalinas, así que la solución suele ser un proceso, no una pantalla."),
      tr("The <strong>peak–end rule</strong> (Kahneman) suggests people judge an experience mostly by its most intense moment and its end. Design the peaks and the ending deliberately.",
         "La <strong>regla del pico y el final</strong> (Kahneman) sugiere que la gente juzga una experiencia sobre todo por su momento más intenso y por su final. Diseña los picos y el cierre de forma deliberada.")))),
  mistakes = c(
    tr("Mapping only the screens you own and ignoring email, phone or physical steps.", "Mapear solo las pantallas propias e ignorar el correo, el teléfono o los pasos físicos."),
    tr("Drawing the map from the organisation's process instead of the person's experience.", "Dibujar el mapa desde el proceso de la organización en lugar de la experiencia de la persona."),
    tr("A beautiful poster that leads to no decisions: end with prioritised opportunities.", "Un póster precioso que no lleva a ninguna decisión: termina con oportunidades priorizadas."),
    tr("Inventing emotions without evidence from research.", "Inventar emociones sin evidencia de investigación.")),
  reading = c(
    "Kalbach, J. (2020). <em>Mapping Experiences</em> (2nd ed.). O'Reilly.",
    "Shostack, G. L. (1984). Designing services that deliver. <em>Harvard Business Review, 62</em>(1), 133–139.",
    "Stickdorn, M., Hormess, M., Lawrence, A., &amp; Schneider, J. (2018). <em>This Is Service Design Doing</em>. O'Reilly.",
    "Kahneman, D. (2011). <em>Thinking, Fast and Slow</em>, ch. 35. Farrar, Straus and Giroux."),
  quiz = list(
    list(q = tr("What does a service blueprint add to a journey map?", "¿Qué añade un service blueprint a un mapa de recorrido?"),
         options = c(tr("More personas", "Más personas"), tr("The organisation's backstage processes and systems", "Los procesos y sistemas internos de la organización"), tr("Visual design mock-ups", "Maquetas de diseño visual")),
         answer = 2, why = tr("Blueprints show what happens behind the line of visibility that makes each step possible.", "Los blueprints muestran lo que ocurre detrás de la línea de visibilidad y hace posible cada paso.")),
    list(q = tr("According to the peak–end rule, what shapes the memory of an experience most?", "Según la regla del pico y el final, ¿qué determina más el recuerdo de una experiencia?"),
         options = c(tr("Its average quality", "Su calidad media"), tr("Its most intense moment and its end", "Su momento más intenso y su final"), tr("Its total duration", "Su duración total")),
         answer = 2, why = tr("People's retrospective judgements are dominated by peaks and endings.", "Los juicios retrospectivos están dominados por los picos y los finales.")),
    list(q = tr("Which map should you build first?", "¿Qué mapa deberías hacer primero?"),
         options = c(tr("Future state", "Estado futuro"), tr("Current state", "Estado actual"), tr("It does not matter", "Da igual")),
         answer = 2, why = tr("Understanding today's experience reveals the problems the future state must solve.", "Entender la experiencia actual revela los problemas que debe resolver el estado futuro.")))
)
