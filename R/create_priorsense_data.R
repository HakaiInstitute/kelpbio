# The power-scaling data priorsense reads from a fit, so that its functions
# (powerscale_sensitivity(), powerscale_plot_dens(), ...) accept a kb_fit
# directly; kb_sensitivity() summarises the same computation. Only the fitted
# parameters with a prior entry are included, the log prior is the sum of those
# priors, and random-effect levels are left out. `...` is passed to
# priorsense::create_priorsense_data().
#' @exportS3Method priorsense::create_priorsense_data
create_priorsense_data.kb_fit <- function(x, ...) {
  .chk_kb_fit(x)
  .chk_likelihood_fit(x, "its prior sensitivity cannot be assessed")
  nchains <- posterior::nchains(x$draws)
  # Stored draws are chain-major, so rows map onto the same chains.
  as_chains <- function(name, values) {
    rvars <- rlang::set_names(
      list(posterior::rvar(values, nchains = nchains)),
      name
    )
    posterior::as_draws_array(posterior::as_draws_rvars(rvars))
  }
  draws <- posterior::as_draws_array(
    posterior::subset_draws(x$draws, variable = x$meta$terms$fixed)
  )
  priorsense::create_priorsense_data(
    draws,
    log_prior = as_chains("lprior", log_prior(x)),
    log_lik = as_chains("log_lik", log_lik(x)),
    ...
  )
}
