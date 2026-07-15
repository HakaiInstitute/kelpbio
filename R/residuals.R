#' Deviance Residuals
#'
#' Posterior point estimates of the deviance residual at each observed row, from
#' the Student-t log-weight likelihood, matching [augment()]'s `residual` column.
#'
#' @details
#' The deviance residual is computed per draw, then summarised with the posterior
#' median.
#'
#' @param object A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A numeric vector of deviance residuals, length `nobs(object)`.
#' @family generics
#' @seealso [fitted()] for fitted values, and [augment()].
#' @exportS3Method stats::residuals
#' @examples
#' residuals(fit_weight_sim_nereo)
residuals.kb_fit_weight <- function(object, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(object)
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
