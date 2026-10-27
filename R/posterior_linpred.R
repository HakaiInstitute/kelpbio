#' Draws of the linear predictor
#'
#' Draws of the linear predictor on the link scale (or, with
#' `transform = TRUE`, on the response scale).
#'
#' @details
#' Site and year columns in `new_data` are handled as in [posterior_epred()];
#' with `new_data = NULL` the observed data is used, with its sites and years.
#'
#' @inheritParams posterior_epred.kb_fit
#' @inheritParams params
#' @param transform A flag specifying whether to apply the inverse link (`exp`,
#'   or the inverse logit for wet/dry, carbon, and nitrogen).
#'
#' @returns A draws-by-observations (`D x N`) matrix.
#' @family fit methods
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
