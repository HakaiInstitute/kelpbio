# Per-parameter sampler diagnostics for the effects the fit estimated (see
# .fitted_draws()). Rows are per element (e.g. "bSite[2]"), so they are matched on
# the name before any index.
.fitted_diagnostics <- function(fit) {
  s <- fit$diagnostics$summary
  s[sub("\\[.*$", "", s$variable) %in% .terms(fit, TRUE), , drop = FALSE]
}
