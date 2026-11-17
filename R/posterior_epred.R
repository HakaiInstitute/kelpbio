#' Draws of the expected response
#'
#' Draws of the expected response.
#'
#' @details
#' Each draw is the expected response, the mean of the fit's likelihood (see
#' [kb_model_describe()]), given that draw's parameters. For a cover
#' calibration with a presence part, it includes the probability that the plot
#' holds plants. For a *Nereocystis* weight fit, which is modelled on the log
#' scale, it is the mean weight, not the median.
#'
#' For draws that include observation noise, use [posterior_predict()].
#'
#' A `site` (and optionally `year`) column in `new_data` with levels in the fit
#' gives predictions for those levels. With `new_data = NULL` the observed data
#' is used, with its sites and years.
#'
#' @inheritParams params
#' @param new_data A data frame with the fit's predictor column (and optional
#'   `site` and `year` columns), or `NULL` for the observed data.
#'
#' @returns A draws-by-observations (`D x N`) matrix.
#' @family fit methods
#' @seealso [kb_predict_weight()], which summarises these draws.
#' @exportS3Method rstantools::posterior_epred
#' @examples
#' ep <- posterior_epred(fit_weight_sim_nereo)
#' dim(ep)
posterior_epred.kb_fit <- function(
  object,
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
      .chk_kb_fit(object)
      .chk_representative_site(object, representative_site)
    },
    call
  )
  res <- data_linpred(object, new_data, new_levels, representative_site, call = call)
  posterior::draws_of(.epred(object, res$linpred, grid = res$grid))
}
