# The level of the in situ limits: a kb_predictions object records its own, a
# plain data frame takes `conf_level`, and 0.95 (the prediction verbs' default)
# applies when neither gives one. A supplied level that contradicts the recorded
# one errors rather than silently rescaling every survey's precision.
cover_conf_level <- function(biomass, conf_level) {
  recorded <- attr(biomass, "kb_conf_level", exact = TRUE)
  if (!is.null(recorded) && is.na(recorded)) {
    recorded <- NULL
  }
  if (is.null(conf_level)) {
    return(recorded %||% 0.95)
  }
  chk::chk_number(conf_level)
  chk::chk_range(conf_level, c(0, 1), inclusive = FALSE)
  if (!is.null(recorded) && !isTRUE(all.equal(recorded, conf_level))) {
    cli::cli_abort(c(
      "{.arg conf_level} ({conf_level}) differs from the level recorded on {.arg biomass} ({recorded}).",
      i = "Leave {.arg conf_level} as {.code NULL} to use the recorded level."
    ))
  }
  conf_level
}
