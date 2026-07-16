#' Posterior-Predictive Weight Draws
#'
#' Draws from the posterior predictive distribution: the expected weight plus
#' Student-t observation noise (scale `sWeight`, 4 degrees of freedom, matching
#' the Stan likelihood). With `new_data = NULL` the stored `yrep` at the observed
#' data is returned, for use with `bayesplot::pp_check()`.
#'
#' @details
#' For supplied `new_data`, conditioning is inferred from the grouping columns
#' present (see [posterior_epred()]).
#'
#' @inheritParams params
#' @param object A `kb_fit_weight` object.
#' @param new_data A data frame with a `diameter` column (and optional `site` /
#'   `year` columns), or `NULL` for the stored `yrep` at the observed data.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @family generics
#' @exportS3Method rstantools::posterior_predict
#' @examples
#' pp <- posterior_predict(fit_weight_sim_nereo)
#' dim(pp)
posterior_predict.kb_fit_weight <- function(object,
                                            new_data = NULL,
                                            ...,
                                            new_levels = "sample",
                                            representative_site = NULL) {
  rlang::check_dots_empty()
  .chk_kb_fit_weight(object)
  .chk_representative_site(object, representative_site)
  if (is.null(new_data)) {
    if (is.null(object$gq)) {
      cli::cli_abort("No posterior-predictive draws are stored (zero-observation fit).")
    }
    return(posterior::draws_of(object$gq$yrep))
  }
  res <- weight_data_linpred(object, new_data, new_levels, representative_site)
  lp <- posterior::draws_of(res$linpred) # D x N
  sweight <- as.vector(posterior::draws_of(object$draws$sWeight)) # length D
  # student_t(nu, mu, sigma) = mu + sigma * t_nu; nu is fixed in weight_nereo.stan
  # and stored in meta so this path cannot drift from the model.
  noise <- matrix(stats::rt(length(lp), df = object$meta$nu), nrow = nrow(lp))
  exp(lp + sweight * noise)
}
