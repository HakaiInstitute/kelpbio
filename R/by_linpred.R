# The grid and link-scale linear predictor behind a `_by` prediction verb: resolve
# the grouping axis, build the grid, evaluate the mean on it. Shared by every
# sub-model's `_by` verb; the verb itself checks the fit is one it accepts.
by_linpred <- function(fit, by, new_levels, predictor_values = NULL) {
  .chk_kb_fit(fit)
  new_levels <- rlang::arg_match(new_levels, c("sample", "average"))
  by <- validate_by(fit, by)
  grid <- build_by_grid(fit, by, predictor_values)
  list(
    grid = grid,
    by = by,
    linpred = .linpred(fit, grid, new_levels) + grid_offset(fit, grid)
  )
}
