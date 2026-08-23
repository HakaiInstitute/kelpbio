# Shared summariser over a link-scale linpred rvar: put it on the response scale,
# reduce each row to estimate/lower/upper, attach the kb_predictions metadata.
# Used by every prediction verb so the summary is defined once.
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
  epred <- .epred(fit, linpred)
  a <- (1 - conf_level) / 2

  out <- grid
  # estimate reduces each row's posterior draws to a scalar, the same contract as
  # in tidy()/summary(): apply it per row over the draws matrix, not to the rvar.
  out$estimate <- signif(
    apply(posterior::draws_of(epred), 2L, estimate),
    sig_fig
  )
  out$lower <- signif(unname(posterior::quantile2(epred, a)), sig_fig)
  out$upper <- signif(unname(posterior::quantile2(epred, 1 - a)), sig_fig)

  new_kb_predictions(
    out,
    predictor = fit$meta[["predictor"]],
    group_vars = group_vars,
    response = fit$meta$response,
    curve = curve
  )
}
