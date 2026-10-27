#' Assemble the Stan Data List for the Nitrogen Model
#'
#' Map validated nitrogen data and a resolved prior list to the `data` block of
#' `inst/stan/nitrogen.stan`, shared by both species. The model takes the nitrogen
#' fraction of each sample, computed from its nitrogen and sample masses. Zero-row
#' data is supported (for prior-only fits).
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#'
#' @returns A named list suitable for `rstan::sampling(stanmodels$nitrogen, data = .)`.
#' @noRd
assemble_nitrogen_data <- function(data, priors, prior_only = FALSE) {
  c(
    list(
      n_obs = nrow(data),
      nitrogen_fraction = as.numeric(nitrogen_fraction(data)),
      prior_only = as.integer(prior_only)
    ),
    prior_data(priors)
  )
}
