#' Posterior-Predictive Weight Draws
#'
#' Draws from the posterior predictive distribution: replicate weights carrying
#' both parameter uncertainty and species-appropriate observation noise
#' (Student-t on log weight with scale `sWeight` for *Nereocystis*; Gamma with
#' shape `shape` for *Macrocystis*, matching the Stan likelihood). With
#' `new_data = NULL` the replicates are at the observed data, for use with
#' `bayesplot::pp_check()`.
#'
#' @details
#' For supplied `new_data`, conditioning is inferred from the grouping columns
#' present (see [posterior_epred()]).
#'
#' The observation noise is drawn in R, for every `new_data` including `NULL`, so
#' repeated calls return different replicates. Set a seed with `set.seed()` for
#' reproducible draws.
#'
#' @inheritParams params
#' @param object A `kb_fit` object.
#' @param new_data A data frame with the fit's predictor column (and optional
#'   `site` / `year` columns), or `NULL` to predict at the observed data.
#' @param ... Unused.
#'
#' @return A draws-by-observations (`D x N`) matrix.
#' @family generics
#' @exportS3Method rstantools::posterior_predict
#' @examples
#' set.seed(1)
#' pp <- posterior_predict(fit_weight_sim_nereo)
#' dim(pp)
posterior_predict.kb_fit <- function(
  object,
  new_data = NULL,
  ...,
  new_levels = "sample",
  representative_site = NULL
) {
  rlang::check_dots_empty()
  .chk_kb_fit(object)
  .chk_representative_site(object, representative_site)
  if (is.null(new_data) && nrow(object$data) == 0L) {
    cli::cli_abort(
      "A zero-observation fit has no posterior-predictive draws at the observed data."
    )
  }
  res <- data_linpred(object, new_data, new_levels, representative_site)
  lp <- posterior::draws_of(res$linpred) # D x N, log scale
  .add_noise(object, lp)
}

# Add observation noise to the link-scale mean (D x N), returning response scale.
.add_noise <- function(fit, lp) {
  UseMethod(".add_noise")
}

#' @export
.add_noise.default <- function(fit, lp) {
  .abort_no_method(x = fit, call = NULL)
}

#' @export
.add_noise.kb_fit_weight_nereo <- function(fit, lp) {
  sweight <- as.vector(posterior::draws_of(fit$draws$sWeight)) # length D
  # student_t(nu, mu, sigma) = mu + sigma * t_nu; nu is fixed in weight_nereo.stan
  # and stored in meta so this path cannot drift from the model.
  noise <- matrix(stats::rt(length(lp), df = fit$meta$nu), nrow = nrow(lp))
  exp(lp + sweight * noise)
}

#' @export
.add_noise.kb_fit_weight_macro <- function(fit, lp) {
  # weight ~ gamma(shape, shape / eWeight); constant Gamma shape matches
  # weight_macro.stan.
  ewt <- exp(lp)
  shape <- as.vector(posterior::draws_of(fit$draws$shape)) # length D
  shape_mat <- matrix(shape, nrow = nrow(ewt), ncol = ncol(ewt)) # D x N, constant per draw
  rate <- shape_mat / ewt
  draws <- stats::rgamma(
    length(shape_mat),
    shape = as.vector(shape_mat),
    rate = as.vector(rate)
  )
  matrix(draws, nrow = nrow(shape_mat))
}
