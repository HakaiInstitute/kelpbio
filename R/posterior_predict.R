#' Posterior predictive draws
#'
#' Draws from the posterior predictive distribution: replicate responses
#' (weights, plant sizes, transect counts, dry:wet ratios, carbon fractions, or
#' in situ biomass estimates) carrying both parameter uncertainty and
#' observation noise from the model's likelihood. With `new_data = NULL` the
#' replicates are at the observed data, as plotted by
#' [pp_check()][pp_check.kb_fit].
#'
#' @details
#' Site and year columns in `new_data` are handled as in [posterior_epred()].
#'
#' The observation noise follows the fitted likelihood: Normal on log weight
#' (*Nereocystis* weight), Gamma (*Macrocystis* weight), Weibull (*Nereocystis*
#' size), zero-truncated negative binomial (*Macrocystis* size), zero-inflated
#' negative binomial (*Nereocystis* density), negative binomial (*Macrocystis*
#' density), Beta (wet/dry and carbon), and lognormal (cover). Density draws are
#' counts on each row's `area_m2`, or on 1 m² when `new_data` has no `area_m2`
#' column. For a cover biomass fit, `new_data` must include `lower` and `upper`
#' (see [kb_fit_cover_biomass_nereo()]).
#'
#' Repeated calls return different draws; use `set.seed()` to reproduce them.
#'
#' @inheritParams params
#' @param new_data A data frame with the fit's predictor column (and optional
#'   `site`, `year`, and `stipes_m2` columns; for a density fit, an optional
#'   `area_m2` column giving each transect's area, 1 m² when absent;
#'   `canopy_area_m2`, `plot_area_m2`, `tide_height_m`, `lower`, and `upper` for
#'   a cover fit), or
#'   `NULL` to predict at the observed data.
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
  # A cover fit checks each row's in situ limits here.
  .with_call(.eval_family(object, lp, res$grid, "ran"), call)
}
