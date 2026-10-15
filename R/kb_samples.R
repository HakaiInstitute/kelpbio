#' Posterior Draws
#'
#' The posterior draws of the effects a fitted model estimated.
#'
#' The `posterior` functions, such as `as_draws_df()`, `summarise_draws()`,
#' `nchains()`, `ndraws()`, and `variables()`, also accept a fit.
#' `summarise_draws(fit)` reports each parameter's Rhat and effective sample
#' size.
#'
#' @param fit A `kb_fit` object.
#' @param ... Unused.
#' @return A `posterior` `draws_rvars` object.
#' @family model
#' @export
#' @examples
#' kb_samples(fit_weight_sim_nereo)
#' posterior::summarise_draws(fit_weight_sim_nereo)
kb_samples <- function(fit, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
  posterior::as_draws(fit)
}
