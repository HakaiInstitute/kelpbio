# Shared body of the grouped prediction verbs, which check the fit class first.
# `offset = FALSE` reports a rate, and `response` then names it.
predict_rows <- function(
  fit,
  new_data,
  new_levels,
  representative_site,
  conf_level,
  estimate,
  sig_fig,
  offset = TRUE,
  response = fit$meta$response,
  call = rlang::caller_env()
) {
  .chk_representative_site(fit, representative_site, call = call)
  .chk_summary_args(conf_level, estimate, sig_fig, call = call)

  res <- data_linpred(
    fit,
    new_data,
    new_levels,
    representative_site,
    offset,
    call = call
  )
  summarise_predictions(
    fit,
    res$grid,
    res$linpred,
    res$group_vars,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = res$curve,
    response = response
  )
}
