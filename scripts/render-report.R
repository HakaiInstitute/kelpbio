# Render scripts/sim-output/report.Rmd to a self-contained HTML file.
#
# Uses rmarkdown when pandoc is available (e.g. inside RStudio); otherwise falls
# back to a pandoc-free path (markdown::mark_html) with the figures embedded as
# base64 data URIs, so the output is a single shareable file either way.

src <- "scripts/sim-output/report.Rmd"
out <- "scripts/sim-output/report.html"

if (rmarkdown::pandoc_available()) {
  rmarkdown::render(src, output_file = "report.html", quiet = TRUE)
  message("Rendered via rmarkdown/pandoc: ", out)
} else {
  lines <- readLines(src, warn = FALSE)

  # strip YAML front matter, capturing the title
  title <- "Report"
  fences <- which(lines == "---")
  if (length(fences) >= 2 && fences[1] == 1) {
    yaml <- lines[(fences[1] + 1):(fences[2] - 1)]
    t <- grep("^title:", yaml, value = TRUE)
    if (length(t)) {
      title <- trimws(sub('^title:\\s*"?([^"]*)"?\\s*$', "\\1", t[1]))
    }
    body <- lines[(fences[2] + 1):length(lines)]
  } else {
    body <- lines
  }
  txt <- paste(body, collapse = "\n")

  # embed local PNG figures as base64 data URIs
  matches <- unique(unlist(regmatches(
    txt, gregexpr("\\([A-Za-z0-9_./-]+\\.png\\)", txt)
  )))
  for (m in matches) {
    path <- sub("^\\((.*)\\)$", "\\1", m)
    full <- file.path(dirname(src), basename(path))
    if (file.exists(full)) {
      txt <- gsub(m, paste0("(", xfun::base64_uri(full), ")"), txt, fixed = TRUE)
    }
  }

  markdown::mark_html(text = txt, output = out,
                      meta = list(title = title))
  message("Rendered via markdown (pandoc-free): ", out)
}
