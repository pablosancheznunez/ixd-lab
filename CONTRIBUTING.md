# Contributing

Thank you for helping improve IxD Lab. Corrections to the content, accessibility improvements, translations and new labs are welcome.

## Running the app and the tests

```r
shiny::runApp(".")          # run locally
source("tests/smoke.R")     # files, parsing and the formulas behind the labs
```

`publish.R` builds the browser version with Shinylive and publishes it.

## Changes that may be made without the maintainer's review

- The README, the demo guide, the roadmap, the site files and styles.

## Changes that always need the maintainer's review

- `R/` (labs, formulas and content), `content/`, `RESEARCH_ETHICS.md` and `tests/`.
- Workflows, `.maintenance.json`, `CODEOWNERS` and this file.

Tests are never weakened or deleted to make them pass. Educational content is licensed CC BY 4.0 and code MIT.
