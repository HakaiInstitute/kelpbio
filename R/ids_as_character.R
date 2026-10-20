# `data` with a numeric `year` or `survey_id` as character, the type of the
# fits' levels. "%.15g" keeps whole numbers out of scientific notation.
ids_as_character <- function(data) {
  for (col in intersect(c("year", "survey_id"), names(data))) {
    if (is.numeric(data[[col]])) {
      data[[col]] <- sprintf("%.15g", data[[col]])
    }
  }
  data
}
