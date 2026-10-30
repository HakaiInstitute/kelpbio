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

summarise_predictions <- function(
  fit,
  grid,
  linpred,
  group_vars,
  conf_level,
  estimate,
  sig_fig,
  curve = FALSE
) {
  summarise_draws_rows(
    grid,
    .epred(fit, linpred, grid = grid),
    group_vars,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = curve,
    predictor = fit$meta[["predictor"]],
    response = fit$meta$response
  )
}

# Takes response-scale draws, so the derived verbs can call it directly. With
# `keep_draws`, the draws travel as an rvar column named for the response, so
# one derived verb's output can feed another.
summarise_draws_rows <- function(
  grid,
  draws,
  group_vars,
  conf_level,
  estimate,
  sig_fig,
  curve,
  predictor,
  response,
  keep_draws = FALSE
) {
  a <- (1 - conf_level) / 2

  out <- grid
  if (keep_draws) {
    out[[response]] <- draws
  }
  # As in tidy(), `estimate` takes a draws vector, so apply it per column.
  out$estimate <- signif(
    apply(posterior::draws_of(draws), 2L, estimate),
    sig_fig
  )
  out$lower <- signif(unname(posterior::quantile2(draws, a)), sig_fig)
  out$upper <- signif(unname(posterior::quantile2(draws, 1 - a)), sig_fig)

  new_kb_predictions(
    out,
    predictor = predictor,
    group_vars = group_vars,
    response = response,
    curve = curve
  )
}
