# The key of an in situ survey, as one label per row; plant rows join to their
# survey on it.
survey_key <- function(site, plot_id, date) {
  paste(as.character(site), as.character(plot_id), format(date), sep = ":")
}
