#' Predict Density by Grouping Factor
#'
#' Summarise the expected density, stipes (*Nereocystis*) or plants
#' (*Macrocystis*) per m², for each level of the grouping factors named in `by`:
#' one estimate per site, per year, or per observed site-year.
#'
#' @details
#' For *Nereocystis*, the expected density includes the probability that a
#' transect holds no stipes. For the expected count on a transect of a given area,
#' use [kb_predict_density()].
#'
#' `by` selects the grouping factors that each get their own estimate,
#' conditioned on their estimated random effects. `new_levels` controls the
#' factors not named in `by`: the default `"average"` holds those random effects
#' at zero (the typical group), while `"sample"` draws a new random effect from
#' its estimated distribution, widening the uncertainty to include between-group
#' variation. Set a seed with `set.seed()` for reproducible `"sample"` intervals.
#'
#' The available `by` values are `NULL` (a single estimate for the typical site
#' and year), `"site"`, `"year"`, and `c("site", "year")`.
#'
#' @inheritParams params
#' @param fit A `kb_fit_density` object.
#'
#' @return A `kb_predictions` object: a summary tibble with the `by` grouping
#'   columns and `estimate`, `lower`, and `upper` columns summarising the
#'   posterior distribution of expected density per m².
#' @family prediction
#' @seealso [kb_predict_density()] for expected counts at the rows of a supplied
#'   data frame.
#' @export
#'
#' @examples
#' kb_predict_density_by(fit_density_sim_nereo, by = "site")
kb_predict_density_by <- function(fit, by = NULL, ...) {
  UseMethod("kb_predict_density_by")
}

#' @export
kb_predict_density_by.default <- function(fit, by = NULL, ...) {
  .chk_kb_fit_density(fit, call = rlang::current_env())
  .abort_no_method("kb_predict_density_by", fit, call = rlang::current_env())
}

#' @rdname kb_predict_density_by
#' @export
kb_predict_density_by.kb_fit_density <- function(
  fit,
  by = NULL,
  ...,
  new_levels = c("average", "sample"),
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  rlang::check_dots_empty()
  .chk_summary_args(conf_level, estimate, sig_fig)

  res <- by_linpred(fit, by, new_levels)
  # The generated grid carries one m² of transect, so the estimate is a
  # density; the helper column is dropped and the response named per m².
  grid <- res$grid
  grid[[fit$meta$offset]] <- NULL
  summarise_predictions(
    fit,
    grid,
    res$linpred,
    res$by,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = FALSE,
    response = paste0(fit$meta$response, "_m2")
  )
}
