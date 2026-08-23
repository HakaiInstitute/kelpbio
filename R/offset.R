# Log-scale offset on the linear predictor. A rate model carries one (density is
# counts over a surveyed area, so the mean count is area * density).
#
# The offset column is set at fit time (`meta$offset`),
#
# Added while the linear predictor is still a posterior rvar over grid rows (see
# .linpred_obs() and data_linpred()), so a length-nrow(grid) vector adds
# elementwise.
grid_offset <- function(fit, grid) {
  col <- fit$meta$offset
  if (is.null(col)) {
    return(0)
  }
  log(grid[[col]])
}

# This sets offset (e.g. 'area') to 1 so that a rate is reported.
add_offset_default <- function(fit, grid) {
  col <- fit$meta$offset
  if (is.null(col)) {
    return(grid)
  }
  grid[[col]] <- 1
  grid
}
