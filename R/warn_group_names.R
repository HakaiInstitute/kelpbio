# Warn when a site or year value contains a comma or square bracket. Per-level
# effects are flattened to names such as site_year_effect[<site>,<year>], which tools
# like tidybayes parse back into levels by splitting on the comma inside the
# brackets, so such values make the names ambiguous. A warning, not an error:
# indexing the draws by name in R is unaffected.
warn_group_names <- function(data, x_name) {
  for (col in intersect(c("site", "year"), names(data))) {
    values <- unique(as.character(data[[col]]))
    bad <- values[grepl("[],[]", values)]
    if (length(bad)) {
      nm <- kb_xname(x_name, col)
      cli::cli_warn(c(
        "{nm} has value{?s} {.val {bad}} containing a comma or square bracket.",
        i = "Parameter names such as {.code site_year_effect[<site>,<year>]} built from such values cannot be split back into their levels by tools that parse them."
      ))
    }
  }
  invisible(data)
}
