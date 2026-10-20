# The text of a `year` or `survey_id` value: the type of the fits' levels, and
# the one form every check and join compares. Whole numbers are written in
# full, never in scientific notation ("100000", not "1e+05").
id_text <- function(x) {
  if (!is.numeric(x) || inherits(x, "integer64")) {
    return(as.character(x))
  }
  whole <- !is.na(x) & is.finite(x) & x == round(x)
  out <- as.character(x)
  out[whole] <- sprintf("%.0f", x[whole])
  out
}
