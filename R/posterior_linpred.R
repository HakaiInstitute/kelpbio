#' Linear-Predictor Posterior Draws
#'
#' Draws of the weight-model linear predictor on the log scale (or, with
#' `transform = TRUE`, on the response scale).
#'
#' Conditioning is inferred from the grouping columns present in `newdata` (see
#' [posterior_epred()]); with `newdata = NULL` the observed data is used and
#' conditioned on its site and year.
#'
#' @inheritParams params
#' @param object A `kb_fit_weight` object.
#' @param transform A flag: if `TRUE`, return the response-scale value (`exp`).
#' @param newdata A data frame with a `diameter` column (and optional `site` /
#'   `year` columns), or `NULL` for the observed data.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @family generics
#' @exportS3Method rstantools::posterior_linpred
#' @examples
#' lp <- posterior_linpred(fit_weight)
#' dim(lp)
posterior_linpred.kb_fit_weight <- function(object,
                                            transform = FALSE,
                                            newdata = NULL,
                                            new_levels = "sample",
                                            representative_site = NULL,
                                            ...) {
  rlang::check_dots_empty()
  chk::chk_flag(transform)
  .chk_kb_fit_weight(object)
  .chk_representative_site(object, representative_site)
  res <- weight_data_linpred(object, newdata, new_levels, representative_site)
  m <- posterior::draws_of(res$linpred)
  if (transform) exp(m) else m
}
