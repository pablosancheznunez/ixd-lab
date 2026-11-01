# IxD Lab

**An AI-Powered Learning and Experimentation Environment for Interaction Design**

**Use it online: <https://pablosancheznunez.com/ixd-lab/>**

IxD Lab is an open, modular learning studio built with R Shiny. It is an open educational resource (OER): free to use, adapt, and share. AI-supported activities and an opt-in research mode for collecting interaction data are in development (see [ROADMAP.md](ROADMAP.md)). Version 0.1.0 includes six complete labs. It does not yet use an AI provider, create accounts, or collect participant data. Simulated content is labelled as such, and activities are formative examples, not validated assessment instruments.

## Labs

| Lab | Activity | Status |
| --- | --- | --- |
| Wireframing | Build from components or templates, reorder, test three widths, live design checks, export | Ready for class |
| Information architecture | Card sort of ten pages, editable labels, comparison with a reference structure | Ready for class |
| Usability | Heuristic evaluation of three interfaces with severity ratings and a findings report | Ready for class |
| Accessibility | WCAG contrast checker with a suggested passing colour, plus a spot-the-barrier exercise | Ready for class; not a complete audit |
| Interaction patterns | Save, delete-with-undo and validation patterns, plus a pattern-choice exercise | Ready for class |
| User behaviour | Three simulated traces on a timeline, observation vs explanation, research methods | Ready for class; not human data |

All labs include learning objectives, a key idea, an experiment, and a reflection with downloadable notes. AI integration and the opt-in research mode are planned for versions 0.3 and 0.4; this release has no AI provider, user account, cookies, analytics, or data collection.

## How it runs

The app runs entirely in the visitor's browser with [Shinylive](https://posit-dev.github.io/r-shinylive/) (R compiled to WebAssembly), so it needs no R server. To publish a new version, run `source("publish.R")` from the project directory: it builds the static site and pushes it to the `gh-pages` branch, which GitHub Pages serves at <https://pablosancheznunez.com/ixd-lab/>. No external fonts, trackers, or third-party services are loaded.

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
├── ixd-lab.Rproj             # RStudio project
├── CITATION.cff              # How to cite
├── LICENSE                   # MIT (software)
├── LICENSE-CONTENT.md        # CC BY 4.0 (educational content)
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

Sánchez-Núñez, P. (2026). *IxD Lab: An AI-Powered Learning and Experimentation Environment for Interaction Design* (Version 0.1.0) [Software and open educational resource]. https://pablosancheznunez.com/ixd-lab/

GitHub also offers this citation, in APA and BibTeX, from **Cite this repository** ([CITATION.cff](CITATION.cff)).

## Author

**Pablo Sánchez-Núñez**
ORCID: [0000-0001-7845-9506](https://orcid.org/0000-0001-7845-9506) · Web: <https://pablosancheznunez.com> · Email: psancheznunez@outlook.com

Suggestions and contributions are welcome through [GitHub issues](https://github.com/pablosancheznunez/ixd-lab/issues).
