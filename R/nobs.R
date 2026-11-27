#' @exportS3Method stats::nobs
nobs.kb_fit <- function(object, ...) {
  rlang::check_dots_empty()
  nrow(object$data)
}
