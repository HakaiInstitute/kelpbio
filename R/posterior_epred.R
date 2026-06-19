#' Expected Weight Posterior Draws
#'
#' Draws from the expectation of the posterior predictive distribution
#' (response-scale expected weight, `exp` of the linear predictor) for the
#' weight model. The prediction engine; [kb_predict_weight()] summarises it.
#'
#' @inheritParams params
#' @param object A `kb_fit_weight` object.
#' @param newdata A data frame with a `diameter` column (and the `by` columns),
#'   or `NULL` for the observed data.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @family generics
#' @exportS3Method rstantools::posterior_epred
posterior_epred.kb_fit_weight <- function(object,
                                          newdata = NULL,
                                          by = NULL,
                                          uncertainty = "marginal",
                                          ...) {
  rlang::check_dots_empty()
  res <- weight_grid_linpred(object, predict_newdata(object, newdata), by, uncertainty)
  exp(posterior::draws_of(res$linpred))
}
