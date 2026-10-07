# Names of the estimated parameters, from meta.
.terms <- function(fit, include_random_effects) {
  terms <- fit$meta$terms
  if (include_random_effects) c(terms$fixed, terms$random) else terms$fixed
}

# Draws of the estimated effects only. Effects the data switched off (e.g.
# site:year for single-year data) were sampled from their priors, so every
# surface that reports parameters reads through here.
.fitted_draws <- function(fit) {
  posterior::subset_draws(fit$draws, variable = .terms(fit, TRUE))
}

# Sampler diagnostics for the estimated effects; rows are per element
# ("site_effect[2]"), so match on the name before the index.
.fitted_diagnostics <- function(fit) {
  s <- fit$diagnostics$summary
  s[sub("\\[.*$", "", s$variable) %in% .terms(fit, TRUE), , drop = FALSE]
}
