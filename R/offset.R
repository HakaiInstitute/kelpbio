# Log-scale offset on the linear predictor. A rate model carries one (density is
# counts over a surveyed area, so the mean count is area * density).
#
# The offset column is set at fit time (`meta$offset`). A grid without that
# column takes one unit of it (1 m^2 for density), whose log is zero, so the
# draws are a rate.
#
# Added while the linear predictor is still a posterior rvar over grid rows (see
# .linpred_obs() and data_linpred()), so a length-nrow(grid) vector adds
# elementwise.
grid_offset <- function(fit, grid) {
  col <- fit$meta$offset
  if (is.null(col) || !col %in% names(grid)) {
    return(0)
  }
  log(grid[[col]])
}
