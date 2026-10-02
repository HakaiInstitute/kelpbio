#' Assemble the Stan Data List for the Wet/Dry Model
#'
#' Map validated wet/dry data and a resolved prior list to the `data` block of
#' `inst/stan/wetdry.stan`, shared by both species. The model takes the dry:wet
#' mass ratio of each sample. Zero-row data is supported (for prior-only fits).
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#'
#' @return A named list suitable for `rstan::sampling(stanmodels$wetdry, data = .)`.
#' @noRd
assemble_wetdry_data <- function(data, priors, prior_only = FALSE) {
  list(
    nObs = nrow(data),
    ratio = as.numeric(data$dry_mass_g / data$wet_mass_g),
    prior_intercept_mu = priors$intercept$mean,
    prior_intercept_sd = priors$intercept$sd,
    prior_precision_rate = priors$precision$rate,
    prior_only = as.integer(prior_only)
  )
}
