#' Posterior-Predictive Draws
#'
#' Draws from the posterior predictive distribution: replicate responses (weights,
#' plant sizes, transect counts, dry:wet ratios, carbon fractions, or in situ
#' biomass estimates) carrying both parameter uncertainty and observation noise from
#' the model's likelihood. With `new_data = NULL` the replicates are at the
#' observed data, for use with `bayesplot::pp_check()`.
#'
#' @details
#' For supplied `new_data`, conditioning is inferred from the grouping columns
#' present (see [posterior_epred()]).
#'
#' The observation noise follows the fitted likelihood: Normal on log weight
#' (*Nereocystis* weight), Gamma (*Macrocystis* weight), Weibull (*Nereocystis*
#' size), zero-truncated negative binomial (*Macrocystis* size, so every draw is a
#' whole number of at least 1), zero-inflated negative binomial (*Nereocystis*
#' density), negative binomial (*Macrocystis* density), Beta (wet/dry and
#' carbon, so every draw lies between 0 and 1), and lognormal (cover). Density
#' draws are counts on each row's `area_m2`, or on 1 m² when `new_data` has no
#' `area_m2` column. Cover draws are in situ biomass estimates whose log-scale SD
#' is `error_scaling` times that implied by the row's `lower` and `upper` (at the
#' fit's `conf_level`), so cover `new_data` must carry those columns.
#'
#' The observation noise is drawn in R, for every `new_data` including `NULL`, so
#' repeated calls return different replicates. Set a seed with `set.seed()` for
#' reproducible draws.
#'
#' @inheritParams params
#' @param object A `kb_fit` object.
#' @param new_data A data frame with the fit's predictor column (and optional
#'   `site`, `year`, and `stipes_m2` columns; for a density fit, an optional
#'   `area_m2` column giving each transect's area, 1 m² when absent;
#'   `canopy_area_m2`, `plot_area_m2`, `tide_height_m`, `lower`, and `upper` for
#'   a cover fit), or
#'   `NULL` to predict at the observed data.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @family generics
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
  rlang::check_dots_empty()
  .chk_kb_fit(object)
  .chk_representative_site(object, representative_site)
  res <- data_linpred(object, new_data, new_levels, representative_site)
  lp <- posterior::draws_of(res$linpred) # D x N, link scale
  # A cover fit checks each row's in situ limits here.
  .with_call(.eval_family(object, lp, res$grid, "ran"), rlang::current_env())
}
