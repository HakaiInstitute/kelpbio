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
#' @param max_facets A whole number capping the facet panels drawn; if the
#'   grouping has more groups, the first `max_facets` are shown with a warning.
#'   Use `Inf` to disable.
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
                                max_facets = 12L,
                                ...) {
  rlang::check_dots_empty()
  if (!is.null(observed)) {
    chk::chk_data(observed)
  }
  chk::chk_number(max_facets)
  chk::chk_gt(max_facets, value = 0)
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
