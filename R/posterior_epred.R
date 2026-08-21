#' Response-Scale Posterior Draws
#'
#' Draws of the response-scale value of the linear predictor, the expectation of
#' the posterior predictive distribution.
#'
#' @details
#' Conditioning is inferred from the grouping columns present in `new_data`: a
#' `site` (and optionally `year`) column with known levels is conditioned on;
#' factors with no column are handled by `new_levels`. With `new_data = NULL` the
#' observed data is used and conditioned on its site and year, so the central
#' estimate agrees with [augment()].
#'
#' @inheritParams params
#' @param object A `kb_fit` object.
#' @param new_data A data frame with a `diameter` column (and optional `site` /
#'   `year` columns), or `NULL` for the observed data.
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
