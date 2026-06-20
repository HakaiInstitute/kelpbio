#' Autoplot Method for Predictions
#'
#' The conventional `ggplot2::autoplot` entry point for a `kb_predictions`
#' object: a thin wrapper on [kb_plot_predictions()]. Dispatches on the
#' prediction data frame (via its stored attributes), never on a fit.
#'
#' @param object A `kb_predictions` object.
#' @param ... Passed to [kb_plot_predictions()] (e.g. `x`, `style`, `facet`,
#'   `observed`).
#'
#' @return A `ggplot` object.
#' @family prediction
#' @exportS3Method ggplot2::autoplot
#' @examples
#' p <- kb_predict_weight_by(fit_weight, by = "site")
#' ggplot2::autoplot(p)
autoplot.kb_predictions <- function(object, ...) {
  kb_plot_predictions(object, ...)
}
