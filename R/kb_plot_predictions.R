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
#' compatibility-interval ribbon for a generated curve ([kb_predict_weight_by()]
#' over a varying predictor), and `geom_pointrange` otherwise (for example
#' [kb_predict_size_by()]). The y-axis extends to zero. Override the inferred
#' x-axis with `x`.
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
#' # Allometric curve by site (ribbon):
#' kb_predict_weight_by(fit_weight_sim_nereo, by = "site") |>
#'   kb_plot_predictions()
#'
#' # Add the raw data as a layer:
#' kb_predict_weight_by(fit_weight_sim_nereo) |>
#'   kb_plot_predictions() +
#'   ggplot2::geom_point(
#'     ggplot2::aes(diameter_mm, weight_kg),
#'     data = data_weight_sim_nereo,
#'     alpha = 0.3
#'   )
#'
#' # Expected size by site (pointrange):
#' kb_predict_size_by(fit_size_sim_nereo, by = "site") |>
#'   kb_plot_predictions()
#'
#' # Weight at a reference diameter by site (pointrange, sites on the y-axis):
#' kb_predict_weight_by(
#'   fit_weight_sim_nereo,
#'   by = "site", diameter_mm = 30, new_levels = "average"
#' ) |>
#'   kb_plot_predictions() +
#'   ggplot2::coord_flip()
kb_plot_predictions <- function(
  predictions,
  ...,
  x = NULL,
  max_facets = 12L
) {
  rlang::check_dots_empty()
  chk::chk_number(max_facets)
  chk::chk_gt(max_facets, value = 0)
  if (is.finite(max_facets)) {
    chk::chk_whole_number(max_facets)
  }
  if (!is.data.frame(predictions)) {
    cli::cli_abort(
      "{.arg predictions} must be a {.cls kb_predictions} data frame."
    )
  }
  if (!all(c("estimate", "lower", "upper") %in% names(predictions))) {
    cli::cli_abort(
      "{.arg predictions} must have {.field estimate}, {.field lower}, and {.field upper} columns."
    )
  }

  # exact = TRUE: a size prediction has no kb_predictor, which would otherwise
  # partially match kb_predictor_units.
  predictor <- attr(predictions, "kb_predictor", exact = TRUE)
  response <- attr(predictions, "kb_response", exact = TRUE)
  group_vars <- attr(predictions, "kb_group_vars", exact = TRUE)

  # A ribbon needs an ordered, generated grid over a varying predictor; supplied
  # rows and held/absent predictors render as grouped points instead.
  predictor_varies <- !is.null(predictor) &&
    predictor %in% names(predictions) &&
    length(unique(predictions[[predictor]])) > 1
  inferred <- if (predictor_varies) {
    predictor
  } else {
    group_vars[length(group_vars)]
  }
  # group_vars[length(0)] is character(0); fall through to NULL so the guard
  # below raises the helpful "supply x" error rather than a cryptic one.
  x <- x %||% if (length(inferred)) inferred else NULL

  # Layout follows from x: facet by the remaining grouping variables, never by
  # the variable on the x-axis.
  facet <- setdiff(group_vars, x)

  # Cap the number of facet panels so a many-group prediction (e.g. site x year
  # over many sites) stays readable; keep the first `max_facets` groups.
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

  if (is.null(x) || !x %in% names(predictions)) {
    cli::cli_abort(c(
      "Cannot infer the x-axis column from {.arg predictions}.",
      i = "Supply {.arg x}."
    ))
  }
  # Ribbon only for a generated curve over the varying predictor; else pointrange.
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
  x_units <- if (identical(x, predictor)) {
    attr(predictions, "kb_predictor_units", exact = TRUE)
  } else {
    NA_character_
  }
  # Every kelpbio response is non-negative, so the y-axis starts at zero and
  # differences are read against the full scale.
  gg +
    ggplot2::expand_limits(y = 0) +
    ggplot2::labs(
      x = kb_axis_label(x, x_units),
      y = kb_axis_label(
        response %||% "estimate",
        attr(predictions, "kb_response_units", exact = TRUE)
      )
    )
}

# Publication-ready axis title for a prediction column: a descriptive label for
# the known model variables. Units are appended in parentheses when supplied; the
# weight predictions supply none, so their labels are unit-free. Unrecognised columns fall back to their name (sentence-cased).
kb_axis_label <- function(name, units = NA_character_) {
  base <- switch(
    name,
    diameter_mm = "Sub-bulb diameter",
    fronds = "Fronds",
    weight_kg = "Wet weight",
    stipes_m2 = "Stipe density",
    plants_m2 = "Plant density",
    site = "Site",
    year = "Year",
    estimate = "Estimate",
    paste0(toupper(substring(name, 1, 1)), substring(name, 2))
  )
  if (!is.na(units) && nzchar(units)) paste0(base, " (", units, ")") else base
}
