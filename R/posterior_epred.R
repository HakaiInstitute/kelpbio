#' Response-Scale Posterior Draws
#'
#' Draws of the expected response.
#'
#' @details
#' Each draw is the expected response given that draw's parameters, where `mu` is
#' the linear predictor: for weight, `exp(mu + sWeight^2 / 2)` (*Nereocystis*) or
#' `exp(mu)` (*Macrocystis*); for size, `exp(mu)` (*Nereocystis*) or the mean of
#' the zero-truncated distribution (*Macrocystis*); for density, the expected
#' count on the row's `area_m2`, `(1 - zi) * exp(mu)` with `zi` the
#' zero-inflation probability (*Nereocystis*) or `exp(mu)` (*Macrocystis*). For
#' draws that include observation noise, use [posterior_predict()].
#'
#' Conditioning is inferred from the grouping columns present in `new_data`: a
#' `site` (and optionally `year`) column with known levels is conditioned on;
#' factors with no column are handled by `new_levels`. With `new_data = NULL` the
#' observed data is used and conditioned on its site and year, so the central
#' estimate agrees with [augment()].
#'
#' @inheritParams params
#' @param object A `kb_fit` object.
#' @param new_data A data frame with the fit's predictor column (and optional
#'   `site`, `year`, and `stipes_m2` columns; `area_m2` for a density fit), or
#'   `NULL` for the observed data.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @family generics
#' @seealso [kb_predict_weight()], which summarises these draws.
#' @exportS3Method rstantools::posterior_epred
#' @examples
#' ep <- posterior_epred(fit_weight_sim_nereo)
#' dim(ep)
posterior_epred.kb_fit <- function(
  object,
  new_data = NULL,
  ...,
  new_levels = "sample",
  representative_site = NULL
) {
  rlang::check_dots_empty()
  .chk_kb_fit(object)
  .chk_representative_site(object, representative_site)
  res <- data_linpred(object, new_data, new_levels, representative_site)
  .epred(object, posterior::draws_of(res$linpred))
}
