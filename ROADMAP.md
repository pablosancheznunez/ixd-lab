# Roadmap

IxD Lab aims to be an AI-powered learning and experimentation environment for interaction design, with an opt-in research mode that collects interaction data ethically. Each stage below builds towards that goal.

## 0.1 · Learning prototype (this release)

- Shared editorial identity, navigation, and modular structure for all six labs.
- One usable starter activity per lab; wireframe add/remove, responsive-width preview, and text export.
- No accounts, telemetry, AI provider, or participant data collection yet.

## 0.2 · Teaching-ready foundations

- Expand each activity with worked examples, progressive challenges, accessible instructions, and facilitator notes.
- Add wireframe selection/reordering, richer export, and saved local drafts with clear privacy controls.
- Add card-sort rounds and sitemap editing; usability task scenarios and severity rationale; semantic structure and keyboard checks; interaction state comparisons; trace filters and interpretation prompts.
- Review content with interaction design educators and disabled learners; document changes.

## 0.3 · AI-supported learning

- Add an AI provider layer (for example, the Claude API through the `ellmer` R package), configured with an API key in an environment variable, never in the code.
- Formative AI feedback on learner work: usability notes, wireframe critiques, sitemap labels, and reflection answers.
- AI-generated scenarios, personas, and synthetic traces for experimentation, labelled as AI-generated at point of use.
- Tell learners before any of their text is sent to an AI provider; keep every lab usable without AI.
- Teacher-reviewed prompts and examples; document known limitations and failure cases of AI feedback.

## 0.4 · Research mode, opt-in data collection

- Define a minimal, configurable event schema (which actions, which fields, why) and keep collection off by default.
- Add study information, an explicit consent gate, withdrawal and deletion, and retention and export controls before any collection.
- Store data pseudonymised, on institution-approved storage, separate from synthetic and AI-generated examples.
- Complete institutional ethics review and a data protection assessment (GDPR, with the university's Data Protection Officer) before participant studies.

## 1.0 · Release and preservation

- Accessibility audit and usability evaluation with documented methodology and consent.
- Automated checks in continuous integration, versioned teaching materials, and release checklist.
- Public repository, citation file, tagged release, and Zenodo DOI integration.

## Evaluation questions

Can learners explain a design choice using a relevant concept? Can they identify an issue and propose a testable change? Does AI feedback help learners improve their reasoning, or does it replace it? Do activities support meaningful comparison and reflection? Evaluate through voluntary, consented classroom studies with predeclared questions and transparent reporting. Do not infer learning outcomes from app usage alone.
