#' Linear-Predictor Posterior Draws
#'
#' Draws of the linear predictor on the link scale (or, with
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
#' @param new_data A data frame with the fit's predictor column (and optional
#'   `site`, `year`, and `stipes_m2` columns; for a density fit, an optional
#'   `area_m2` column giving each transect's area, 1 m² when absent), or
#'   `NULL` for the observed data.
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
  new_levels = c("average", "sample"),
  representative_site = NULL
) {
  # error_call() names the generic, not the method.
  call <- rlang::error_call(rlang::current_env())
  .with_call(
    {
      rlang::check_dots_empty()
      chk::chk_flag(transform)
      .chk_kb_fit(object)
      .chk_representative_site(object, representative_site)
    },
    call
  )
  res <- data_linpred(object, new_data, new_levels, representative_site, call = call)
  lp <- res$linpred
  # The inverse link, not the response mean.
  if (transform) {
    lp <- .epred(object, lp, expectation = FALSE)
  }
  posterior::draws_of(lp)
}
