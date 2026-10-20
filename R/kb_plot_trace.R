#' Trace plot
#'
#' Plot the posterior draws of each term against iteration, one panel per term
#' and one line per chain, to check that the chains have mixed.
#'
#' @details
#' The terms are those [tidy()] reports: the population-level coefficients and
#' the random-effect standard deviations. Chains that have mixed overlap and
#' wander around a common level with no trend; a chain stuck apart from the
#' others, or a slow drift, points to a convergence problem that [kb_converged()]
#' and the `converged` column of [summary()][summary.kb_fit()] also report.
#'
#' @inheritParams params
#' @param ncol A whole number of panel columns.
#'
#' @returns A `ggplot` object. It sets no theme, so it takes the active one
#'   ([ggplot2::theme_get()]); add a theme with `+` to change it.
#' @family diagnostics
#' @export
#' @examples
#' kb_plot_trace(fit_weight_sim_nereo)
kb_plot_trace <- function(fit, ..., ncol = 2L) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
  chk::chk_whole_number(ncol)
  chk::chk_gte(ncol, value = 1)
  terms <- .terms(fit, include_random_effects = FALSE)
  draws <- posterior::as_draws_df(
    posterior::subset_draws(fit$draws, variable = terms)
  )
  trace <- tibble::tibble(
    term = factor(rep(terms, each = nrow(draws)), levels = terms),
    chain = factor(rep(draws$.chain, length(terms))),
    iteration = rep(draws$.iteration, length(terms)),
    value = unlist(lapply(terms, function(term) draws[[term]]), use.names = FALSE)
  )
  ggplot2::ggplot(
    trace,
    ggplot2::aes(
      x = .data$iteration,
      y = .data$value,
      colour = .data$chain
    )
  ) +
    ggplot2::geom_line(linewidth = 0.3, alpha = 0.8) +
    ggplot2::facet_wrap(
      ggplot2::vars(.data$term),
      ncol = ncol,
      scales = "free_y"
    ) +
    ggplot2::labs(x = "Iteration", y = NULL, colour = "Chain")
}
