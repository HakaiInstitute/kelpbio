# Level of the in situ limits: recorded on a kb_predictions object, else
# `conf_level`, else 0.95. A supplied level contradicting the recorded one errors,
# since it would rescale every survey's precision.
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
