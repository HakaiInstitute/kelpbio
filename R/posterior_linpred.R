#' Linear-Predictor Posterior Draws
#'
#' Draws of the weight-model linear predictor on the log scale (or, with
#' `transform = TRUE`, on the response scale).
#'
#' @inheritParams params
#' @param object A `kb_fit_weight` object.
#' @param transform A flag: if `TRUE`, return the response-scale value (`exp`).
#' @param newdata A data frame with a `diameter` column (and the `by` columns),
#'   or `NULL` for the observed data.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @exportS3Method rstantools::posterior_linpred
posterior_linpred.kb_fit_weight <- function(object,
                                            transform = FALSE,
                                            newdata = NULL,
                                            by = NULL,
                                            uncertainty = "marginal",
                                            ...) {
  rlang::check_dots_empty()
  chk::chk_flag(transform)
  res <- weight_grid_linpred(object, predict_newdata(object, newdata), by, uncertainty)
  m <- posterior::draws_of(res$linpred)
  if (transform) exp(m) else m
}
