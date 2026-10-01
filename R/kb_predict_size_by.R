#' Predict Size by Grouping Factor
#'
#' Summarise the expected plant size for each level of the grouping factors named
#' in `by`: one estimate per site, per year, or per observed site-year.
#'
#' @details
#' The expected size is the mean of the fitted size distribution (see
#' [kb_predict_size()]).
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
#' @param fit A `kb_fit_size` object.
#'
#' @return A `kb_predictions` object: a summary tibble with the `by` grouping
#'   columns and `estimate`, `lower`, and `upper` columns summarising the
#'   posterior distribution of expected size.
#' @family prediction
#' @seealso [kb_predict_size()] for predictions at the rows of a supplied data
#'   frame.
#' @export
#'
#' @examples
#' kb_predict_size_by(fit_size_sim_nereo, by = "site")
kb_predict_size_by <- function(fit, by = NULL, ...) {
  UseMethod("kb_predict_size_by")
}

#' @export
kb_predict_size_by.default <- function(fit, by = NULL, ...) {
  .chk_kb_fit_size(fit, call = rlang::current_env())
  .abort_no_method("kb_predict_size_by", fit, call = rlang::current_env())
}

#' @rdname kb_predict_size_by
#' @export
kb_predict_size_by.kb_fit_size <- function(
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
  summarise_predictions(
    fit,
    res$grid,
    res$linpred,
    res$by,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = FALSE
  )
}
