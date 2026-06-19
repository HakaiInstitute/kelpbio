#' Plot Model Predictions
#'
#' Render a `ggplot` from a `kb_predictions` object (the output of a
#' `kb_predict_*()` function). Operates on prediction data frames in a pipe-based
#' workflow; it never takes a fit object. The result is a `ggplot` the user can
#' extend with `+`.
#'
#' `x`, `style`, and `facet` default to `NULL` and are inferred from the
#' prediction's metadata (the predictor column, predictor type, and grouping
#' variables); each remains an overridable argument. If the metadata has been
#' stripped (e.g. by dplyr post-processing) and `x` cannot be inferred, the
#' function errors and asks for `x`.
#'
#' @param predictions A `kb_predictions` object.
#' @param x The predictor column name; `NULL` infers it from the metadata.
#' @param style One of `"ribbon"` (continuous predictor) or `"pointrange"`;
#'   `NULL` infers it from the predictor type.
#' @param facet Grouping variables to facet by; `NULL` infers them from the
#'   metadata.
#' @param observed Optional raw data to overlay as points; `NULL` for none.
#' @param ... Unused.
#'
#' @return A `ggplot` object.
#' @family prediction
#' @export
kb_plot_predictions <- function(predictions,
                                x = NULL,
                                style = NULL,
                                facet = NULL,
                                observed = NULL,
                                ...) {
  rlang::check_dots_empty()
  if (!is.null(observed)) {
    chk::chk_data(observed)
  }
  if (!is.data.frame(predictions)) {
    cli::cli_abort("{.arg predictions} must be a {.cls kb_predictions} data frame.")
  }
  if (!all(c("estimate", "lower", "upper") %in% names(predictions))) {
    cli::cli_abort("{.arg predictions} must have {.field estimate}, {.field lower}, and {.field upper} columns.")
  }

  predictor <- attr(predictions, "kb_predictor")
  response <- attr(predictions, "kb_response")
  x <- x %||% predictor
  facet <- facet %||% attr(predictions, "kb_group_vars")

  if (is.null(x) || !x %in% names(predictions)) {
    cli::cli_abort(c(
      "Cannot infer the predictor column from {.arg predictions}.",
      i = "Supply {.arg x} (and {.arg facet} for grouping)."
    ))
  }
  if (is.null(style)) {
    style <- if (is.numeric(predictions[[x]])) "ribbon" else "pointrange"
  }
  style <- rlang::arg_match(style, c("ribbon", "pointrange"))

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
  gg + ggplot2::labs(x = x, y = response %||% "estimate")
}
