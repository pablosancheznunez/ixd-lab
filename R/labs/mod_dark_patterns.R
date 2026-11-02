# Ethics and dark patterns: identify deceptive designs, rate their harm and propose a fair alternative.
dark_types <- c(
  confirmshaming = tr("Confirmshaming", "Confirmshaming (culpabilizar)"),
  preselection = tr("Preselection / sneaking into basket", "Preselección / añadido a escondidas"),
  obstruction = tr("Obstruction (roach motel)", "Obstrucción (fácil entrar, difícil salir)"),
  urgency = tr("False urgency or scarcity", "Falsa urgencia o escasez"),
  hidden = tr("Hidden costs (drip pricing)", "Costes ocultos (precio por goteo)"),
  trick = tr("Trick question", "Pregunta trampa"),
  nagging = tr("Nagging", "Insistencia"),
  disguised = tr("Disguised ad", "Publicidad encubierta")
)

dark_screens <- list(
  newsletter = list(type = "confirmshaming", title = tr("Newsletter pop-up", "Ventana de boletín"),
    mock = function() div(class = "mock text-center",
      h5(tr("Get 10% off your first course!", "¡10% de descuento en tu primer curso!")),
      span(class = "btn btn-success btn-sm d-block mb-2", tr("Sign me up", "Suscribirme")),
      span(class = "footnote", tags$u(tr("No thanks, I prefer to stay uninformed", "No, gracias, prefiero seguir desinformado")))),
    law = tr("Manipulative wording undermines free choice; the EU Digital Services Act (Art. 25) bans online platform interfaces that deceive or manipulate users.",
             "La redacción manipuladora socava la libre elección; la Ley de Servicios Digitales de la UE (art. 25) prohíbe a las plataformas en línea interfaces que engañen o manipulen.")),
  checkout = list(type = "preselection", title = tr("Checkout extras", "Extras en el pago"),
    mock = function() div(class = "mock",
      div(class = "mock-bar", tr("travel.example / checkout", "viajes.example / pago")),
      p(class = "mb-1", tr("Flight Madrid–Lisbon · €89", "Vuelo Madrid–Lisboa · 89 €")),
      tags$label(class = "footnote", tags$input(type = "checkbox", checked = NA, disabled = NA), tr(" Add travel insurance (€19.99)", " Añadir seguro de viaje (19,99 €)")),
      div(class = "mt-2", span(class = "btn btn-primary btn-sm", tr("Pay €108.99", "Pagar 108,99 €")))),
    law = tr("Under the EU Consumer Rights Directive (Art. 22), extra payments need express consent: pre-ticked boxes are not allowed.",
             "Según la Directiva europea sobre derechos de los consumidores (art. 22), los pagos adicionales requieren consentimiento expreso: no se permiten casillas premarcadas.")),
  cancel = list(type = "obstruction", title = tr("Cancelling a subscription", "Cancelar una suscripción"),
    mock = function() div(class = "mock",
      div(class = "mock-bar", tr("account.example / membership", "cuenta.example / suscripción")),
      p(class = "mb-1", tr("Joined online in one click.", "Te diste de alta en línea con un clic.")),
      p(class = "footnote mb-0", tr("To cancel, call 900 000 000, Monday to Friday 10:00–13:00, and quote your 16-digit customer code.", "Para cancelar, llama al 900 000 000, de lunes a viernes de 10:00 a 13:00, e indica tu código de cliente de 16 dígitos."))),
    law = tr("Cancelling should be as easy as signing up. The EU Consumer Rights Directive and national rules increasingly require an online cancellation button.",
             "Darse de baja debería ser tan fácil como darse de alta. La normativa europea de consumo y las normas nacionales exigen cada vez más un botón de baja en línea.")),
  timer = list(type = "urgency", title = tr("Course offer", "Oferta de curso"),
    mock = function() div(class = "mock",
      span(class = "chip chip-warn", tr("Only 2 places left!", "¡Solo quedan 2 plazas!")),
      h5(class = "mt-2", tr("UX Bootcamp · €499", "Bootcamp UX · 499 €")),
      p(class = "footnote mb-0", tr("Offer ends in 04:59 (the timer restarts every time you reload the page).", "La oferta termina en 04:59 (el contador se reinicia cada vez que recargas la página)."))),
    law = tr("Falsely claiming that a product is available only for a very limited time is an unfair commercial practice in all circumstances (EU Unfair Commercial Practices Directive, Annex I).",
             "Afirmar falsamente que un producto solo está disponible durante un tiempo muy limitado es una práctica comercial desleal en cualquier circunstancia (Directiva europea de prácticas comerciales desleales, anexo I).")),
  fees = list(type = "hidden", title = tr("Ticket price", "Precio de la entrada"),
    mock = function() div(class = "mock",
      p(class = "mb-1", tr("Step 1: Concert ticket · €49", "Paso 1: Entrada de concierto · 49 €")),
      p(class = "footnote mb-1", tr("Step 4 of 4: Service fee €12 · Processing fee €4 · Total €65", "Paso 4 de 4: Gastos de gestión 12 € · Gastos de tramitación 4 € · Total 65 €"))),
    law = tr("The total price, including unavoidable fees, must be shown upfront (EU Consumer Rights Directive and Price Indication rules).",
             "El precio total, con los cargos inevitables, debe mostrarse desde el principio (normativa europea de derechos de los consumidores e indicación de precios).")),
  consent = list(type = "trick", title = tr("Account sign-up", "Registro de cuenta"),
    mock = function() div(class = "mock",
      tags$label(class = "footnote", tags$input(type = "checkbox", disabled = NA),
        tr(" Untick this box if you do not wish not to receive offers from our partners.", " Desmarca esta casilla si no deseas no recibir ofertas de nuestros socios."))),
    law = tr("Under the GDPR, consent must be clear and unambiguous; the CJEU's Planet49 ruling (2019) held that pre-ticked or confusing consent is not valid.",
             "Según el RGPD, el consentimiento debe ser claro e inequívoco; la sentencia Planet49 del TJUE (2019) estableció que el consentimiento premarcado o confuso no es válido."))
)

dark_patterns_ui <- function(id) {
  ns <- NS(id)
  lab_section(ns,
    objectives = c(tr("Recognise common deceptive design patterns.", "Reconocer patrones de diseño engañoso habituales."),
                   tr("Judge their harm to people, not only to conversion.", "Valorar el daño que causan a las personas, no solo a la conversión."),
                   tr("Propose fair alternatives that still meet business goals.", "Proponer alternativas justas que sigan cumpliendo los objetivos de negocio.")),
    concept = tr("Dark patterns (deceptive designs) push people into choices they would not make if they understood them. They may lift short-term metrics, but they erode trust, harm vulnerable users and are increasingly illegal in the EU.",
                 "Los patrones oscuros (diseño engañoso) empujan a la gente a decisiones que no tomaría si las entendiera. Pueden mejorar métricas a corto plazo, pero erosionan la confianza, dañan a usuarios vulnerables y son cada vez más ilegales en la UE."),
    activity = tagList(
      p(tr("Challenge · Review six screens from a design audit. Name the pattern, rate its harm, and propose a fair version.", "Reto · Revisa seis pantallas de una auditoría de diseño. Nombra el patrón, valora su daño y propón una versión justa.")),
      layout_columns(col_widths = c(6, 6),
        div(radioButtons(ns("screen"), tr("Screen", "Pantalla"), setNames(names(dark_screens), vapply(dark_screens, `[[`, "", "title")), inline = TRUE),
            uiOutput(ns("mock"))),
        div(
          selectInput(ns("type"), tr("Which pattern is this?", "¿Qué patrón es?"), c(setNames("", tr("Choose a pattern", "Elige un patrón")), setNames(names(dark_types), dark_types))),
          sliderInput(ns("harm"), tr("Harm to people (1 = minor, 5 = severe)", "Daño a las personas (1 = leve, 5 = grave)"), 1, 5, 3, step = 1, ticks = FALSE),
          textAreaInput(ns("alternative"), tr("A fair alternative", "Una alternativa justa"), rows = 3, width = "100%"),
          actionButton(ns("add"), tr("Add to audit", "Añadir a la auditoría"), class = "btn-primary"),
          uiOutput(ns("feedback")))),
      h4(class = "mt-4", tr("Audit report", "Informe de auditoría")),
      tableOutput(ns("audit"))),
    reflection = tr("A product manager says the pre-ticked insurance box raises revenue by 12%. How would you argue for removing it, and what would you measure instead?",
                    "Una responsable de producto dice que la casilla de seguro premarcada aumenta los ingresos un 12%. ¿Cómo defenderías quitarla y qué medirías en su lugar?"))
}

dark_patterns_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    audit <- reactiveVal(data.frame(screen = character(), pattern = character(), correct = character(), harm = integer(), alternative = character()))
    feedback <- reactiveVal(NULL)
    output$mock <- renderUI(dark_screens[[input$screen]]$mock())
    observeEvent(input$screen, feedback(NULL))

    observeEvent(input$add, {
      sc <- dark_screens[[input$screen]]
      if (!nzchar(input$type)) return(feedback(div(class = "alert alert-warning mt-3", tr("Choose a pattern first.", "Elige primero un patrón."))))
      if (nchar(trimws(input$alternative)) < 15) return(feedback(div(class = "alert alert-warning mt-3", tr("Describe a fair alternative in a sentence.", "Describe una alternativa justa en una frase."))))
      right <- input$type == sc$type
      audit(rbind(audit()[audit()$screen != sc$title, ], data.frame(screen = sc$title, pattern = dark_types[[input$type]], correct = if (right) "✓" else dark_types[[sc$type]],
                                                                     harm = as.integer(input$harm), alternative = trimws(input$alternative))))
      updateTextAreaInput(session, "alternative", value = "")
      feedback(div(class = paste("alert mt-3", if (right) "alert-success" else "alert-info"),
        tags$strong(if (right) tr("Correct. ", "Correcto. ") else paste0(tr("Closer to: ", "Más bien: "), dark_types[[sc$type]], ". ")),
        tags$br(), span(class = "footnote", tags$strong(tr("Law and policy: ", "Normativa: ")), sc$law)))
    })
    output$feedback <- renderUI(feedback())
    output$audit <- renderTable({
      x <- audit()
      if (!nrow(x)) return(setNames(data.frame(tr("No screens audited yet.", "Todavía no has auditado ninguna pantalla.")), " "))
      x <- x[order(-x$harm), ]
      setNames(x, c(tr("Screen", "Pantalla"), tr("Your pattern", "Tu patrón"), tr("Reference", "Referencia"), tr("Harm", "Daño"), tr("Fair alternative", "Alternativa justa")))
    }, striped = TRUE, width = "100%")

    lines <- function() {
      x <- audit()
      if (!nrow(x)) return(tr("(no screens audited)", "(ninguna pantalla auditada)"))
      x <- x[order(-x$harm), ]
      c(sprintf(tr("Patterns identified correctly: %d of %d", "Patrones identificados correctamente: %d de %d"), sum(x$correct == "✓"), nrow(x)),
        unlist(lapply(seq_len(nrow(x)), function(i) c(sprintf(tr("%d. %s · %s · harm %d", "%d. %s · %s · daño %d"), i, x$screen[i], x$pattern[i], x$harm[i]), paste0(tr("   Fair alternative: ", "   Alternativa justa: "), x$alternative[i])))))
    }
    observeEvent(input$example, {
      audit(data.frame(screen = c(dark_screens$checkout$title, dark_screens$cancel$title),
                       pattern = c(dark_types[["preselection"]], dark_types[["obstruction"]]), correct = "✓", harm = c(4L, 5L),
                       alternative = c(tr("Leave the box unticked and show the insurance as an optional add-on with its benefits.", "Dejar la casilla sin marcar y mostrar el seguro como un extra opcional con sus ventajas."),
                                       tr("Add a ‘Cancel membership’ button in the account page, with one confirmation step.", "Añadir un botón «Cancelar suscripción» en la cuenta, con un único paso de confirmación."))))
      example_reflection(session, tr("Part of the 12% are customers who did not notice the box: they will complain, ask for refunds and trust us less, and the practice breaks EU consumer law. I would measure opt-in rate with an unticked box, refund requests and repeat purchases.",
                                     "Parte de ese 12% son clientes que no vieron la casilla: reclamarán, pedirán devoluciones y confiarán menos en nosotros, y la práctica incumple la normativa europea de consumo. Mediría la tasa de contratación con la casilla sin marcar, las devoluciones y la repetición de compra."))
    })

    reflect_server(tr("Ethics and dark patterns", "Ética y patrones oscuros"), input, output, session, lines)
  })
}

lab_content$ethics <- list(
  theory = list(
    list(title = tr("From persuasion to deception", "De la persuasión al engaño"), body = c(
      tr("Harry Brignull coined ‘dark patterns’ in 2010; he now prefers <strong>deceptive design</strong>. Gray et al. (2018) group them into nagging, obstruction, sneaking, interface interference and forced action. The line is crossed when design exploits cognitive biases against the person's own interests, or hides information they need to decide.",
         "Harry Brignull acuñó «dark patterns» en 2010; hoy prefiere <strong>diseño engañoso</strong>. Gray et al. (2018) los agrupan en insistencia, obstrucción, ocultación, interferencia en la interfaz y acción forzada. Se cruza la línea cuando el diseño explota sesgos cognitivos contra los intereses de la persona u oculta información que necesita para decidir."))),
    list(title = tr("The legal landscape in the EU", "El marco legal en la UE"), body = c(
      tr("Several laws now target deceptive design: the <strong>Unfair Commercial Practices Directive</strong> (misleading and aggressive practices), the <strong>Consumer Rights Directive</strong> (no pre-ticked boxes for extra payments, clear total prices), the <strong>GDPR</strong> (consent must be freely given, specific, informed and unambiguous), and the <strong>Digital Services Act</strong> (Art. 25 bans deceptive interfaces on online platforms). The AI Act also prohibits manipulative AI techniques.",
         "Varias normas abordan ya el diseño engañoso: la <strong>Directiva de prácticas comerciales desleales</strong> (prácticas engañosas y agresivas), la <strong>Directiva sobre derechos de los consumidores</strong> (sin casillas premarcadas para pagos adicionales, precios totales claros), el <strong>RGPD</strong> (el consentimiento debe ser libre, específico, informado e inequívoco) y la <strong>Ley de Servicios Digitales</strong> (el art. 25 prohíbe las interfaces engañosas en plataformas en línea). El Reglamento de IA también prohíbe técnicas de IA manipuladoras."))),
    list(title = tr("Designing ethically", "Diseñar con ética"), body = c(
      tr("Useful tests: would you be comfortable explaining the design to the user's face? Would it survive being described in the press? Does it work as well for vulnerable users (older people, people in a hurry, people with cognitive disabilities)? Measure long-term value, such as retention, complaints and trust, not only immediate conversion.",
         "Preguntas útiles: ¿te sentirías cómodo explicando el diseño a la persona usuaria cara a cara? ¿Sobreviviría a que lo contara la prensa? ¿Funciona igual de bien para usuarios vulnerables (personas mayores, con prisa o con discapacidad cognitiva)? Mide el valor a largo plazo, como la retención, las reclamaciones y la confianza, no solo la conversión inmediata.")))),
  mistakes = c(
    tr("Justifying a pattern because ‘everyone does it’.", "Justificar un patrón porque «todo el mundo lo hace»."),
    tr("Optimising a single short-term metric in A/B tests without guardrail metrics.", "Optimizar una única métrica a corto plazo en tests A/B sin métricas de control."),
    tr("Cookie banners where ‘Accept’ is a big button and ‘Reject’ is hidden in settings.", "Banners de cookies donde «Aceptar» es un botón grande y «Rechazar» está escondido en la configuración."),
    tr("Treating ethics as the legal team's job only.", "Tratar la ética como trabajo exclusivo del equipo legal.")),
  reading = c(
    "Brignull, H. (2023). <em>Deceived by Design</em>. Testimonium.",
    "Gray, C. M., Kou, Y., Battles, B., Hoggatt, J., &amp; Toombs, A. L. (2018). The dark (patterns) side of UX design. <em>CHI '18</em>, paper 534.",
    "Mathur, A., et al. (2019). Dark patterns at scale. <em>Proceedings of the ACM on HCI, 3</em>(CSCW), 81.",
    "European Commission (2022). <em>Behavioural study on unfair commercial practices in the digital environment</em>.",
    "Regulation (EU) 2022/2065 — Digital Services Act, Art. 25."),
  quiz = list(
    list(q = tr("A cancellation link reads ‘No thanks, I don't care about my health’. Which pattern?", "Un enlace de cancelación dice «No, gracias, no me importa mi salud». ¿Qué patrón es?"),
         options = c(dark_types[["confirmshaming"]], dark_types[["hidden"]], dark_types[["nagging"]]),
         answer = 1, why = tr("It shames people into accepting by making the refusal sound bad.", "Avergüenza a la gente para que acepte, haciendo que el rechazo suene mal.")),
    list(q = tr("Under EU consumer law, may a checkout pre-tick an optional paid extra?", "Según la normativa europea de consumo, ¿puede un proceso de pago premarcar un extra de pago opcional?"),
         options = c(tr("Yes, if it can be unticked", "Sí, si se puede desmarcar"), tr("No, extra payments need express consent", "No, los pagos adicionales requieren consentimiento expreso"), tr("Only for insurance", "Solo para seguros")),
         answer = 2, why = tr("Article 22 of the Consumer Rights Directive rules out default options for additional payments.", "El artículo 22 de la Directiva sobre derechos de los consumidores excluye las opciones por defecto para pagos adicionales.")),
    list(q = tr("Which metric best reveals the cost of a dark pattern?", "¿Qué métrica revela mejor el coste de un patrón oscuro?"),
         options = c(tr("Immediate conversion", "Conversión inmediata"), tr("Complaints, refunds and long-term retention", "Reclamaciones, devoluciones y retención a largo plazo"), tr("Page views", "Páginas vistas")),
         answer = 2, why = tr("Deceptive designs often lift short-term numbers while damaging trust and long-term value.", "El diseño engañoso suele mejorar las cifras a corto plazo mientras daña la confianza y el valor a largo plazo.")))
)
