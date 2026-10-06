# Construct a kb_predictions object: a tibble subclass carrying column-role
# metadata (predictor, grouping variables, response) as attributes, used
# by kb_plot_predictions() for its defaults. `curve` records whether the rows
# form an ordered, generated grid over the predictor (ribbon-eligible) rather
# than scattered supplied rows; it cannot be recovered from the data shape.
# `conf_level` records the level of `lower` and `upper`, so a prediction passed on
# as data (the in situ biomass of a cover biomass fit) carries its own level.
new_kb_predictions <- function(
  x,
  predictor,
  group_vars,
  response,
  curve = FALSE,
  conf_level = NA_real_
) {
  x <- tibble::as_tibble(x)
  structure(
    x,
    class = c("kb_predictions", class(x)),
    kb_predictor = predictor,
    kb_group_vars = group_vars,
    kb_response = response,
    kb_curve = curve,
    kb_conf_level = conf_level
  )
}
