# The body shared by the prediction verbs for models with grouping factors:
# resolve the rows, evaluate the mean, summarise each row. The verb checks the fit
# class first. `offset = FALSE` reports a rate model's rate (density per m^2), and
# `response` then names the rate.
predict_rows <- function(
  fit,
  new_data,
  new_levels,
  representative_site,
  conf_level,
  estimate,
  sig_fig,
  offset = TRUE,
  response = fit$meta$response
) {
  .chk_representative_site(fit, representative_site)
  .chk_summary_args(conf_level, estimate, sig_fig)

  res <- data_linpred(fit, new_data, new_levels, representative_site, offset)
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
