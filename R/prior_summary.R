#' Prior Summary
#'
#' The resolved prior objects used to fit the model.
#'
#' @param object A `kb_fit` object.
#' @param ... Unused.
#'
#' @return The named list of prior objects (see [kb_priors_weight()]).
#' @family generics
#' @exportS3Method rstantools::prior_summary
#' @examples
#' prior_summary(fit_weight)
prior_summary.kb_fit <- function(object, ...) {
  rlang::check_dots_empty()
  object$meta$priors
}
