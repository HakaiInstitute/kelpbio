#' Plot Model Predictions
#'
#' Render a `ggplot` from a `kb_predictions` object (the output of a
#' `kb_predict_*()` function). It operates on prediction data frames, never on a
#' fit object.
#'
#' @details
#' `x` defaults to `NULL` and is inferred from the prediction's metadata (the
#' predictor column, or the grouping factor when the predictor does not vary); it
#' remains overridable. The layout follows from `x`: the remaining grouping
#' variables are always faceted, so the variable on the x-axis is never also used
#' as a facet. The plot style is derived, not an argument: a line with a
#' credible-interval ribbon is drawn only for a generated curve (the output of
#' [kb_predict_weight_by()] over a varying predictor); every other prediction
#' renders as `geom_pointrange`. When the predictor does not vary (a held
#' reference value, or a model with no continuous predictor) the last grouping
#' factor goes on the x-axis. If the metadata has been stripped (e.g. by dplyr
#' post-processing) and `x` cannot be inferred, the function errors and asks for
#' `x`.
#'
#' @param predictions A `kb_predictions` object.
#' @param x A string naming the x-axis column, or `NULL` to infer it from the
#'   metadata.
#' @param observed A data frame of raw observations to overlay as points, or
#'   `NULL` for none.
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
#' # Weight at a reference diameter by site (pointrange, sites on the x-axis):
#' kb_predict_weight_by(
#'   fit_weight_sim_nereo,
#'   by = "site", diameter = 30, new_levels = "average"
#' ) |>
#'   kb_plot_predictions()
kb_plot_predictions <- function(predictions,
                                ...,
                                x = NULL,
                                observed = NULL,
                                max_facets = 12L) {
  rlang::check_dots_empty()
  if (!is.null(observed)) {
    chk::chk_data(observed)
  }
  chk::chk_number(max_facets)
  chk::chk_gt(max_facets, value = 0)
  if (is.finite(max_facets)) {
    chk::chk_whole_number(max_facets)
  }
  if (!is.data.frame(predictions)) {
    cli::cli_abort("{.arg predictions} must be a {.cls kb_predictions} data frame.")
  }
  if (!all(c("estimate", "lower", "upper") %in% names(predictions))) {
    cli::cli_abort("{.arg predictions} must have {.field estimate}, {.field lower}, and {.field upper} columns.")
  }

  predictor <- attr(predictions, "kb_predictor")
  response <- attr(predictions, "kb_response")
  group_vars <- attr(predictions, "kb_group_vars")

  # A ribbon needs an ordered, generated grid over a varying predictor; supplied
  # rows and held/absent predictors render as grouped points instead.
  predictor_varies <- !is.null(predictor) && predictor %in% names(predictions) &&
    length(unique(predictions[[predictor]])) > 1
  inferred <- if (predictor_varies) predictor else group_vars[length(group_vars)]
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
      if (!is.null(observed) && all(facet %in% names(observed))) {
        observed <- observed[do.call(paste, c(observed[facet], sep = "\r")) %in% keep, , drop = FALSE]
      }
    }
  }

  if (is.null(x) || !x %in% names(predictions)) {
    cli::cli_abort(c(
      "Cannot infer the x-axis column from {.arg predictions}.",
      i = "Supply {.arg x}."
    ))
  }
  # Ribbon only for a generated curve over the varying predictor; else pointrange.
  style <- if (isTRUE(attr(predictions, "kb_curve")) &&
    identical(x, predictor) && predictor_varies) {
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
  if (!is.null(observed)) {
    if (is.null(predictor) || is.null(response)) {
      cli::cli_abort("An {.arg observed} overlay needs predictor/response metadata on {.arg predictions}.")
    }
    gg <- gg + ggplot2::geom_point(
      data = observed,
      mapping = ggplot2::aes(x = .data[[predictor]], y = .data[[response]]),
      inherit.aes = FALSE, alpha = 0.3
    )
  }
  x_units <- if (identical(x, predictor)) attr(predictions, "kb_predictor_units") else NA_character_
  gg + ggplot2::labs(
    x = kb_axis_label(x, x_units),
    y = kb_axis_label(response %||% "estimate", attr(predictions, "kb_response_units"))
  )
}

# Publication-ready axis title for a prediction column: a descriptive label for
# the known model variables. Units are appended in parentheses when supplied, but
# the weight model leaves them unset (units are the user's choice), so labels are
# unit-free. Unrecognised columns fall back to their name (sentence-cased).
kb_axis_label <- function(name, units = NA_character_) {
  base <- switch(name,
    diameter = "Sub-bulb diameter",
    weight = "Wet weight",
    site = "Site",
    year = "Year",
    estimate = "Estimate",
    paste0(toupper(substring(name, 1, 1)), substring(name, 2))
  )
  if (!is.na(units) && nzchar(units)) paste0(base, " (", units, ")") else base
}
