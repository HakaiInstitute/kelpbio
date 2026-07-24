#' Predict Weight for New Data
#'
#' Predict weight for the supplied rows, or for the observed data when
#' `new_data = NULL`. For an allometric curve over a diameter sequence, use
#' [kb_predict_weight_by()] instead.
#'
#' @details
#' Conditioning is resolved per row: a `site`/`year` value the model has seen is
#' conditioned on its estimated random effects; a new site or year, or an absent
#' grouping column, is handled by `new_levels`.
#'
#' With the default `new_levels = "sample"`, an absent or new group draws a random
#' effect from its estimated distribution, so the interval includes between-group
#' variation; `"average"` instead holds those random effects at zero. `"sample"`
#' draws fresh values on each call; set a seed with `set.seed()` for a
#' reproducible interval. `"sample"` is the default because it produces honest
#' uncertainty for a new, unobserved site/year.
#'
#' For a new site, `representative_site` offers a third approach: instead of
#' `new_levels` (`"sample"` or `"average"`) it borrows the site intercept and
#' slope of one or more named reference sites (the per-draw average across
#' several). The `site:year` interaction still follows `new_levels`.
#'
#' @inheritParams params
#' @param fit A `kb_fit_weight` object.
#' @param new_data A data frame with a `diameter` column (and optional `site` /
#'   `year` columns), or `NULL` to predict at the observed data.
#'
#' @return A `kb_predictions` object: the input rows with added `estimate`,
#'   `lower`, and `upper` columns.
#' @family prediction
#' @seealso [kb_predict_weight_by()] to generate new_data by grouping factors
#' and diameter sequence, and [augment()] for fitted/residual values at
#' the observed data.
#' @export
#'
#' @examples
#' new_data <- data.frame(diameter = c(20, 40, 60))
#' kb_predict_weight(fit_weight_sim_nereo, new_data, new_levels = "average")
#'
#' # Predict a new site as if it behaves like a known reference site:
#' new_site <- data.frame(diameter = c(20, 40, 60), site = "new_site")
#' kb_predict_weight(
#'   fit_weight_sim_nereo, new_site,
#'   representative_site = fit_weight_sim_nereo$meta$site_levels[1]
#' )
kb_predict_weight <- function(
  fit,
  new_data = NULL,
  ...,
  new_levels = c("sample", "average"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(fit)
  .chk_representative_site(fit, representative_site)
  .chk_summary_args(conf_level, estimate, sig_fig)

  res <- weight_data_linpred(fit, new_data, new_levels, representative_site)
  summarise_weight_predictions(
    res$grid,
    res$linpred,
    res$group_vars,
    predictor = fit$meta$predictor %||% "diameter",
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = FALSE
  )
}

# Shared summariser over a log-scale linpred rvar: exponentiate, reduce to
# estimate/lower/upper, attach kb_predictions metadata. Used by both prediction
# verbs so the summary is defined once. `curve` is TRUE for the grid-generating
# `_by` verb (ribbon-eligible) and FALSE for predictions at supplied rows.
summarise_weight_predictions <- function(
  grid,
  linpred,
  group_vars,
  predictor,
  conf_level,
  estimate,
  sig_fig,
  curve = FALSE
) {
  epred <- exp(linpred)
  a <- (1 - conf_level) / 2

  out <- grid
  # estimate reduces each row's posterior draws to a scalar, the same contract as
  # in tidy()/summary(): apply it per row over the draws matrix, not to the rvar.
  out$estimate <- signif(
    apply(posterior::draws_of(epred), 2L, estimate),
    sig_fig
  )
  out$lower <- signif(unname(posterior::quantile2(epred, a)), sig_fig)
  out$upper <- signif(unname(posterior::quantile2(epred, 1 - a)), sig_fig)

  new_kb_predictions(
    out,
    predictor = predictor,
    group_vars = group_vars,
    response = "weight",
    curve = curve
  )
}
