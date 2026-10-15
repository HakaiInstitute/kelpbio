#' Priors of a fit
#'
#' The priors used to fit the model.
#'
#'
#' @inheritParams params
#' @returns The named list of prior objects (see the model's `kb_priors_*()`
#'   function).
#' @family fit methods
#' @exportS3Method rstantools::prior_summary
#' @examples
#' prior_summary(fit_weight_sim_nereo)
prior_summary.kb_fit <- function(object, ...) {
  rlang::check_dots_empty()
  object$meta$priors
}
