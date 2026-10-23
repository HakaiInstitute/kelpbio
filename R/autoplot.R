#' Plot predictions with autoplot()
#'
#' Plot a `kb_predictions` object, as [kb_plot_predictions()] does.
#'
#' @param object A `kb_predictions` object.
#' @param ... Passed to [kb_plot_predictions()] (for example `x`, `log_axis`, `max_facets`).
#'
#' @returns A `ggplot` object.
#' @family prediction functions
#' @exportS3Method ggplot2::autoplot
#' @examples
#' fit <- fit_weight_sim_nereo
#' p <- kb_predict_weight(fit, kb_new_data(fit, by = "site"))
#' ggplot2::autoplot(p)
autoplot.kb_predictions <- function(object, ...) {
  kb_plot_predictions(object, ...)
}
