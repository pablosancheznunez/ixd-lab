# Publish IxD Lab to shinyapps.io (run from the project directory).
# One-time setup: in RStudio, Tools > Global Options > Publishing > Connect,
# or paste the rsconnect::setAccountInfo(...) line from shinyapps.io > Account > Tokens.
stopifnot(nrow(rsconnect::accounts()) > 0)
source("tests/smoke.R")
rsconnect::deployApp(
  appDir = ".",
  appName = "ixd-lab",
  appTitle = "IxD Lab",
  appFiles = c("app.R", "R/helpers.R", list.files("R/labs", full.names = TRUE)),
  launch.browser = TRUE
)
