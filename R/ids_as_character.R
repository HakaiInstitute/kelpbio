# `data` with a numeric `year` or `survey_id` as character (see id_text()).
ids_as_character <- function(data) {
  for (col in intersect(c("year", "survey_id"), names(data))) {
    if (is.numeric(data[[col]])) {
      data[[col]] <- id_text(data[[col]])
    }
  }
  data
}
