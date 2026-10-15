#' Predict Method for a Weight Model Fit
#'
#' Predict the expected weight at the rows of `new_data`, or at the observed
#' data when `new_data = NULL`. Equivalent to [kb_predict_weight()].
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
  new_levels = c("average", "sample"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  # error_call() names the generic, not the wrapped verb.
  .with_call(
    {
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
    },
    rlang::error_call(rlang::current_env())
  )
}

#' Predict Method for a Size Model Fit
#'
#' Predict the expected size at the rows of `new_data`, or at the observed data
#' when `new_data = NULL`. Equivalent to [kb_predict_size()].
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
#' predict(fit_size_sim_nereo, data.frame(site = "otter_cove"))
predict.kb_fit_size <- function(
  object,
  new_data = NULL,
  ...,
  new_levels = c("average", "sample"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  # error_call() names the generic, not the wrapped verb.
  .with_call(
    {
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
    },
    rlang::error_call(rlang::current_env())
  )
}

#' Predict Method for a Density Model Fit
#'
#' Predict the expected density per m² at the rows of `new_data`, or at the
#' observed transects when `new_data = NULL`. Equivalent to
#' [kb_predict_density()].
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
#' predict(fit_density_sim_nereo, data.frame(site = "otter_cove"))
predict.kb_fit_density <- function(
  object,
  new_data = NULL,
  ...,
  new_levels = c("average", "sample"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  # error_call() names the generic, not the wrapped verb.
  .with_call(
    {
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
    },
    rlang::error_call(rlang::current_env())
  )
}

#' Predict Method for a Wet/Dry Model Fit
#'
#' Summarise the expected dry:wet ratio as a single estimate. Equivalent to
#' [kb_predict_wetdry()].
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
  # error_call() names the generic, not the wrapped verb.
  .with_call(
    {
      rlang::check_dots_empty()
      kb_predict_wetdry(
        object,
        conf_level = conf_level,
        estimate = estimate,
        sig_fig = sig_fig
      )
    },
    rlang::error_call(rlang::current_env())
  )
}

#' Predict Method for a Carbon Model Fit
#'
#' Summarise the expected carbon fraction of dry mass as a single estimate.
#' Equivalent to [kb_predict_carbon()].
#'
#' @inheritParams params
#' @param object A `kb_fit_carbon` object.
#' @param ... Unused.
#'
#' @return A `kb_predictions` object.
#' @family generics
#' @exportS3Method stats::predict
#' @examples
#' predict(fit_carbon_sim_macro)
predict.kb_fit_carbon <- function(
  object,
  ...,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  # error_call() names the generic, not the wrapped verb.
  .with_call(
    {
      rlang::check_dots_empty()
      kb_predict_carbon(
        object,
        conf_level = conf_level,
        estimate = estimate,
        sig_fig = sig_fig
      )
    },
    rlang::error_call(rlang::current_env())
  )
}

#' Predict Method for a Cover Biomass Model Fit
#'
#' Predict the expected wet biomass per m² of plot at the rows of `new_data`, or
#' at the observed data when `new_data = NULL`. Equivalent to
#' [kb_predict_cover_biomass()].
#'
#' @inheritParams params
#' @inheritParams kb_predict_cover_biomass
#' @param object A `kb_fit_cover_biomass` object.
#' @param ... Unused.
#'
#' @return A `kb_predictions` object.
#' @family generics
#' @exportS3Method stats::predict
#' @examples
#' predict(
#'   fit_cover_biomass_sim_macro,
#'   data.frame(canopy_area_m2 = 120, plot_area_m2 = 200, tide_height_m = 0.5)
#' )
predict.kb_fit_cover_biomass <- function(
  object,
  new_data = NULL,
  ...,
  new_levels = c("average", "sample"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  # error_call() names the generic, not the wrapped verb.
  .with_call(
    {
      rlang::check_dots_empty()
      kb_predict_cover_biomass(
        object,
        new_data = new_data,
        new_levels = new_levels,
        representative_site = representative_site,
        conf_level = conf_level,
        estimate = estimate,
        sig_fig = sig_fig
      )
    },
    rlang::error_call(rlang::current_env())
  )
}
