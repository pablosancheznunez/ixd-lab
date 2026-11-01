# Presenting IxD Lab as a demo

A guide for showing IxD Lab at a conference demo session, poster session or workshop.

- **Live app:** <https://pablosancheznunez.com/ixd-lab/> · Spanish: <https://pablosancheznunez.com/ixd-lab/es/>
- **QR code for attendees:** [`site/qr-ixd-lab.png`](site/qr-ixd-lab.png) (also published at <https://pablosancheznunez.com/ixd-lab/qr-ixd-lab.png>)
- **Cite:** Sánchez-Núñez, P. (2026). *IxD Lab: An AI-Powered Learning and Experimentation Environment for Interaction Design* (Version 0.1.0). Zenodo. <https://doi.org/10.5281/zenodo.23863524>

## Before the session

1. Open the app on the demo laptop at least once while you have a good connection. The first visit downloads R for the browser (about 20 seconds); later visits load from the browser cache.
2. If you want to show AI feedback, open **✦ AI**, paste your Anthropic API key and tick "Remember on this device". Check that your account has credit.
3. Prepare the offline fallback (below) in case the venue Wi-Fi fails.
4. Print the QR code on the poster or a table card so attendees can try the labs on their phones.

## Five-minute walkthrough

| Time | Show | Say |
| --- | --- | --- |
| 0:00 | Home page | "Six hands-on labs for learning interaction design, open and bilingual, running entirely in the browser." |
| 0:45 | Wireframing → **Load an example** → switch to Mobile | "Learners build a page and get formative design checks as they go." |
| 1:45 | Usability → **Load an example** | "Heuristic evaluation with severity ratings, exported as a findings report." |
| 2:30 | Accessibility → **Load an example** | "Contrast is checked against WCAG, with the closest passing colour, and learners name the barriers contrast cannot catch." |
| 3:15 | Any lab → **✦ Get AI feedback** | "Optional formative feedback from Claude, with the learner's own key, labelled as AI-generated." |
| 4:00 | Home → **Download all my notes**, then **ES** | "Every lab ends with a reflection; learners keep a portfolio. The whole resource is in Spanish too." |
| 4:30 | QR code | "It is an open educational resource: MIT code, CC BY content, with a DOI. Try it now." |

**Load an example** fills a lab with a worked example in one click, so you never type during a demo.

## Offline fallback

If the venue has no reliable internet, run the app locally from RStudio:

```r
shiny::runApp("ixd-lab")
```

Everything works offline except AI feedback, which needs the Claude API.

## Suggested demo abstract (about 150 words)

> IxD Lab is an open, browser-based learning environment for interaction design education. Six labs cover wireframing, information architecture, usability, accessibility, interaction patterns and user behaviour. Each lab follows a learn–experiment–reflect cycle: a key concept, a hands-on task with formative feedback, and a written reflection that learners can download as a portfolio. Optional AI feedback from a large language model comments on the learner's work and reflection; it runs with the learner's own API key, is labelled as AI-generated, and is never required. IxD Lab is built with R Shiny and runs entirely in the browser through WebAssembly, so it needs no server, accounts or data collection. It is bilingual (English and Spanish) and released as an open educational resource (MIT and CC BY 4.0) with a DOI. The demo shows how the labs support studio-style teaching and how an opt-in research mode will study how people learn interaction design.

## What a demo paper usually needs

Most demo tracks ask for a short paper (2–4 pages) with a link to the system and often a video. Describe the learning design and the design rationale, what is novel, and how you plan to evaluate it; do not claim learning outcomes that have not been measured. See [RESEARCH_ETHICS.md](RESEARCH_ETHICS.md) for the evaluation plan.
