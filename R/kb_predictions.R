# Column roles are stored as attributes for kb_plot_predictions(). `curve`
# marks a generated grid over the predictor, which the data shape cannot reveal.
new_kb_predictions <- function(
  x,
  predictor,
  group_vars,
  response,
  curve = FALSE
) {
  x <- tibble::as_tibble(x)
  structure(
    x,
    class = c("kb_predictions", class(x)),
    kb_predictor = predictor,
    kb_group_vars = group_vars,
    kb_response = response,
    kb_curve = curve
  )
}
