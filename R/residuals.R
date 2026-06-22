#' Deviance Residuals
#'
#' Posterior summary of the deviance residual at each observed row, from the
#' Student-t log-weight likelihood: the point estimate with a compatibility
#' interval, one row per observed row.
#'
#' @details
#' The deviance residual is computed per draw; the `estimate` is its posterior
#' point estimate and `lower`/`upper` its equal-tailed `conf_level` limits.
#'
#' @inheritParams params
#' @param object A `kb_fit_weight` object.
#' @param ... Unused.
#'
#' @return A tibble with one row per observed row and columns `estimate`,
#'   `lower`, and `upper`.
#' @family generics
#' @seealso [fitted()] for fitted values, and [augment()].
#' @exportS3Method stats::residuals
#' @examples
#' residuals(fit_weight_hakai_nereo)
residuals.kb_fit_weight <- function(object, conf_level = 0.95,
                                    estimate = stats::median, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(object)
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)
  chk::chk_function(estimate)
  mu <- posterior::draws_of(.weight_nereo_linpred_obs(object))
  sw <- as.vector(posterior::draws_of(object$draws$sWeight))
  y <- log(object$data$weight)
  theta <- 1 / object$meta$nu
  # vapply yields an nObs x ndraws matrix (obs in rows); rvar() reads draws from
  # the first margin, so transpose to ndraws x nObs.
  res <- vapply(
    seq_len(nrow(mu)),
    function(d) extras::res_student(y, mu[d, ], sd = sw[d], theta = theta),
    numeric(length(y))
  )
  summarise_rvar(posterior::rvar(t(res)), conf_level, estimate)
}
