# Log-scale SD of each in situ biomass estimate, from its compatibility limits at
# `conf_level`. The limits of a lognormal posterior are symmetric about the log
# estimate, so their log half-width over the normal quantile is the SD.
cover_log_sd <- function(lower, upper, conf_level) {
  z <- stats::qnorm(1 - (1 - conf_level) / 2)
  (log(upper) - log(lower)) / (2 * z)
}
