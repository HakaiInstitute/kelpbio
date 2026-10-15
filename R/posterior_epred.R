#' Response-Scale Posterior Draws
#'
#' Draws of the expected response.
#'
#' @details
#' Each draw is the expected response given that draw's parameters:
#'
#' - *Nereocystis* weight: the lognormal mean.
#' - *Macrocystis* weight: the Gamma mean.
#' - *Nereocystis* size: the Weibull mean.
#' - *Macrocystis* size: the mean of the zero-truncated negative binomial.
#' - Density: the expected count on the row's `area_m2` (1 m² when absent),
#'   including the zero inflation for *Nereocystis*.
#' - Wet/dry: the mean dry:wet ratio.
#' - Carbon: the mean carbon fraction.
#' - Cover biomass: the wet biomass per m², without the estimation error of the
#'   in situ estimate.
#'
#' For draws that include observation noise, use [posterior_predict()].
#'
#' A `site` (and optionally `year`) column in `new_data` with levels in the fit
#' gives predictions for those levels. With `new_data = NULL` the observed data
#' is used, with its sites and years.
#'
#' @inheritParams params
#' @param object A `kb_fit` object.
#' @param new_data A data frame with the fit's predictor column (and optional
#'   `site`, `year`, and `stipes_m2` columns; for a density fit, an optional
#'   `area_m2` column giving each transect's area, 1 m² when absent), or
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
  posterior::draws_of(.epred(object, res$linpred))
}
