# Validators for kb_fit objects (.vld_/.chk_ pattern). Public functions that take
# a fit call .chk_kb_fit_weight() at their head so a wrong object errors clearly
# rather than failing deep in the prediction engine; S3 dispatch alone does not
# catch a non-fit passed to a function called directly.

.vld_kb_fit <- function(x) {
  inherits(x, "kb_fit")
}

.vld_kb_fit_weight <- function(x) {
  inherits(x, "kb_fit_weight")
}

.chk_kb_fit_weight <- function(x, x_name = deparse(substitute(x))) {
  if (.vld_kb_fit_weight(x)) {
    return(invisible(x))
  }
  cli::cli_abort(c(
    "{.arg {x_name}} must be a {.cls kb_fit_weight} object.",
    i = "See {.fun kb_fit_weight}."
  ))
}

# Validate representative_site: NULL, or a character vector of site levels
# present in the fit. Shared by the prediction entry points so the message is
# defined once.
.chk_representative_site <- function(fit, representative_site) {
  if (is.null(representative_site)) {
    return(invisible(NULL))
  }
  chk::chk_character(representative_site)
  chk::chk_not_empty(representative_site)
  bad <- setdiff(representative_site, fit$meta$site_levels)
  if (length(bad)) {
    cli::cli_abort(c(
      "Invalid {.arg representative_site} value{?s}: {.val {bad}}.",
      i = "Available site{?s}: {.val {fit$meta$site_levels}}."
    ))
  }
  invisible(NULL)
}
