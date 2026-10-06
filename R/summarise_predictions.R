# Shared summariser over a link-scale linpred rvar: put it on the response scale,
# reduce each row to estimate/lower/upper, attach the kb_predictions metadata.
# Used by every prediction verb so the summary is defined once. `response` names
# what the estimate measures; it differs from the fit's response only where the
# grid changes the scale (density per m\u00b2 rather than a transect count).
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

# Reduce a response-scale rvar over grid rows to estimate/lower/upper and attach
# the kb_predictions metadata. Shared by summarise_predictions() and the biomass
# composition, which builds its response-scale draws from several fits.
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
  # estimate reduces each row's posterior draws to a scalar, the same contract as
  # in tidy()/summary(): apply it per row over the draws matrix, not to the rvar.
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
