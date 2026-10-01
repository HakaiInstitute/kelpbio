# The stored draws of the effects the fit estimated. A fit also stores draws for
# effects the data switched off (site:year for single-year data, density when not
# recorded): those were sampled from their priors and never met the data, so every
# surface that reports parameters reads them through here.
.fitted_draws <- function(fit) {
  posterior::subset_draws(fit$draws, variable = .terms(fit, TRUE))
}
