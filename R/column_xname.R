# Column-qualified name for chk error messages (bboudata convention).
column_xname <- function(x_name, col) {
  paste0("Column `", col, "` of ", x_name)
}
