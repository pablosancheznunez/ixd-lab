# Publish IxD Lab to https://pablosancheznunez.com/ixd-lab/ (English) and /ixd-lab/es/ (Spanish).
# Run from the project directory. Builds the app with Shinylive and pushes the static site to the
# gh-pages branch, which GitHub Pages serves. Needs the shinylive package: install.packages("shinylive")
source("tests/smoke.R")

base_url <- "https://pablosancheznunez.com/ixd-lab/"
site_dir <- file.path(tempdir(), "ixd-lab-site")
unlink(site_dir, recursive = TRUE)

pages <- list(
  en = list(subdir = "", url = base_url,
            title = "IxD Lab · Interaction design studio",
            desc = "Six hands-on labs for learning interaction design: wireframing, information architecture, usability, accessibility, interaction patterns and user behaviour. Open educational resource.",
            loading = "Loading the labs… The first visit takes about 20 seconds."),
  es = list(subdir = "es", url = paste0(base_url, "es/"),
            title = "IxD Lab · Estudio de diseño de interacción",
            desc = "Seis labs prácticos para aprender diseño de interacción: wireframing, arquitectura de la información, usabilidad, accesibilidad, patrones de interacción y comportamiento del usuario. Recurso educativo abierto.",
            loading = "Cargando los labs… La primera visita tarda unos 20 segundos.")
)

# Adds language, description, sharing preview and a loading message to Shinylive's outer page.
decorate <- function(path, lang, page) {
  html <- paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = "\n")
  head_tags <- paste0(
    "<title>", page$title, "</title>\n",
    '    <meta name="description" content="', page$desc, '" />\n',
    '    <meta name="author" content="Pablo Sánchez-Núñez" />\n',
    '    <link rel="canonical" href="', page$url, '" />\n',
    '    <link rel="alternate" hreflang="en" href="', pages$en$url, '" />\n',
    '    <link rel="alternate" hreflang="es" href="', pages$es$url, '" />\n',
    '    <link rel="license" href="https://creativecommons.org/licenses/by/4.0/" />\n',
    '    <meta property="og:type" content="website" />\n',
    '    <meta property="og:title" content="', page$title, '" />\n',
    '    <meta property="og:description" content="', page$desc, '" />\n',
    '    <meta property="og:url" content="', page$url, '" />\n',
    '    <meta property="og:image" content="', base_url, 'og-image.png" />\n',
    '    <meta property="og:locale" content="', if (lang == "es") "es_ES" else "en_GB", '" />\n',
    '    <meta name="twitter:card" content="summary_large_image" />\n',
    '    <style>#root{position:relative;z-index:1}.ixd-loading{position:fixed;left:0;right:0;bottom:18vh;z-index:0;text-align:center;',
    'font:16px/1.5 system-ui,sans-serif;color:#5f665f;padding:0 16px}.ixd-loading strong{font:22px Georgia,serif;color:#202522}</style>')
  loading <- paste0('<div class="ixd-loading" role="status"><strong>IxD Lab</strong><br>', page$loading, "</div>\n    ")
  html <- sub("<html lang=\"en\">", sprintf("<html lang=\"%s\">", lang), html, fixed = TRUE)
  html <- sub("<title>[^<]*</title>", head_tags, html)
  html <- sub("<div style=\"height: 100vh; width: 100vw\" id=\"root\"></div>", paste0(loading, "<div style=\"height: 100vh; width: 100vw\" id=\"root\"></div>"), html, fixed = TRUE)
  writeLines(enc2utf8(html), path, useBytes = TRUE)
}

for (lang in names(pages)) {
  app_dir <- file.path(tempdir(), paste0("ixd-lab-app-", lang))
  unlink(app_dir, recursive = TRUE)
  dir.create(app_dir)
  file.copy(c("app.R", "R", "www"), app_dir, recursive = TRUE)
  writeLines(lang, file.path(app_dir, "lang.txt"))
  shinylive::export(app_dir, site_dir, subdir = pages[[lang]]$subdir)
  decorate(file.path(site_dir, pages[[lang]]$subdir, "index.html"), lang, pages[[lang]])
}
file.copy("site/og-image.png", site_dir)
file.create(file.path(site_dir, ".nojekyll"))

# Set IXD_DRY_RUN=1 to build the site locally without publishing it.
if (nzchar(Sys.getenv("IXD_DRY_RUN"))) {
  cat("Site built in", site_dir, "(not published).\n")
} else {
  remote <- system2("git", c("remote", "get-url", "origin"), stdout = TRUE)
  git <- function(...) stopifnot(system2("git", c("-C", shQuote(site_dir), ...)) == 0)
  git("init", "-q", "-b", "gh-pages")
  git("add", "-A")
  git("commit", "-q", "-m", shQuote(paste("Publish IxD Lab", format(Sys.time(), "%Y-%m-%d %H:%M"))))
  git("push", "-q", "--force", remote, "gh-pages")
  cat("Published. The site updates at", base_url, "and", pages$es$url, "in about a minute.\n")
}
