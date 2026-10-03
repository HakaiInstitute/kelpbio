#' Predict Method for a Weight Model Fit
#'
#' A thin wrapper on [kb_predict_weight()]: predict weight at the supplied `new_data`
#' rows (or the observed data when `new_data = NULL`). For allometric curves to
#' visualise, use [kb_predict_weight_by()].
#'
#' @inheritParams params
#' @inheritParams kb_predict_weight
#' @param object A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A `kb_predictions` object.
#' @family generics
#' @exportS3Method stats::predict
#' @examples
#' predict(fit_weight_sim_nereo, data.frame(diameter_mm = c(20, 40)))
predict.kb_fit_weight <- function(
  object,
  new_data = NULL,
  ...,
  new_levels = c("sample", "average"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  rlang::check_dots_empty()
  kb_predict_weight(
    object,
    new_data = new_data,
    new_levels = new_levels,
    representative_site = representative_site,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig
  )
}

#' Predict Method for a Size Model Fit
#'
#' A thin wrapper on [kb_predict_size()]: predict expected size at the supplied
#' `new_data` rows (or the observed data when `new_data = NULL`). For one estimate
#' per group, use [kb_predict_size_by()].
#'
#' @inheritParams params
#' @inheritParams kb_predict_size
#' @param object A `kb_fit_size` object.
#' @param ... Unused.
#'
#' @return A `kb_predictions` object.
#' @family generics
#' @exportS3Method stats::predict
#' @examples
#' predict(fit_size_sim_nereo, data.frame(site = "site1"))
predict.kb_fit_size <- function(
  object,
  new_data = NULL,
  ...,
  new_levels = c("sample", "average"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  rlang::check_dots_empty()
  kb_predict_size(
    object,
    new_data = new_data,
    new_levels = new_levels,
    representative_site = representative_site,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig
  )
}

#' Predict Method for a Density Model Fit
#'
#' A thin wrapper on [kb_predict_density()]: predict the expected count at the
#' supplied `new_data` rows, each a transect of its `area_m2` (or at the observed
#' data when `new_data = NULL`). For density per m² by group, use
#' [kb_predict_density_by()].
#'
#' @inheritParams params
#' @inheritParams kb_predict_density
#' @param object A `kb_fit_density` object.
#' @param ... Unused.
#'
#' @return A `kb_predictions` object.
#' @family generics
#' @exportS3Method stats::predict
#' @examples
#' predict(fit_density_sim_nereo, data.frame(site = "site1", area_m2 = 40))
predict.kb_fit_density <- function(
  object,
  new_data = NULL,
  ...,
  new_levels = c("sample", "average"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  rlang::check_dots_empty()
  kb_predict_density(
    object,
    new_data = new_data,
    new_levels = new_levels,
    representative_site = representative_site,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig
  )
}

#' Predict Method for a Wet/Dry Model Fit
#'
#' A thin wrapper on [kb_predict_wetdry()]: the expected dry:wet mass ratio as a
#' single estimate.
#'
#' @inheritParams params
#' @param object A `kb_fit_wetdry` object.
#' @param ... Unused.
#'
#' @return A `kb_predictions` object.
#' @family generics
#' @exportS3Method stats::predict
#' @examples
#' predict(fit_wetdry_sim_macro)
predict.kb_fit_wetdry <- function(
  object,
  ...,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  rlang::check_dots_empty()
  kb_predict_wetdry(
    object,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig
  )
}
