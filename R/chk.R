# Validators for kb_fit objects, following the bboutools .vld_/.chk_ pattern.
# Public entry points that take a fit call .chk_kb_fit_weight() at their head so
# a wrong object errors with a clear message rather than failing deep in the
# prediction engine (S3 dispatch alone does not catch a non-fit passed to a
# function called directly, e.g. kb_predict_weight()).

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
