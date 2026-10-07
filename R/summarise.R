# One row per scalar term (e.g. site_effect[1]).
summarise_draws_terms <- function(
  draws,
  variables,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  a <- (1 - conf_level) / 2
  sub <- posterior::subset_draws(draws, variable = variables)
  posterior::summarise_draws(
    sub,
    estimate = estimate,
    lower = function(x) unname(posterior::quantile2(x, a)),
    upper = function(x) unname(posterior::quantile2(x, 1 - a))
  ) |>
    dplyr::rename(term = "variable") |>
    dplyr::mutate(
      dplyr::across(c("estimate", "lower", "upper"), function(x) {
        signif(x, sig_fig)
      })
    ) |>
    tibble::as_tibble()
}
