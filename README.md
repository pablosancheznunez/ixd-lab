# IxD Lab

**An AI-Powered Learning and Experimentation Environment for Interaction Design**

IxD Lab is an open, modular learning studio built with R Shiny. AI-supported activities and an opt-in research mode for collecting interaction data are in development (see [ROADMAP.md](ROADMAP.md)). This 0.1.0 prototype includes six visible labs and a working starter activity in each. It does not yet require an AI provider, create an account, or collect participant data. The user behaviour trace is explicitly synthetic. Activities are formative examples, not validated assessment instruments.

## Run locally

Requires R 4.1 or later, plus Shiny 1.8 or later and bslib 0.7 or later.

```r
install.packages(c("shiny", "bslib"))
shiny::runApp("ixd-lab")
```

Run the second line from the parent directory, or open `app.R` in RStudio and select **Run App**. Google Fonts are an optional visual enhancement; system fonts remain as fallback.

## Labs and current status

| Lab | Working starter activity | Status |
| --- | --- | --- |
| Wireframing | Add/remove components, change canvas width, export a text sketch | Operational prototype |
| Information architecture | Place course content into labelled sitemap categories | Starter activity |
| Usability | Heuristic review prompt with formative feedback | Starter activity |
| Accessibility | WCAG contrast ratio estimate and live text preview | Starter activity; not a complete audit |
| Interaction patterns | Compare inline status notification and confirmation dialog | Starter activity |
| User behaviour | Inspect a clearly labelled synthetic navigation trace | Starter activity; not human data |

All labs include learning objectives, an experiment, and a reflection prompt. There is no AI integration, user account, telemetry, or persistent research mode in this release. Do not represent simulated examples as empirical findings.

## Project structure

```text
ixd-lab/
├── app.R
├── R/
│   ├── helpers.R
│   └── labs/                 # One Shiny module per lab
├── tests/                    # Basic source and helper checks
├── content/                  # Initial teaching activity notes
├── www/                      # Optional local CSS, scripts, and images
├── README.md
├── ROADMAP.md
├── RESEARCH_ETHICS.md
├── DESCRIPTION
└── LICENSE
```

## Development and checks

From the project directory, run `Rscript tests/smoke.R` for basic checks. For the app, run `shiny::runApp()` and open each lab to check its interactive controls. See [ROADMAP.md](ROADMAP.md) for the staged development plan and [RESEARCH_ETHICS.md](RESEARCH_ETHICS.md) for a proposed evidence protocol. No tests or live app execution could be confirmed in the authoring environment if R is unavailable there.

## Open source and preservation

The software is licensed under the MIT License. Before a public release, replace the example maintainer contact, add repository URL and citation metadata, review accessibility with users, and configure a GitHub release with Zenodo DOI integration. Teaching content may need a separate Creative Commons license; obtain contributor agreement before publishing it.
