# Contributing

Thank you for helping improve IxD Lab. Corrections to the content, accessibility improvements, translations and new labs are welcome.

## Running the app and the tests

```r
shiny::runApp(".")          # run locally
source("tests/smoke.R")     # files, parsing and the formulas behind the labs
```

`publish.R` builds the browser version with Shinylive and publishes it.

## Small changes (welcome as pull requests)

- The README, the demo guide, the roadmap, the site files and styles.

## Changes to discuss in an issue first

- `R/` (labs, formulas and content), `content/`, `RESEARCH_ETHICS.md` and `tests/`.
- Workflows and this file.

Tests are never weakened or deleted to make them pass. Educational content is licensed CC BY 4.0 and code MIT.
