# Log-scale SD of each in situ biomass estimate: the log half-width of its
# lognormal limits at `conf_level` over the normal quantile.
cover_log_sd <- function(lower, upper, conf_level) {
  z <- stats::qnorm(1 - (1 - conf_level) / 2)
  (log(upper) - log(lower)) / (2 * z)
}
