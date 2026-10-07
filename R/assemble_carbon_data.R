#' Assemble the Stan Data List for the Carbon Model
#'
#' Map validated carbon data and a resolved prior list to the `data` block of
#' `inst/stan/carbon.stan`, shared by both species. The model takes the carbon
#' fraction of each sample, computed from its carbon and sample masses. Zero-row
#' data is supported (for prior-only fits).
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#'
#' @return A named list suitable for `rstan::sampling(stanmodels$carbon, data = .)`.
#' @noRd
assemble_carbon_data <- function(data, priors, prior_only = FALSE) {
  c(
    list(
      n_obs = nrow(data),
      carbon_fraction = as.numeric(carbon_fraction(data)),
      prior_only = as.integer(prior_only)
    ),
    prior_data(priors)
  )
}
