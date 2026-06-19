#' Augment Weight Data with Fitted Values
#'
#' Return the input data augmented with fitted values and residuals, evaluated
#' at each observed row using that row's estimated random effects (site
#' intercept, site slope, and site:year) via the shared `.weight_linpred()`
#' engine. Full precision; for residual diagnostics.
#'
#' @inheritParams params
#' @param x A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return The input data with added columns `fitted`, `residual`, `lower`,
#'   `upper`.
#' @family generics
#' @exportS3Method generics::augment
augment.kb_fit_weight <- function(x, conf_level = 0.95, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(x)
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)

  data <- tibble::as_tibble(x$data)
  # The observed data carries site and year columns, so .weight_linpred()
  # conditions on each row's estimated random effects; new_levels is immaterial.
  epred <- exp(.weight_linpred(x, data, new_levels = "average"))
  a <- (1 - conf_level) / 2
  fitted <- as.numeric(stats::median(epred))

  dplyr::mutate(
    data,
    fitted = fitted,
    residual = data$weight - fitted,
    lower = unname(posterior::quantile2(epred, a)),
    upper = unname(posterior::quantile2(epred, 1 - a))
  )
}
