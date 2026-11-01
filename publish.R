# Publish IxD Lab to https://pablosancheznunez.com/ixd-lab/ (run from the project directory).
# Builds the app with Shinylive and pushes the static site to the gh-pages branch,
# which GitHub Pages serves. Needs the shinylive package: install.packages("shinylive")
source("tests/smoke.R")

app_dir <- file.path(tempdir(), "ixd-lab-app")
site_dir <- file.path(tempdir(), "ixd-lab-site")
unlink(c(app_dir, site_dir), recursive = TRUE)
dir.create(app_dir)
file.copy(c("app.R", "R", "www"), app_dir, recursive = TRUE)

shinylive::export(app_dir, site_dir, template_params = list(title = "IxD Lab · Interaction design studio"))
file.create(file.path(site_dir, ".nojekyll"))

remote <- system2("git", c("remote", "get-url", "origin"), stdout = TRUE)
git <- function(...) stopifnot(system2("git", c("-C", shQuote(site_dir), ...)) == 0)
git("init", "-q", "-b", "gh-pages")
git("add", "-A")
git("commit", "-q", "-m", shQuote(paste("Publish IxD Lab", format(Sys.time(), "%Y-%m-%d %H:%M"))))
git("push", "-q", "--force", remote, "gh-pages")

cat("Published. The site updates at https://pablosancheznunez.com/ixd-lab/ in about a minute.\n")
