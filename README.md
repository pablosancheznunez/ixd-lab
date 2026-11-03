# IxD Lab <img src="man/figures/logo.svg" align="right" height="139" alt="IxD Lab logo" />

**An AI-Powered Learning and Experimentation Environment for Interaction Design**

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.23863524.svg)](https://doi.org/10.5281/zenodo.23863524)

**Use it online: <https://pablosancheznunez.com/ixd-lab/> · En español: <https://pablosancheznunez.com/ixd-lab/es/>**

IxD Lab is an open, modular learning studio built with R Shiny, designed for university courses in interaction design and user experience (for example, a master's in UX). It is an open educational resource (OER): free to use, adapt, and share. Every lab offers optional AI feedback and an AI tutor with Claude, ChatGPT or Gemini, using your own API key; an opt-in research mode for collecting interaction data is in development (see [ROADMAP.md](ROADMAP.md)). IxD Lab does not create accounts or collect participant data. Simulated content is labelled as such, and activities are formative examples, not validated assessment instruments.

## Labs

Fifteen labs in three modules that follow a UX process.

| # | Lab | Activity |
| --- | --- | --- |
| | **Discover** | |
| 01 | Research methods | Match six research questions to methods on the attitudinal–behavioural / qualitative–quantitative landscape and build a research plan |
| 02 | Interviews and surveys | Diagnose biased draft questions, rewrite them with live checks, and build an interview guide |
| 03 | Personas | Tag twelve interview notes (affinity mapping) and build an evidence-based persona with checks |
| 04 | Journey mapping | Map five stages with emotions, touchpoints, pain points and opportunities, drawn as an emotional curve |
| | **Design** | |
| 05 | Information architecture | Card sort of ten pages, editable labels, comparison with a reference structure |
| 06 | Wireframing | Build from components or templates, reorder, test three widths, live design checks, export |
| 07 | Interaction patterns | Save, delete-with-undo and validation patterns, plus a pattern-choice exercise |
| 08 | UX writing | Rewrite five pieces of microcopy with readability (Flesch / Fernández-Huerta) and tone checks |
| 09 | Laws of UX | Run Fitts's and Hick's law experiments in the browser and fit the models to your own data |
| | **Evaluate** | |
| 10 | Heuristic evaluation | Heuristic evaluation of three interfaces with severity ratings and a findings report |
| 11 | Usability testing and metrics | SUS scoring, completion rates with adjusted Wald intervals, task times, and the problem-discovery curve |
| 12 | Accessibility | WCAG contrast checker with a suggested passing colour, plus a spot-the-barrier exercise (not a complete audit) |
| 13 | Behaviour analytics | Three simulated traces on a timeline, observation vs explanation, research methods (not human data) |
| 14 | A/B testing | Sample-size planning, a simulated experiment with confidence intervals, and a simulation of the peeking problem |
| 15 | Ethics and dark patterns | Audit six deceptive designs, rate their harm, and propose fair alternatives with EU legal references |

Every lab has four parts: **Learn** (objectives, a key idea, and a *Go deeper* section with theory, common mistakes and references), **Experiment** (a hands-on task with a **Load an example** shortcut), **Check** (a three-question quiz with explained answers) and **Reflect** (notes, AI feedback and an AI tutor). Notes are saved in the browser's local storage on that device only, and the home page shows progress and offers **Download my portfolio**. A searchable glossary links each term to its lab. To present IxD Lab at a conference or workshop, see [DEMO.md](DEMO.md). There are no user accounts, cookies, analytics, or data collection.

## AI feedback and tutor (optional)

In every lab, **✦ Get AI feedback** asks an AI model for 3 to 5 formative points on the activity and the learner's reflection, and **✦ Ask the AI tutor** answers questions about the lab's topic in a conversation, in the interface language. To turn it on, open **✦ AI** in the menu, choose a provider and paste your own API key; usage is billed to that account.

| Provider | Default model | Get a key |
| --- | --- | --- |
| Claude (Anthropic) | `claude-opus-5-5` | <https://console.anthropic.com/settings/keys> |
| ChatGPT (OpenAI) | `gpt-5` | <https://platform.openai.com/api-keys> |
| Gemini (Google) | `gemini-flash-latest` | <https://aistudio.google.com/app/apikey> |

- The key stays in the browser (session storage, or local storage if you tick "Remember on this device"). It is never sent to the Shiny server or to the author.
- The request goes directly from the browser to the chosen provider (`www/ai.js`). Only the lab's activity summary, the reflection, or the tutor question are sent, and only when the learner asks. A different model can be set under *Advanced: model*, for example when a provider retires the default.
- Responses are labelled as AI-generated with the provider's name. Without a key, every lab works as before.
- Because the key is held by each user, this suits teachers, demos and self-study. For a whole class without individual keys, see version 0.3 in the roadmap.

## How it runs

The app runs entirely in the visitor's browser with [Shinylive](https://posit-dev.github.io/r-shinylive/) (R compiled to WebAssembly), so it needs no R server. The interface is available in English and Spanish: every text is written once with `tr("English", "Español")`, and the language is chosen when the site is built. To run the Spanish version locally, create a file `lang.txt` containing `es` in the project directory.

To publish a new version, run `source("publish.R")` from the project directory: it builds both languages, adds the loading message and sharing preview, and pushes the static site to the `gh-pages` branch, which GitHub Pages serves at <https://pablosancheznunez.com/ixd-lab/>. Set the environment variable `IXD_DRY_RUN=1` to build without publishing. No external fonts, trackers, or third-party services are loaded; the only outside calls go to the AI provider a user chooses (Anthropic, OpenAI or Google), and only when they ask with their own key.

## Run locally

Requires R 4.1 or later, plus Shiny 1.8 or later and bslib 0.7 or later.

```r
install.packages(c("shiny", "bslib"))
shiny::runApp("ixd-lab")
```

Run the second line from the parent directory, or open `ixd-lab.Rproj` in RStudio, then open `app.R` and select **Run App**.

## Project structure

```text
ixd-lab/
├── app.R                     # App shell: navigation, home, about
├── R/
│   ├── helpers.R
│   └── labs/                 # One Shiny module per lab
├── www/styles.css            # Visual identity
├── content/                  # Teaching notes for each activity
├── tests/smoke.R             # Basic checks
├── publish.R                 # Build with Shinylive and publish to GitHub Pages
├── site/                     # Icons and sharing preview image for the published page
├── ixd-lab.Rproj             # RStudio project
├── CITATION.cff              # How to cite
├── LICENSE                   # MIT (software)
├── LICENSE-CONTENT.md        # CC BY 4.0 (educational content)
├── DEMO.md                   # Presenter guide for conferences and workshops
├── README.md
├── ROADMAP.md
├── RESEARCH_ETHICS.md
└── DESCRIPTION
```

## Development and checks

From the project directory, run `Rscript tests/smoke.R` for basic checks, then `shiny::runApp()` and open each lab to check its interactive controls. See [ROADMAP.md](ROADMAP.md) for the staged development plan and [RESEARCH_ETHICS.md](RESEARCH_ETHICS.md) for the evidence and data protection principles.

## Open educational resource

IxD Lab is published as an open educational resource, in line with the [UNESCO Recommendation on OER (2019)](https://www.unesco.org/en/legal-affairs/recommendation-open-educational-resources-oer): teaching and learning material in the public domain or released under an open license that allows no-cost access, re-use, re-purposing, adaptation, and redistribution. You can:

- **Retain** a copy of the app, the code, and the activities.
- **Reuse** them in your courses, workshops, or self-study.
- **Revise** them: translate, adapt to your context, or add new scenarios.
- **Remix** them with other open materials.
- **Redistribute** the original or your adapted version.

## Licenses

- **Software:** the source code is released under the [MIT License](LICENSE).
- **Educational content:** the learning objectives, key ideas, activities, scenarios, prompts, feedback texts, teaching notes in `content/`, and documentation are released under [Creative Commons Attribution 4.0 International (CC BY 4.0)](LICENSE-CONTENT.md).
- **Simulated data:** traces and scenarios are written for teaching and do not represent real people.

## How to cite

Sánchez-Núñez, P. (2026). *IxD Lab: An AI-Powered Learning and Experimentation Environment for Interaction Design* (Version 0.2.0) [Software and open educational resource]. Zenodo. https://doi.org/10.5281/zenodo.23863524

The DOI [10.5281/zenodo.23863524](https://doi.org/10.5281/zenodo.23863524) always points to the latest version; each release also has its own DOI on Zenodo. GitHub offers this citation, in APA and BibTeX, from **Cite this repository** ([CITATION.cff](CITATION.cff)).

## Author

**Pablo Sánchez-Núñez**
ORCID: [0000-0001-7845-9506](https://orcid.org/0000-0001-7845-9506) · Web: <https://pablosancheznunez.com> · Email: psancheznunez@outlook.com

Suggestions and contributions are welcome through [GitHub issues](https://github.com/pablosancheznunez/ixd-lab/issues).
