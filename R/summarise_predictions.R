# `response` differs from the fit's response only for a rate (density per m^2
# rather than a transect count).
summarise_predictions <- function(
  fit,
  grid,
  linpred,
  group_vars,
  conf_level,
  estimate,
  sig_fig,
  curve = FALSE,
  response = fit$meta$response
) {
  summarise_draws_rows(
    grid,
    .epred(fit, linpred),
    group_vars,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = curve,
    predictor = fit$meta[["predictor"]],
    response = response
  )
}

# Takes response-scale draws, so the biomass composition can call it directly.
summarise_draws_rows <- function(
  grid,
  draws,
  group_vars,
  conf_level,
  estimate,
  sig_fig,
  curve,
  predictor,
  response
) {
  a <- (1 - conf_level) / 2

  out <- grid
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
    curve = curve,
    conf_level = conf_level
  )
}
