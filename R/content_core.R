# Go deeper, common mistakes, reading and quiz for the original six labs.
# Each entry is keyed by the lab's namespace id (see the labs list in app.R).

lab_content$wire <- list(
  theory = list(
    list(title = tr("Fidelity: why rough is a feature", "Fidelidad: por qué lo tosco es una virtud"), body = c(
      tr("Wireframes sit at the low-fidelity end of a continuum that runs from sketches to interactive prototypes. Low fidelity is deliberate: grey boxes keep the conversation on <strong>content, priority and flow</strong>, while colour and imagery invite opinions about taste too early.",
         "Los wireframes están en el extremo de baja fidelidad de un continuo que va del boceto al prototipo interactivo. La baja fidelidad es deliberada: las cajas grises centran la conversación en el <strong>contenido, la prioridad y el flujo</strong>, mientras que el color y las imágenes invitan a opinar sobre gustos demasiado pronto."),
      tr("Raise fidelity only to answer a question the current level cannot: for example, whether a label is understood (needs real copy) or whether an interaction feels responsive (needs a clickable prototype).",
         "Sube la fidelidad solo para responder una pregunta que el nivel actual no puede: por ejemplo, si una etiqueta se entiende (requiere texto real) o si una interacción se percibe ágil (requiere un prototipo clicable)."))),
    list(title = tr("Visual hierarchy and scanning", "Jerarquía visual y escaneo"), body = c(
      tr("People scan before they read. Eye-tracking studies by the Nielsen Norman Group describe an <strong>F-pattern</strong> on text-heavy pages and a <strong>layer-cake</strong> pattern when headings are clear. Your wireframe decides what is seen first through position, size and grouping.",
         "La gente escanea antes de leer. Los estudios de seguimiento ocular del Nielsen Norman Group describen un <strong>patrón en F</strong> en páginas con mucho texto y un patrón de <strong>tarta por capas</strong> cuando los encabezados son claros. Tu wireframe decide qué se ve primero mediante la posición, el tamaño y la agrupación."),
      tr("Gestalt principles explain grouping: elements that are <em>close</em>, <em>similar</em> or inside a <em>common region</em> are read as belonging together. Use them to show which controls act on which content.",
         "Los principios de la Gestalt explican la agrupación: los elementos <em>próximos</em>, <em>similares</em> o dentro de una <em>región común</em> se leen como un conjunto. Úsalos para mostrar qué controles actúan sobre qué contenido."))),
    list(title = tr("Mobile first and responsive layouts", "Primero móvil y diseño adaptable"), body = c(
      tr("Designing for the narrowest screen first forces you to rank content: on a 320 px column there is no sidebar to hide secondary items. Then ask what the extra width of tablet and desktop should <em>add</em>, not just stretch.",
         "Diseñar primero para la pantalla más estrecha obliga a jerarquizar el contenido: en una columna de 320 px no hay barra lateral donde esconder lo secundario. Después pregúntate qué debe <em>añadir</em> el ancho extra de tableta y escritorio, no solo estirar."),
      tr("Keep one primary call to action per view. Several equally loud buttons create a choice problem (see Hick's law in lab 09).",
         "Mantén una única llamada a la acción principal por vista. Varios botones igual de llamativos crean un problema de elección (mira la ley de Hick en el lab 09).")))),
  mistakes = c(
    tr("Polishing visual style in a wireframe, which shifts feedback to colours and fonts.", "Pulir el estilo visual en un wireframe, lo que desvía el feedback hacia colores y tipografías."),
    tr("Using lorem ipsum everywhere: real or realistic copy reveals whether labels and length work.", "Usar lorem ipsum en todo: un texto real o realista revela si las etiquetas y la extensión funcionan."),
    tr("Designing only for desktop and squeezing it into mobile at the end.", "Diseñar solo para escritorio y comprimirlo en móvil al final."),
    tr("Skipping the task: every screen should support a named user goal.", "Olvidar la tarea: cada pantalla debe apoyar un objetivo de usuario concreto.")),
  reading = c(
    "Krug, S. (2014). <em>Don't Make Me Think, Revisited</em> (3rd ed.). New Riders.",
    "Buxton, B. (2007). <em>Sketching User Experiences</em>. Morgan Kaufmann.",
    "Wroblewski, L. (2011). <em>Mobile First</em>. A Book Apart.",
    "Nielsen Norman Group. <em>F-Shaped Pattern of Reading on the Web</em>. nngroup.com"),
  quiz = list(
    list(q = tr("Why keep a wireframe grey and rough?", "¿Por qué mantener un wireframe gris y esquemático?"),
         options = c(tr("Because colour is expensive to add later", "Porque añadir color después es caro"), tr("To keep discussion on structure, content and priority", "Para centrar la conversación en estructura, contenido y prioridad"), tr("Because users prefer grey interfaces", "Porque los usuarios prefieren interfaces grises")),
         answer = 2, why = tr("Low fidelity avoids premature debates about visual taste and makes it cheap to change structure.", "La baja fidelidad evita debates prematuros sobre gustos visuales y abarata cambiar la estructura.")),
    list(q = tr("A landing page has four equally prominent buttons. What is the main risk?", "Una página de inicio tiene cuatro botones igual de destacados. ¿Cuál es el principal riesgo?"),
         options = c(tr("Slower decisions and an unclear next step", "Decisiones más lentas y un siguiente paso poco claro"), tr("Lower accessibility contrast", "Menor contraste de accesibilidad"), tr("Longer loading time", "Mayor tiempo de carga")),
         answer = 1, why = tr("Competing calls to action dilute the visual hierarchy and add choice time.", "Las llamadas a la acción que compiten diluyen la jerarquía visual y aumentan el tiempo de elección.")),
    list(q = tr("What does a mobile-first approach mainly force you to do?", "¿Qué te obliga a hacer sobre todo el enfoque primero móvil?"),
         options = c(tr("Use smaller fonts", "Usar fuentes más pequeñas"), tr("Rank content by priority", "Jerarquizar el contenido por prioridad"), tr("Remove navigation", "Eliminar la navegación")),
         answer = 2, why = tr("A narrow column leaves room only for what matters most, so you must decide the order.", "Una columna estrecha solo deja sitio para lo más importante, así que debes decidir el orden.")))
)

lab_content$ia <- list(
  theory = list(
    list(title = tr("Organisation, labelling, navigation, search", "Organización, etiquetado, navegación y búsqueda"), body = c(
      tr("Rosenfeld, Morville and Arango describe information architecture as four systems: <strong>organisation</strong> (how content is grouped), <strong>labelling</strong> (what groups are called), <strong>navigation</strong> (how people move) and <strong>search</strong>. Card sorting works on the first two.",
         "Rosenfeld, Morville y Arango describen la arquitectura de la información como cuatro sistemas: <strong>organización</strong> (cómo se agrupa el contenido), <strong>etiquetado</strong> (cómo se llaman los grupos), <strong>navegación</strong> (cómo se mueve la gente) y <strong>búsqueda</strong>. El card sorting trabaja los dos primeros."))),
    list(title = tr("Open, closed and hybrid card sorts", "Card sorting abierto, cerrado e híbrido"), body = c(
      tr("In an <strong>open</strong> sort, participants create and name their own groups: use it to discover mental models. In a <strong>closed</strong> sort the categories are given: use it to test an existing structure. A <strong>hybrid</strong> sort allows new groups when none fit.",
         "En un card sorting <strong>abierto</strong>, los participantes crean y nombran sus propios grupos: úsalo para descubrir modelos mentales. En uno <strong>cerrado</strong> las categorías vienen dadas: úsalo para evaluar una estructura existente. Uno <strong>híbrido</strong> permite crear grupos cuando ninguno encaja."),
      tr("Results are usually analysed with a <strong>similarity matrix</strong> (how often two cards were grouped together) and a dendrogram. About 15 participants give stable patterns for an open sort (Tullis &amp; Wood, 2004).",
         "Los resultados suelen analizarse con una <strong>matriz de similitud</strong> (cuántas veces se agruparon dos tarjetas juntas) y un dendrograma. Unos 15 participantes dan patrones estables en un card sorting abierto (Tullis y Wood, 2004)."))),
    list(title = tr("Tree testing and information scent", "Tree testing y rastro de información"), body = c(
      tr("A <strong>tree test</strong> checks findability: people look for items in a text-only version of the hierarchy, without visual design. It complements card sorting, which generates the structure.",
         "Un <strong>tree test</strong> comprueba la encontrabilidad: la gente busca elementos en una versión solo texto de la jerarquía, sin diseño visual. Complementa al card sorting, que genera la estructura."),
      tr("<strong>Information scent</strong> (Pirolli &amp; Card) is how strongly a label suggests that the goal lies behind it. Weak scent, such as ‘Resources’ or ‘Miscellaneous’, makes people guess and backtrack.",
         "El <strong>rastro de información</strong> (Pirolli y Card) es cuánto sugiere una etiqueta que el objetivo está detrás. Un rastro débil, como «Recursos» o «Varios», obliga a adivinar y volver atrás.")))),
  mistakes = c(
    tr("Mirroring the organisation chart instead of the users' tasks.", "Reflejar el organigrama en lugar de las tareas de los usuarios."),
    tr("Catch-all labels such as ‘Other’ or ‘Resources’ that carry no scent.", "Etiquetas cajón de sastre como «Otros» o «Recursos» que no dan rastro."),
    tr("Treating one card sort as the answer instead of a hypothesis to tree-test.", "Tomar un card sorting como la respuesta en vez de una hipótesis que validar con un tree test."),
    tr("Running a sort with cards whose names contain the category word, which biases grouping.", "Usar tarjetas cuyo nombre contiene la palabra de la categoría, lo que sesga la agrupación.")),
  reading = c(
    "Rosenfeld, L., Morville, P., &amp; Arango, J. (2015). <em>Information Architecture: For the Web and Beyond</em> (4th ed.). O'Reilly.",
    "Spencer, D. (2009). <em>Card Sorting: Designing Usable Categories</em>. Rosenfeld Media.",
    "Tullis, T., &amp; Wood, L. (2004). How many users are enough for a card-sorting study? <em>UPA Conference</em>.",
    "Pirolli, P., &amp; Card, S. (1999). Information foraging. <em>Psychological Review, 106</em>(4), 643–675."),
  quiz = list(
    list(q = tr("You want to discover how students would naturally group course content. Which method?", "Quieres descubrir cómo agruparía el alumnado los contenidos de una asignatura. ¿Qué método?"),
         options = c(tr("Closed card sort", "Card sorting cerrado"), tr("Open card sort", "Card sorting abierto"), tr("Tree test", "Tree test")),
         answer = 2, why = tr("An open sort lets participants create and name their own groups, revealing their mental model.", "Un card sorting abierto permite a los participantes crear y nombrar sus grupos, y revela su modelo mental.")),
    list(q = tr("What does a tree test measure?", "¿Qué mide un tree test?"),
         options = c(tr("Visual appeal of the menu", "El atractivo visual del menú"), tr("Whether people can find items in a hierarchy", "Si la gente encuentra elementos en una jerarquía"), tr("How fast pages load", "La velocidad de carga de las páginas")),
         answer = 2, why = tr("Tree testing isolates the structure and labels from visual design to test findability.", "El tree testing aísla la estructura y las etiquetas del diseño visual para evaluar la encontrabilidad.")),
    list(q = tr("Which label has the weakest information scent?", "¿Qué etiqueta tiene el rastro de información más débil?"),
         options = c(tr("Submit assignment", "Entregar trabajo"), tr("Office hours", "Tutorías"), tr("Resources", "Recursos")),
         answer = 3, why = tr("‘Resources’ could contain almost anything, so it does not help people predict what is behind it.", "«Recursos» podría contener casi cualquier cosa, así que no ayuda a predecir qué hay detrás.")))
)

lab_content$use <- list(
  theory = list(
    list(title = tr("Nielsen's ten heuristics", "Las diez heurísticas de Nielsen"), body = c(
      tr("Jakob Nielsen's heuristics (1994) are broad rules of thumb distilled from many usability problems. They are not a checklist of features: each one names a <em>kind</em> of problem, such as poor system status or no way to undo.",
         "Las heurísticas de Jakob Nielsen (1994) son reglas generales destiladas de muchos problemas de usabilidad. No son una lista de funcionalidades: cada una nombra un <em>tipo</em> de problema, como un estado del sistema poco visible o no poder deshacer."),
      tr("Other sets exist, such as Shneiderman's eight golden rules or Gerhardt-Powals' cognitive principles. Choose one set and use it consistently within a review.",
         "Existen otros conjuntos, como las ocho reglas de oro de Shneiderman o los principios cognitivos de Gerhardt-Powals. Elige un conjunto y úsalo de forma coherente en cada revisión."))),
    list(title = tr("Running a heuristic evaluation", "Cómo hacer una evaluación heurística"), body = c(
      tr("Three to five evaluators review the interface <strong>independently</strong>, each in one or two passes, then merge their findings. A single evaluator typically finds about a third of the problems; five find around two-thirds (Nielsen &amp; Molich, 1990).",
         "De tres a cinco evaluadores revisan la interfaz <strong>por separado</strong>, en una o dos pasadas, y después combinan sus hallazgos. Un solo evaluador suele encontrar un tercio de los problemas; cinco, unos dos tercios (Nielsen y Molich, 1990)."),
      tr("A good finding states <em>where</em> it happens, <em>what</em> happens, <em>who</em> it affects, the heuristic, a severity and a recommendation. Severity combines frequency, impact and persistence.",
         "Un buen hallazgo indica <em>dónde</em> ocurre, <em>qué</em> pasa, <em>a quién</em> afecta, la heurística, una gravedad y una recomendación. La gravedad combina frecuencia, impacto y persistencia."))),
    list(title = tr("Limits: inspection is not testing", "Límites: inspeccionar no es testar"), body = c(
      tr("Heuristic evaluation is fast and cheap, but it predicts problems; it does not prove them. It produces false positives and misses problems that depend on domain knowledge. Combine it with usability testing (lab 11).",
         "La evaluación heurística es rápida y barata, pero predice problemas; no los demuestra. Produce falsos positivos y pasa por alto problemas que dependen del conocimiento del dominio. Combínala con tests de usabilidad (lab 11).")))),
  mistakes = c(
    tr("Writing opinions (‘I don't like the colour’) instead of observable issues.", "Escribir opiniones («no me gusta el color») en vez de problemas observables."),
    tr("Rating everything as severe, which makes prioritisation impossible.", "Calificar todo como grave, lo que impide priorizar."),
    tr("Merging evaluators' notes before each has finished, which reduces coverage.", "Combinar las notas antes de que cada evaluador termine, lo que reduce la cobertura."),
    tr("Recommending ‘redesign it’ instead of a specific, testable change.", "Recomendar «rediseñarlo» en vez de un cambio concreto y comprobable.")),
  reading = c(
    "Nielsen, J. (1994). Enhancing the explanatory power of usability heuristics. <em>CHI '94</em>, 152–158.",
    "Nielsen, J., &amp; Molich, R. (1990). Heuristic evaluation of user interfaces. <em>CHI '90</em>, 249–256.",
    "Shneiderman, B., Plaisant, C., et al. (2016). <em>Designing the User Interface</em> (6th ed.). Pearson.",
    "ISO 9241-11:2018. <em>Ergonomics of human-system interaction — Usability: Definitions and concepts</em>."),
  quiz = list(
    list(q = tr("A form clears itself after submit with no message. Which heuristic is most clearly violated?", "Un formulario se vacía al enviarlo sin ningún mensaje. ¿Qué heurística se incumple con más claridad?"),
         options = c(heuristics[1], heuristics[8], heuristics[10]),
         answer = 1, why = tr("People cannot tell whether the action worked: the system's status is invisible.", "La gente no sabe si la acción ha funcionado: el estado del sistema es invisible.")),
    list(q = tr("How many evaluators are usually recommended for a heuristic evaluation?", "¿Cuántos evaluadores se suelen recomendar en una evaluación heurística?"),
         options = c("1", tr("3 to 5", "De 3 a 5"), tr("20 or more", "20 o más")),
         answer = 2, why = tr("Each evaluator finds different problems; 3–5 balances coverage and cost.", "Cada evaluador encuentra problemas distintos; 3–5 equilibra cobertura y coste.")),
    list(q = tr("What can a heuristic evaluation not tell you?", "¿Qué no puede decirte una evaluación heurística?"),
         options = c(tr("Which parts of the interface break known principles", "Qué partes de la interfaz incumplen principios conocidos"), tr("Whether real users actually struggle", "Si los usuarios reales tienen dificultades de verdad"), tr("How to prioritise likely problems", "Cómo priorizar los problemas probables")),
         answer = 2, why = tr("Only observing people (usability testing) shows whether a predicted problem really happens.", "Solo observar a personas (test de usabilidad) muestra si un problema previsto ocurre de verdad.")))
)

lab_content$access <- list(
  theory = list(
    list(title = tr("WCAG 2.2 and the POUR principles", "WCAG 2.2 y los principios POUR"), body = c(
      tr("The Web Content Accessibility Guidelines (WCAG 2.2, W3C 2023) are organised under four principles: content must be <strong>Perceivable</strong>, <strong>Operable</strong>, <strong>Understandable</strong> and <strong>Robust</strong>. Each success criterion has a level: A, AA or AAA. Most laws, including the EU's EN 301 549 and the European Accessibility Act, refer to level AA.",
         "Las Pautas de Accesibilidad para el Contenido Web (WCAG 2.2, W3C 2023) se organizan en cuatro principios: el contenido debe ser <strong>Perceptible</strong>, <strong>Operable</strong>, <strong>Comprensible</strong> y <strong>Robusto</strong>. Cada criterio de conformidad tiene un nivel: A, AA o AAA. La mayoría de las leyes, como la norma europea EN 301 549 y el Acta Europea de Accesibilidad, remiten al nivel AA."))),
    list(title = tr("Colour contrast in practice", "El contraste de color en la práctica"), body = c(
      tr("Criterion 1.4.3 requires a contrast ratio of at least <strong>4.5:1</strong> for normal text and <strong>3:1</strong> for large text (24 px, or 18.7 px bold). Criterion 1.4.11 asks for 3:1 for interface components and meaningful graphics, such as input borders and focus indicators.",
         "El criterio 1.4.3 exige una relación de contraste de al menos <strong>4,5:1</strong> para texto normal y <strong>3:1</strong> para texto grande (24 px, o 18,7 px en negrita). El criterio 1.4.11 pide 3:1 para componentes de interfaz y gráficos con significado, como bordes de campos e indicadores de foco."),
      tr("Never use colour as the only way to convey information (1.4.1): add text, icons or patterns. About 1 in 12 men and 1 in 200 women have a colour vision deficiency.",
         "No uses nunca el color como única forma de transmitir información (1.4.1): añade texto, iconos o tramas. Aproximadamente 1 de cada 12 hombres y 1 de cada 200 mujeres tienen alguna deficiencia en la visión del color."))),
    list(title = tr("Beyond colour: keyboard, semantics, testing", "Más allá del color: teclado, semántica y pruebas"), body = c(
      tr("Everything must work with a keyboard, with a visible focus (2.1.1, 2.4.7). Use real headings, labels and buttons so assistive technologies can announce them. Automated checkers catch only part of the issues: test with a keyboard, a screen reader (NVDA, VoiceOver) and, above all, with disabled people.",
         "Todo debe funcionar con teclado y con un foco visible (2.1.1, 2.4.7). Usa encabezados, etiquetas y botones reales para que las tecnologías de apoyo puedan anunciarlos. Los validadores automáticos detectan solo una parte de los problemas: prueba con teclado, con un lector de pantalla (NVDA, VoiceOver) y, sobre todo, con personas con discapacidad.")))),
  mistakes = c(
    tr("Placeholder text used as the only label for a field.", "Usar el texto de ejemplo (placeholder) como única etiqueta de un campo."),
    tr("Removing the focus outline for aesthetic reasons.", "Quitar el contorno de foco por motivos estéticos."),
    tr("Relying only on automated tools and declaring a site ‘accessible’.", "Fiarse solo de herramientas automáticas y declarar un sitio «accesible»."),
    tr("Red and green status indicators with no text or icon.", "Indicadores de estado rojos y verdes sin texto ni icono.")),
  reading = c(
    "W3C (2023). <em>Web Content Accessibility Guidelines (WCAG) 2.2</em>. w3.org/TR/WCAG22",
    "Horton, S., &amp; Quesenbery, W. (2014). <em>A Web for Everyone</em>. Rosenfeld Media.",
    "Directive (EU) 2019/882 — European Accessibility Act.",
    "Microsoft (2016). <em>Inclusive Design Toolkit</em>. inclusive.microsoft.design"),
  quiz = list(
    list(q = tr("What minimum contrast does WCAG AA require for normal body text?", "¿Qué contraste mínimo exige WCAG AA para el texto normal?"),
         options = c("3:1", "4.5:1", "7:1"), answer = 2,
         why = tr("4.5:1 is level AA for normal text; 7:1 is AAA; 3:1 applies to large text and UI components.", "4,5:1 es el nivel AA para texto normal; 7:1 es AAA; 3:1 se aplica a texto grande y componentes de interfaz.")),
    list(q = tr("A form marks errors only by turning the border red. Which principle is at risk?", "Un formulario marca los errores solo poniendo el borde en rojo. ¿Qué principio está en riesgo?"),
         options = c(tr("Perceivable: colour is the only cue", "Perceptible: el color es la única señal"), tr("Robust: the code is invalid", "Robusto: el código no es válido"), tr("Operable: it cannot be clicked", "Operable: no se puede pulsar")),
         answer = 1, why = tr("People who cannot distinguish red will miss the error; add a text message and an icon.", "Quien no distingue el rojo no verá el error; añade un mensaje de texto y un icono.")),
    list(q = tr("Which is the most reliable way to know whether a site is usable for screen reader users?", "¿Cuál es la forma más fiable de saber si un sitio es usable con lector de pantalla?"),
         options = c(tr("An automated checker score of 100", "Una puntuación de 100 en un validador automático"), tr("Testing with people who use screen readers", "Probarlo con personas que usan lector de pantalla"), tr("Checking the colour palette", "Revisar la paleta de colores")),
         answer = 2, why = tr("Automated tools find only a fraction of barriers; real users reveal how the experience works in practice.", "Las herramientas automáticas solo encuentran una parte de las barreras; los usuarios reales muestran cómo funciona la experiencia.")))
)

lab_content$patterns <- list(
  theory = list(
    list(title = tr("Feedback and the gulfs of execution and evaluation", "Feedback y los golfos de ejecución y evaluación"), body = c(
      tr("Don Norman describes two gaps: the <strong>gulf of execution</strong> (how do I do what I want?) and the <strong>gulf of evaluation</strong> (did it work?). Feedback bridges the second. Response times matter: under 0.1 s feels instant, under 1 s keeps the flow, over 10 s needs progress and a way to cancel (Nielsen, 1993).",
         "Don Norman describe dos brechas: el <strong>golfo de ejecución</strong> (¿cómo hago lo que quiero?) y el <strong>golfo de evaluación</strong> (¿ha funcionado?). El feedback salva el segundo. Los tiempos de respuesta importan: menos de 0,1 s se percibe instantáneo, menos de 1 s mantiene el flujo y más de 10 s requiere progreso y una forma de cancelar (Nielsen, 1993)."))),
    list(title = tr("Confirm or undo?", "¿Confirmar o deshacer?"), body = c(
      tr("Confirmation dialogs work when they are <em>rare</em> and name the consequence (‘Delete 120 student records?’). Used for every action, they are clicked through automatically, a habit known as <em>habituation</em>. For frequent, reversible actions, act immediately and offer <strong>Undo</strong>.",
         "Los diálogos de confirmación funcionan cuando son <em>poco frecuentes</em> y nombran la consecuencia («¿Eliminar 120 expedientes?»). Si aparecen en cada acción, se aceptan de forma automática, un efecto llamado <em>habituación</em>. Para acciones frecuentes y reversibles, actúa de inmediato y ofrece <strong>Deshacer</strong>."))),
    list(title = tr("Form validation patterns", "Patrones de validación de formularios"), body = c(
      tr("Validate when the person leaves a field, not on every keystroke, and keep the message next to the field. Say what is wrong and how to fix it. Never clear what people typed. Pattern libraries such as the GOV.UK Design System document these choices with research behind them.",
         "Valida cuando la persona sale del campo, no en cada pulsación, y deja el mensaje junto al campo. Di qué está mal y cómo arreglarlo. No borres nunca lo que la gente escribió. Bibliotecas de patrones como el GOV.UK Design System documentan estas decisiones con investigación detrás.")))),
  mistakes = c(
    tr("‘Are you sure?’ dialogs on every action.", "Diálogos «¿Estás seguro?» en cada acción."),
    tr("Spinners with no indication of how long or what is happening.", "Indicadores de carga sin indicar cuánto falta ni qué está pasando."),
    tr("Error messages at the top of the page, far from the field.", "Mensajes de error arriba de la página, lejos del campo."),
    tr("Toasts that disappear before people can read them.", "Avisos emergentes que desaparecen antes de poder leerlos.")),
  reading = c(
    "Norman, D. (2013). <em>The Design of Everyday Things</em> (revised ed.). Basic Books.",
    "Tidwell, J., Brewer, C., &amp; Valencia, A. (2020). <em>Designing Interfaces</em> (3rd ed.). O'Reilly.",
    "Saffer, D. (2013). <em>Microinteractions</em>. O'Reilly.",
    "GOV.UK Design System. <em>Error message</em> and <em>Validation</em> patterns. design-system.service.gov.uk"),
  quiz = list(
    list(q = tr("An action takes 15 seconds. What should the interface show?", "Una acción tarda 15 segundos. ¿Qué debería mostrar la interfaz?"),
         options = c(tr("Nothing, to avoid distraction", "Nada, para no distraer"), tr("A progress indicator and a way to cancel", "Un indicador de progreso y una forma de cancelar"), tr("A confirmation dialog", "Un diálogo de confirmación")),
         answer = 2, why = tr("Beyond about 10 seconds people lose focus; show progress and let them stop.", "A partir de unos 10 segundos la gente pierde la atención; muestra el progreso y permite detenerlo.")),
    list(q = tr("Why can frequent confirmation dialogs make actions less safe?", "¿Por qué los diálogos de confirmación frecuentes pueden hacer las acciones menos seguras?"),
         options = c(tr("People learn to click OK without reading", "La gente aprende a pulsar Aceptar sin leer"), tr("They slow the server", "Ralentizan el servidor"), tr("They break keyboard access", "Rompen el acceso con teclado")),
         answer = 1, why = tr("Habituation turns the dialog into a reflex, so it no longer protects against mistakes.", "La habituación convierte el diálogo en un reflejo, así que deja de proteger de los errores.")),
    list(q = tr("Which gulf does feedback help to bridge?", "¿Qué golfo ayuda a salvar el feedback?"),
         options = c(tr("Gulf of execution", "Golfo de ejecución"), tr("Gulf of evaluation", "Golfo de evaluación"), tr("Gulf of expectation", "Golfo de expectativa")),
         answer = 2, why = tr("Feedback tells people what happened, so they can evaluate the result of their action.", "El feedback dice qué ha pasado, para que la gente pueda evaluar el resultado de su acción.")))
)

lab_content$behaviour <- list(
  theory = list(
    list(title = tr("What logs and analytics can and cannot say", "Qué pueden y qué no pueden decir los registros y la analítica"), body = c(
      tr("Behavioural data shows <strong>what</strong> people did: paths, time on page, drop-off, rage clicks. It never shows <strong>why</strong>. Pair quantitative traces with qualitative methods, such as interviews or think-aloud tests, to explain them (triangulation).",
         "Los datos de comportamiento muestran <strong>qué</strong> hizo la gente: recorridos, tiempo en página, abandonos, clics repetidos. Nunca muestran <strong>por qué</strong>. Combina los rastros cuantitativos con métodos cualitativos, como entrevistas o tests con pensamiento en voz alta, para explicarlos (triangulación)."))),
    list(title = tr("Funnels, paths and the HEART framework", "Embudos, recorridos y el marco HEART"), body = c(
      tr("A <strong>funnel</strong> counts how many people complete each step of a flow; the biggest drop is where to look first. Google's <strong>HEART</strong> framework (Rodden et al., 2010) links metrics to goals: Happiness, Engagement, Adoption, Retention and Task success, each through Goals → Signals → Metrics.",
         "Un <strong>embudo</strong> cuenta cuántas personas completan cada paso de un flujo; la mayor caída es donde mirar primero. El marco <strong>HEART</strong> de Google (Rodden et al., 2010) vincula métricas a objetivos: felicidad, implicación, adopción, retención y éxito en la tarea, cada uno mediante Objetivos → Señales → Métricas."))),
    list(title = tr("Ethics and law", "Ética y legislación"), body = c(
      tr("Collect the minimum needed, pseudonymise it, and ask for consent before setting analytics cookies (GDPR and the ePrivacy rules). Session replay tools record behaviour in detail: mask what people type and say so in your privacy notice.",
         "Recoge lo mínimo necesario, seudonimízalo y pide consentimiento antes de instalar cookies de analítica (RGPD y normas de ePrivacy). Las herramientas de grabación de sesiones registran el comportamiento con detalle: enmascara lo que la gente escribe y dilo en tu aviso de privacidad.")))),
  mistakes = c(
    tr("Reading long time-on-page as engagement when it may be confusion.", "Interpretar mucho tiempo en página como interés cuando puede ser confusión."),
    tr("Explaining behaviour from data alone, without talking to anyone.", "Explicar el comportamiento solo con datos, sin hablar con nadie."),
    tr("Vanity metrics (page views) that do not relate to any user goal.", "Métricas de vanidad (páginas vistas) que no se relacionan con ningún objetivo de usuario."),
    tr("Tracking first and asking for consent later.", "Rastrear primero y pedir consentimiento después.")),
  reading = c(
    "Rodden, K., Hutchinson, H., &amp; Fu, X. (2010). Measuring the user experience on a large scale: HEART. <em>CHI '10</em>, 2395–2398.",
    "Kaushik, A. (2009). <em>Web Analytics 2.0</em>. Sybex.",
    "Lazar, J., Feng, J. H., &amp; Hochheiser, H. (2017). <em>Research Methods in Human-Computer Interaction</em> (2nd ed.). Morgan Kaufmann.",
    "Regulation (EU) 2016/679 — General Data Protection Regulation."),
  quiz = list(
    list(q = tr("A user spent 90 seconds on a help page. What can you conclude from the log alone?", "Una persona pasó 90 segundos en una página de ayuda. ¿Qué puedes concluir solo con el registro?"),
         options = c(tr("The page was confusing", "La página era confusa"), tr("The page was very useful", "La página era muy útil"), tr("Only that the page was open for 90 seconds", "Solo que la página estuvo abierta 90 segundos")),
         answer = 3, why = tr("Time alone has many explanations; you need other evidence to know why.", "El tiempo por sí solo tiene muchas explicaciones; necesitas otra evidencia para saber por qué.")),
    list(q = tr("In HEART, what does the ‘T’ stand for?", "En HEART, ¿qué significa la «T»?"),
         options = c(tr("Traffic", "Tráfico"), tr("Task success", "Éxito en la tarea"), tr("Time on page", "Tiempo en página")),
         answer = 2, why = tr("Task success covers efficiency, effectiveness and errors.", "El éxito en la tarea incluye eficiencia, eficacia y errores.")),
    list(q = tr("Under the GDPR and ePrivacy rules, when may analytics cookies be set in the EU?", "Según el RGPD y las normas de ePrivacy, ¿cuándo pueden instalarse cookies de analítica en la UE?"),
         options = c(tr("Always, if the data is anonymous", "Siempre, si los datos son anónimos"), tr("After the visitor gives consent", "Después de que el visitante dé su consentimiento"), tr("Only on mobile", "Solo en móvil")),
         answer = 2, why = tr("Non-essential cookies, including most analytics, need prior consent.", "Las cookies no esenciales, incluida la mayoría de la analítica, requieren consentimiento previo.")))
)
