# Construct a kb_predictions object: a tibble subclass carrying column-role
# metadata (predictor, grouping variables, response + units) as attributes, used
# by kb_plot_predictions() for its defaults.
new_kb_predictions <- function(x, predictor, group_vars, response,
                               response_units = NA_character_) {
  x <- tibble::as_tibble(x)
  structure(
    x,
    class = c("kb_predictions", class(x)),
    kb_predictor = predictor,
    kb_group_vars = group_vars,
    kb_response = response,
    kb_response_units = response_units
  )
}

#' @export
print.kb_predictions <- function(x, ...) {
  gv <- attr(x, "kb_group_vars")
  cat(
    "<kb_predictions> predictor: ", attr(x, "kb_predictor"),
    " | response: ", attr(x, "kb_response"),
    if (length(gv)) paste0(" | by: ", paste(gv, collapse = ", ")) else "",
    "\n",
    sep = ""
  )
  print(tibble::as_tibble(x), ...)
  invisible(x)
}
