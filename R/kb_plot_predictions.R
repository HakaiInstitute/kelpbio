#' Plot Model Predictions
#'
#' Render a `ggplot` from a `kb_predictions` object (the output of a
#' `kb_predict_*()` function).
#'
#' @details
#' Called with just the predictions, the plot configures itself: the x-axis,
#' faceting, and geometry are inferred from the prediction's metadata. The result
#' is a standard `ggplot` that can be refined with `+` (scales, labels, themes,
#' `coord_flip()`).
#'
#' The geometry is chosen automatically, not set by an argument: a line with a
#' compatibility-interval ribbon for predictions at a [kb_new_data()] grid over
#' several predictor values (weight curves), and `geom_pointrange` otherwise (for
#' example size by site, or weight at the observed plants). Override the inferred
#' x-axis with `x`.
#'
#' Axes are linear by default, with the y-axis extended to zero. Weights,
#' densities, and biomass often span orders of magnitude; `log_axis = "y"` shows
#' them on a log scale, and `log_axis = "xy"` also log-scales a numeric x-axis,
#' as for a weight curve. A log axis says so in its title. Every value on a log
#' axis must be positive, so a cover
#' curve on log-log axes needs a grid of positive cover values (see the
#' examples).
#'
#' Only the predictions are drawn. They hold the effects not in the prediction at
#' their typical values, while each raw observation carries its own site, year,
#' and site-year effects, so raw data are not a like-for-like comparison. Add
#' them as a layer with `+` if wanted. To compare the model with the data, plot
#' the fitted values from [augment()] against the observed response, or check
#' [posterior_predict()] replicates against the data.
#'
#' @param predictions A `kb_predictions` object.
#' @param x A string naming the x-axis column, or `NULL` to infer it from the
#'   metadata.
#' @param log_axis A string, one of `"none"` (linear axes), `"y"` (log-scaled
#'   y-axis), or `"xy"` (log-scaled x- and y-axes).
#' @param max_facets A whole number capping the facet panels drawn; if the
#'   grouping has more groups, the first `max_facets` are shown with a warning.
#'   Use `Inf` to disable.
#' @param ... Unused.
#'
#' @return A `ggplot` object.
#' @family prediction
#' @export
#'
#' @examples
#' fit <- fit_weight_sim_nereo
#'
#' # Allometric curve by site (ribbon):
#' kb_predict_weight(fit, kb_new_data(fit, by = "site")) |>
#'   kb_plot_predictions()
#'
#' # Add the raw data as a layer:
#' kb_predict_weight(fit, kb_new_data(fit)) |>
#'   kb_plot_predictions() +
#'   ggplot2::geom_point(
#'     ggplot2::aes(diameter_mm, weight_kg),
#'     data = data_weight_sim_nereo,
#'     alpha = 0.3
#'   )
#'
#' # Expected size by site (pointrange):
#' kb_predict_size(
#'   fit_size_sim_nereo,
#'   kb_new_data(fit_size_sim_nereo, by = "site")
#' ) |>
#'   kb_plot_predictions()
#'
#' # Weight at a reference diameter by site (pointrange, sites on the y-axis):
#' kb_predict_weight(fit, kb_new_data(fit, by = "site", diameter_mm = 30)) |>
#'   kb_plot_predictions() +
#'   ggplot2::coord_flip()
#'
#' # Allometric curve on log-log axes:
#' kb_predict_weight(fit, kb_new_data(fit)) |>
#'   kb_plot_predictions(log_axis = "xy")
#'
#' # Cover curve on log-log axes, over positive cover values:
#' cover_fit <- fit_cover_biomass_sim_nereo
#' kb_predict_cover_biomass(
#'   cover_fit,
#'   kb_new_data(cover_fit, cover = 10^seq(-3, 0, length.out = 30))
#' ) |>
#'   kb_plot_predictions(log_axis = "xy")
kb_plot_predictions <- function(
  predictions,
  ...,
  x = NULL,
  log_axis = c("none", "y", "xy"),
  max_facets = 12L
) {
  rlang::check_dots_empty()
  chk::chk_null_or(x, vld = chk::vld_string)
  log_axis <- rlang::arg_match(log_axis)
  chk::chk_number(max_facets)
  chk::chk_gt(max_facets, value = 0)
  if (is.finite(max_facets)) {
    chk::chk_whole_number(max_facets)
  }
  .chk_predictions(predictions)

  predictor <- attr(predictions, "kb_predictor", exact = TRUE)
  response <- attr(predictions, "kb_response", exact = TRUE)
  group_vars <- attr(predictions, "kb_group_vars", exact = TRUE)

  predictor_varies <- !is.null(predictor) &&
    predictor %in% names(predictions) &&
    length(unique(predictions[[predictor]])) > 1
  inferred <- if (predictor_varies) {
    predictor
  } else {
    group_vars[length(group_vars)]
  }
  x_supplied <- !is.null(x)
  # character(0) becomes NULL so the guard below asks for `x`.
  x <- x %||% if (length(inferred)) inferred else NULL

  facet <- setdiff(group_vars, x)

  if (length(facet) && is.finite(max_facets)) {
    keys <- do.call(paste, c(predictions[facet], sep = "\r"))
    groups <- unique(keys)
    if (length(groups) > max_facets) {
      keep <- groups[seq_len(max_facets)]
      cli::cli_warn(c(
        "Showing the first {max_facets} of {length(groups)} {.field {facet}} group{?s}.",
        i = "Pre-filter {.arg predictions} or raise {.arg max_facets} to show more."
      ))
      predictions <- predictions[keys %in% keep, , drop = FALSE]
    }
  }

  .chk_plot_x(x, predictions, x_supplied)
  .chk_log_axis(log_axis, predictions, x)
  # kb_curve separates a generated grid from supplied rows with varying values.
  style <- if (
    isTRUE(attr(predictions, "kb_curve", exact = TRUE)) &&
      identical(x, predictor) &&
      predictor_varies
  ) {
    "ribbon"
  } else {
    "pointrange"
  }

  gg <- ggplot2::ggplot(
    predictions,
    ggplot2::aes(x = .data[[x]], y = .data$estimate)
  )
  if (style == "ribbon") {
    gg <- gg +
      ggplot2::geom_ribbon(
        ggplot2::aes(ymin = .data$lower, ymax = .data$upper),
        alpha = 0.2
      ) +
      ggplot2::geom_line()
  } else {
    gg <- gg +
      ggplot2::geom_pointrange(
        ggplot2::aes(ymin = .data$lower, ymax = .data$upper)
      )
  }
  if (length(facet)) {
    gg <- gg + ggplot2::facet_wrap(facet)
  }
  gg <- switch(
    log_axis,
    none = gg + ggplot2::expand_limits(y = 0),
    y = gg + ggplot2::scale_y_log10(labels = log_labels),
    xy = gg +
      ggplot2::scale_x_log10(labels = log_labels) +
      ggplot2::scale_y_log10(labels = log_labels)
  )
  gg +
    ggplot2::labs(
      x = axis_label(x, log = log_axis == "xy"),
      y = axis_label(response %||% "estimate", log = log_axis != "none")
    )
}

# Plain numbers (0.1, 1, 10) in place of the default 1e-01 style.
log_labels <- function(breaks) {
  format(
    breaks,
    big.mark = ",",
    scientific = FALSE,
    trim = TRUE,
    drop0trailing = TRUE
  )
}

# "Wet weight (kg)" becomes "Wet weight (kg, log scale)"; "Fronds" becomes
# "Fronds (log scale)".
axis_label <- function(name, log = FALSE) {
  label <- base_axis_label(name)
  if (!log) {
    return(label)
  }
  if (endsWith(label, ")")) {
    return(sub("\\)$", ", log scale)", label))
  }
  paste0(label, " (log scale)")
}

base_axis_label <- function(name) {
  switch(
    name,
    diameter_mm = "Sub-bulb diameter (mm)",
    fronds = "Fronds",
    weight_kg = "Wet weight (kg)",
    stipes_m2 = "Stipe density (stipes/m\u00b2)",
    plants_m2 = "Plant density (plants/m\u00b2)",
    biomass_kg_m2 = "Wet biomass (kg/m\u00b2)",
    dry_biomass_kg_m2 = "Dry biomass (kg/m\u00b2)",
    carbon_biomass_g_m2 = "Carbon biomass (g C/m\u00b2)",
    biomass_kg = "Total wet biomass (kg)",
    dry_biomass_kg = "Total dry biomass (kg)",
    carbon_biomass_kg = "Total carbon biomass (kg C)",
    dry_wet_ratio = "Dry:wet mass ratio",
    carbon_fraction = "Carbon fraction of dry mass",
    cover = "Tide-corrected canopy cover",
    site = "Site",
    year = "Year",
    estimate = "Estimate",
    paste0(toupper(substring(name, 1, 1)), substring(name, 2))
  )
}
