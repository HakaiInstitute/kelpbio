#' Power-Scaling Data for priorsense
#'
#' The posterior draws, log prior, and pointwise log-likelihood of a fit, in the
#' form the priorsense package uses, so that priorsense functions such as
#' `priorsense::powerscale_sensitivity()` and `priorsense::powerscale_plot_dens()`
#' accept a `kb_fit` directly.
#'
#' @details
#' Only the fitted parameters with a prior in the model's `kb_priors_*()` list
#' are included, and the log prior is the sum of those priors. Random-effect levels
#' are left out. [kb_sensitivity()] summarises the same computation as a table.
#'
#' @param x A `kb_fit` object.
#' @param ... Passed to `priorsense::create_priorsense_data()`.
#'
#' @return A `priorsense_data` object.
#' @family generics
#' @exportS3Method priorsense::create_priorsense_data
#' @examplesIf rlang::is_installed("priorsense")
#' priorsense::powerscale_sensitivity(fit_wetdry_sim_nereo)
create_priorsense_data.kb_fit <- function(x, ...) {
  .chk_kb_fit(x)
  .chk_sensitivity_fit(x)
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
