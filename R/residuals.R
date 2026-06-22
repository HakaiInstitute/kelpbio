#' Deviance Residuals
#'
#' Posterior point estimates of the deviance residual at each observed row, from
#' the Student-t log-weight likelihood. Computed with [extras::res_student()]
#' (the definition used in the analysis project), per draw, then summarised with
#' the posterior median. Returned as a numeric vector, one value per row,
#' matching [augment()]'s `residual` column.
#'
#' @param object A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A numeric vector of deviance residuals, length `nobs(object)`.
#' @family generics
#' @seealso [fitted()] for fitted values, and [augment()].
#' @exportS3Method stats::residuals
#' @examples
#' residuals(fit_weight_hakai_nereo)
residuals.kb_fit_weight <- function(object, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(object)
  # Per-draw deviance residual via the Student-t likelihood (extras::res_student,
  # matching the analysis project), summarised with the posterior median.
  mu <- posterior::draws_of(.weight_nereo_linpred_obs(object))
  sw <- as.vector(posterior::draws_of(object$draws$sWeight))
  y <- log(object$data$weight)
  theta <- 1 / object$meta$nu
  res <- vapply(
    seq_len(nrow(mu)),
    function(d) extras::res_student(y, mu[d, ], sd = sw[d], theta = theta),
    numeric(length(y))
  )
  as.numeric(apply(res, 1L, stats::median))
}
