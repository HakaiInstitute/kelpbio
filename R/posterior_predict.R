#' Posterior-Predictive Weight Draws
#'
#' Draws from the posterior predictive distribution: the expected weight plus
#' Student-t observation noise (scale `sWeight`, 4 degrees of freedom, matching
#' the Stan likelihood). With `newdata = NULL` the stored `yrep` (the
#' posterior-predictive replicate at the observed data) is returned, for use
#' with `bayesplot::pp_check()`.
#'
#' @inheritParams params
#' @param object A `kb_fit_weight` object.
#' @param newdata A data frame with a `diameter` column (and the `by` columns),
#'   or `NULL` for the stored `yrep` at the observed data.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @family generics
#' @exportS3Method rstantools::posterior_predict
posterior_predict.kb_fit_weight <- function(object,
                                            newdata = NULL,
                                            by = NULL,
                                            uncertainty = "marginal",
                                            ...) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(object)
  if (is.null(newdata)) {
    if (is.null(object$gq)) {
      cli::cli_abort("No posterior-predictive draws are stored (zero-observation fit).")
    }
    return(posterior::draws_of(object$gq$yrep))
  }
  res <- weight_grid_linpred(object, newdata, by, uncertainty)
  lp <- posterior::draws_of(res$linpred) # D x N
  sweight <- as.vector(posterior::draws_of(object$draws$sWeight)) # length D
  # student_t(nu, mu, sigma) = mu + sigma * t_nu; nu = 4 (fixed in weight.stan).
  noise <- matrix(stats::rt(length(lp), df = 4), nrow = nrow(lp))
  exp(lp + sweight * noise)
}
