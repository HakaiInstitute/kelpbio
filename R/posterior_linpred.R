#' Linear-Predictor Posterior Draws
#'
#' Draws of the weight-model linear predictor on the log scale (or, with
#' `transform = TRUE`, on the response scale).
#'
#' @details
#' Conditioning is inferred from the grouping columns present in `new_data` (see
#' [posterior_epred()]); with `new_data = NULL` the observed data is used and
#' conditioned on its site and year.
#'
#' @inheritParams params
#' @param object A `kb_fit` object.
#' @param transform A flag specifying whether to return the response-scale
#'   value (`exp`).
#' @param new_data A data frame with a `diameter` column (and optional `site` /
#'   `year` columns), or `NULL` for the observed data.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @family generics
#' @exportS3Method rstantools::posterior_linpred
#' @examples
#' lp <- posterior_linpred(fit_weight_sim_nereo)
#' dim(lp)
posterior_linpred.kb_fit <- function(
  object,
  transform = FALSE,
  new_data = NULL,
  ...,
  new_levels = "sample",
  representative_site = NULL
) {
  rlang::check_dots_empty()
  chk::chk_flag(transform)
  .chk_kb_fit(object)
  .chk_representative_site(object, representative_site)
  res <- data_linpred(object, new_data, new_levels, representative_site)
  m <- posterior::draws_of(res$linpred)
  # transform is contractually the inverse link, not the response mean.
  if (transform) .epred(object, m, expectation = FALSE) else m
}
