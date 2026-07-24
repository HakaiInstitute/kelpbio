# Construct a kb_predictions object: a tibble subclass carrying column-role
# metadata (predictor, grouping variables, response + units) as attributes, used
# by kb_plot_predictions() for its defaults. `curve` records whether the rows
# form an ordered, generated grid over the predictor (ribbon-eligible) rather
# than scattered supplied rows; it cannot be recovered from the data shape.
new_kb_predictions <- function(
  x,
  predictor,
  group_vars,
  response,
  response_units = NA_character_,
  predictor_units = NA_character_,
  curve = FALSE
) {
  x <- tibble::as_tibble(x)
  structure(
    x,
    class = c("kb_predictions", class(x)),
    kb_predictor = predictor,
    kb_predictor_units = predictor_units,
    kb_group_vars = group_vars,
    kb_response = response,
    kb_response_units = response_units,
    kb_curve = curve
  )
}
