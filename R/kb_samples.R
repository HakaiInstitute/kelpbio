#' Posterior Draws
#'
#' The posterior draws of the effects a fitted model estimated.
#'
#' `kb_samples(fit)` is `posterior::as_draws(fit)`, so the other `posterior`
#' conversions, such as `as_draws_df()`, and `summarise_draws()` accept a fit
#' directly, as they do a brms or cmdstanr fit.
#'
#' @param fit A `kb_fit` object.
#' @param ... Unused.
#' @return A `posterior` `draws_rvars` object.
#' @family generics
#' @export
#' @examples
#' kb_samples(fit_weight_sim_nereo)
#' posterior::summarise_draws(fit_weight_sim_nereo)
kb_samples <- function(fit, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
  posterior::as_draws(fit)
}
