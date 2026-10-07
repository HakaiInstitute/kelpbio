# A grid without the offset column takes one unit (log 0), giving a rate. Add
# it to an rvar over rows, not a D x N matrix, where it would recycle down
# columns (decisions/prediction-engine.md).
grid_offset <- function(fit, grid) {
  col <- fit$meta$offset
  if (is.null(col) || !col %in% names(grid)) {
    return(0)
  }
  log(grid[[col]])
}
