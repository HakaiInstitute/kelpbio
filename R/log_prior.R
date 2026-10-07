# The joint log prior density per draw (length D), summed over the fitted
# parameters that carry a prior, each evaluated at its draws under the prior
# entry of the same name. The standard-normal priors on the non-centred
# deviates (z_*) are left out: they are fixed by the parameterisation, not a
# prior a user sets. The renormalisation of priors truncated at zero is the same
# for every draw and is omitted, so this suits power-scaling, not model
# comparison.
log_prior <- function(fit) {
  total <- numeric(posterior::ndraws(fit$draws))
  for (term in fit$meta$terms$fixed) {
    x <- as.vector(posterior::draws_of(fit$draws[[term]]))
    total <- total + log_prior_density(fit$meta$priors[[term]], x)
  }
  total
}

# Log density of one parameter's draws under its prior.
log_prior_density <- function(prior, x) {
  UseMethod("log_prior_density")
}

#' @export
log_prior_density.kb_prior_normal <- function(prior, x) {
  stats::dnorm(x, prior$mean, prior$sd, log = TRUE)
}

#' @export
log_prior_density.kb_prior_exponential <- function(prior, x) {
  stats::dexp(x, prior$rate, log = TRUE)
}

#' @export
log_prior_density.kb_prior_lognormal <- function(prior, x) {
  stats::dlnorm(x, prior$meanlog, prior$sdlog, log = TRUE)
}

#' @export
log_prior_density.default <- function(prior, x) {
  cli::cli_abort(
    "Internal error: no log density for a {.cls {class(prior)[1]}} prior.",
    .internal = TRUE
  )
}
