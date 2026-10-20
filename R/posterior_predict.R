#' Posterior predictive draws
#'
#' Draws from the posterior predictive distribution: replicate responses
#' (weights, plant sizes, dry:wet ratios, carbon fractions, or survey biomass)
#' carrying both parameter uncertainty and observation noise from the model's
#' likelihood. With `new_data = NULL` the replicates are at the observed data,
#' as plotted by [pp_check()][pp_check.kb_fit].
#'
#' @details
#' Site and year columns in `new_data` are handled as in [posterior_epred()].
#'
#' The observation noise follows the fitted likelihood: Normal on log weight
#' (*Nereocystis* weight), Gamma (*Macrocystis* weight), Weibull (*Nereocystis*
#' size), Beta (wet/dry and carbon), and Normal censored at zero (cover
#' calibration). For a cover calibration fit, each row's spread includes the SD
#' of its survey biomass, from a `biomass_sd_kg_m2` column or a
#' `biomass_kg_m2` column of draws, and the residual alone when `new_data` has
#' neither.
#'
#' Repeated calls return different draws; use `set.seed()` to reproduce them.
#'
#' @inheritParams params
#' @param new_data A data frame with the fit's predictor column (and optional
#'   `site` and `year` columns; `canopy_area_m2`, `plot_area_m2`, and
#'   `tide_height_m` for a cover calibration fit), or `NULL` to predict at the
#'   observed data.
#'
#' @returns A draws-by-observations (`D x N`) matrix.
#' @family fit methods
#' @exportS3Method rstantools::posterior_predict
#' @examples
#' set.seed(1)
#' pp <- posterior_predict(fit_weight_sim_nereo)
#' dim(pp)
posterior_predict.kb_fit <- function(
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
  lp <- posterior::draws_of(res$linpred) # D x N, link scale
  .with_call(.eval_family(object, lp, res$grid, "ran"), call)
}
