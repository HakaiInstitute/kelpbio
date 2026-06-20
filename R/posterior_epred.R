#' Expected Weight Posterior Draws
#'
#' Draws from the expectation of the posterior predictive distribution
#' (response-scale expected weight, `exp` of the linear predictor).
#'
#' @details
#' Conditioning is inferred from the grouping columns present in `newdata`: a
#' `site` (and optionally `year`) column with known levels is conditioned on;
#' factors with no column are handled by `new_levels`. With `newdata = NULL` the
#' observed data is used and conditioned on its site and year, so the central
#' estimate agrees with [augment()].
#'
#' @inheritParams params
#' @param object A `kb_fit_weight` object.
#' @param newdata A data frame with a `diameter_mm` column (and optional `site` /
#'   `year` columns), or `NULL` for the observed data.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @family generics
#' @seealso [kb_predict_weight()], which summarises these draws.
#' @exportS3Method rstantools::posterior_epred
#' @examples
#' ep <- posterior_epred(fit_weight)
#' dim(ep)
posterior_epred.kb_fit_weight <- function(object,
                                          newdata = NULL,
                                          new_levels = "sample",
                                          ...) {
  rlang::check_dots_empty()
  res <- weight_data_linpred(object, newdata, new_levels)
  exp(posterior::draws_of(res$linpred))
}
