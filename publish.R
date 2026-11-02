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
            desc = "Fifteen hands-on labs for learning UX and interaction design: research methods, interviews, personas, journey maps, information architecture, wireframing, UX writing, laws of UX, usability testing, accessibility, A/B testing and ethics. Open educational resource.",
            tagline = "An AI-powered learning and experimentation environment for interaction design",
            intro = "Learn UX by doing it: fifteen hands-on labs that run in your browser, with no account. Optional AI feedback and tutor with Claude, ChatGPT or Gemini. Open educational resource by Pablo Sánchez-Núñez.",
            labs = c("Research methods", "Interviews and surveys", "Personas", "Journey mapping", "Information architecture", "Wireframing", "Interaction patterns", "UX writing", "Laws of UX", "Heuristic evaluation", "Usability testing and metrics", "Accessibility", "Behaviour analytics", "A/B testing", "Ethics and dark patterns"),
            loading = "Loading the labs… The first visit takes about 20 seconds."),
  es = list(subdir = "es", url = paste0(base_url, "es/"),
            title = "IxD Lab · Estudio de diseño de interacción",
            desc = "Quince labs prácticos para aprender UX y diseño de interacción: métodos de investigación, entrevistas, personas, mapas de recorrido, arquitectura de la información, wireframing, escritura UX, leyes de la UX, tests de usabilidad, accesibilidad, tests A/B y ética. Recurso educativo abierto.",
            tagline = "Un entorno de aprendizaje y experimentación con IA para el diseño de interacción",
            intro = "Aprende UX haciéndola: quince labs prácticos que funcionan en tu navegador, sin registro. Feedback y tutor opcionales con Claude, ChatGPT o Gemini. Recurso educativo abierto de Pablo Sánchez-Núñez.",
            labs = c("Métodos de investigación", "Entrevistas y encuestas", "Personas", "Mapas de recorrido", "Arquitectura de la información", "Wireframing", "Patrones de interacción", "Escritura UX", "Leyes de la UX", "Evaluación heurística", "Tests de usabilidad y métricas", "Accesibilidad", "Analítica del comportamiento", "Tests A/B", "Ética y patrones oscuros"),
            loading = "Cargando los labs… La primera visita tarda unos 20 segundos.")
)

# Structured data so search engines understand the page as an open learning resource.
json_ld <- function(lang, page) {
  jsonlite_free <- function(x) paste0('"', gsub('"', '\\\\"', x), '"')
  paste0('<script type="application/ld+json">{',
    '"@context":"https://schema.org","@type":"LearningResource",',
    '"name":"IxD Lab","alternateName":', jsonlite_free(page$title), ',',
    '"description":', jsonlite_free(page$desc), ',',
    '"url":', jsonlite_free(page$url), ',"inLanguage":"', lang, '",',
    '"learningResourceType":"Interactive resource","educationalLevel":"Higher education",',
    '"teaches":[', paste(vapply(page$labs, jsonlite_free, ""), collapse = ","), '],',
    '"isAccessibleForFree":true,"license":"https://creativecommons.org/licenses/by/4.0/",',
    '"identifier":"https://doi.org/10.5281/zenodo.23863524","image":"', base_url, 'og-image.png",',
    '"author":{"@type":"Person","name":"Pablo Sánchez-Núñez","url":"https://pablosancheznunez.com/",',
    '"sameAs":["https://orcid.org/0000-0001-7845-9506","https://github.com/pablosancheznunez"]}}</script>')
}

# Adds language, description, icons, structured data, sharing preview and a readable loading
# screen (also the text search engines index, since the app itself loads with JavaScript).
decorate <- function(path, lang, page) {
  html <- paste(readLines(path, encoding = "UTF-8", warn = FALSE), collapse = "\n")
  head_tags <- paste0(
    "<title>", page$title, "</title>\n",
    '    <link rel="icon" href="', base_url, 'favicon.ico" sizes="48x48" />\n',
    '    <link rel="icon" href="', base_url, 'favicon-96x96.png" type="image/png" sizes="96x96" />\n',
    '    <link rel="apple-touch-icon" href="', base_url, 'apple-touch-icon.png" />\n',
    "    ", json_ld(lang, page), "\n",
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
    '    <style>body{background:#f6f4ef}#root{position:relative;z-index:1}',
    '.ixd-intro{position:fixed;top:7vh;left:0;right:0;z-index:0;max-width:640px;margin:0 auto;padding:0 16px;text-align:center;font:15px/1.5 system-ui,sans-serif;color:#5f665f}',
    '.ixd-intro h1{font:400 30px/1.15 Georgia,serif;color:#202522;margin:0 0 .3rem}.ixd-intro h2{font:500 12px/1.4 ui-monospace,Consolas,monospace;letter-spacing:.08em;text-transform:uppercase;margin:0 0 .8rem}',
    '.ixd-intro p{margin:0 0 .6rem}.ixd-loading{position:fixed;left:0;right:0;bottom:16vh;z-index:0;text-align:center;font:15px/1.5 system-ui,sans-serif;color:#5f665f;padding:0 16px}</style>')
  loading <- paste0(
    '<header class="ixd-intro"><h1>IxD Lab</h1><h2>', page$tagline, "</h2><p>", page$intro, "</p><p>",
    paste(page$labs, collapse = " · "), "</p></header>\n    ",
    '<div class="ixd-loading" role="status">', page$loading, "</div>\n    ")
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
file.copy(list.files("site", full.names = TRUE), site_dir)
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
