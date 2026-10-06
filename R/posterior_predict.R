#' Posterior-Predictive Draws
#'
#' Draws from the posterior predictive distribution: replicate responses (weights,
#' plant sizes, transect counts, dry:wet ratios, carbon fractions, or in situ
#' biomass estimates) carrying both parameter uncertainty and observation noise from
#' the model's likelihood. With `new_data = NULL` the replicates are at the
#' observed data, for use with `bayesplot::pp_check()`.
#'
#' @details
#' For supplied `new_data`, conditioning is inferred from the grouping columns
#' present (see [posterior_epred()]).
#'
#' The observation noise follows the fitted likelihood: Normal on log weight
#' (*Nereocystis* weight), Gamma (*Macrocystis* weight), Weibull (*Nereocystis*
#' size), zero-truncated negative binomial (*Macrocystis* size, so every draw is a
#' whole number of at least 1), zero-inflated negative binomial (*Nereocystis*
#' density), negative binomial (*Macrocystis* density), Beta (wet/dry and
#' carbon, so every draw lies between 0 and 1), and lognormal (cover). Density
#' draws are counts on each row's `area_m2`, or on 1 m² when `new_data` has no
#' `area_m2` column. Cover draws are in situ biomass estimates whose log-scale SD
#' is `bScaling` times that implied by the row's `lower` and `upper` (at the
#' fit's `conf_level`), so cover `new_data` must carry those columns.
#'
#' The observation noise is drawn in R, for every `new_data` including `NULL`, so
#' repeated calls return different replicates. Set a seed with `set.seed()` for
#' reproducible draws.
#'
#' @inheritParams params
#' @param object A `kb_fit` object.
#' @param new_data A data frame with the fit's predictor column (and optional
#'   `site`, `year`, and `stipes_m2` columns; for a density fit, an optional
#'   `area_m2` column giving each transect's area, 1 m² when absent;
#'   `canopy_area_m2`, `plot_area_m2`, `tide_height_m`, `lower`, and `upper` for
#'   a cover fit), or
#'   `NULL` to predict at the observed data.
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
  new_levels = c("average", "sample"),
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
  .add_noise(object, lp, res$grid)
}

# Add observation noise to the link-scale mean (D x N), returning response scale.
# `grid` holds the rows predicted at, for a model whose noise depends on them
# (cover biomass, through each row's in situ precision); the others ignore it.
.add_noise <- function(fit, lp, grid) {
  UseMethod(".add_noise")
}

#' @export
.add_noise.default <- function(fit, lp, grid) {
  .abort_no_method(x = fit, call = NULL)
}

#' @export
.add_noise.kb_fit_weight_nereo <- function(fit, lp, grid) {
  sweight <- as.vector(posterior::draws_of(fit$draws$sWeight)) # length D
  # sweight recycles down each column of the D x N matrix, so element (d, n)
  # gets draw d's residual SD.
  noise <- matrix(stats::rnorm(length(lp)), nrow = nrow(lp))
  exp(lp + sweight * noise)
}

#' @export
.add_noise.kb_fit_weight_macro <- function(fit, lp, grid) {
  # weight ~ gamma(bShape, bShape / eWeight); constant Gamma shape matches
  # weight_macro.stan.
  ewt <- exp(lp)
  shape <- as.vector(posterior::draws_of(fit$draws$bShape)) # length D
  shape_mat <- matrix(shape, nrow = nrow(ewt), ncol = ncol(ewt)) # D x N, constant per draw
  rate <- shape_mat / ewt
  draws <- stats::rgamma(
    length(shape_mat),
    shape = as.vector(shape_mat),
    rate = as.vector(rate)
  )
  matrix(draws, nrow = nrow(shape_mat))
}

#' @export
.add_noise.kb_fit_size_nereo <- function(fit, lp, grid) {
  shape <- as.vector(posterior::draws_of(fit$draws$bShape)) # length D
  # shape recycles down each column of the D x N matrix, so element (d, n) gets
  # draw d's shape.
  scale <- weibull_scale(exp(lp), shape)
  draws <- stats::rweibull(
    length(lp),
    shape = rep_len(shape, length(lp)),
    scale = as.vector(scale)
  )
  matrix(draws, nrow = nrow(lp))
}

#' @export
.add_noise.kb_fit_size_macro <- function(fit, lp, grid) {
  theta <- as.vector(posterior::draws_of(fit$draws$bDispersion)) # length D
  draws <- ran_gamma_pois_zt(
    length(lp),
    lambda = exp(as.vector(lp)),
    theta = rep_len(theta, length(lp))
  )
  matrix(draws, nrow = nrow(lp))
}

#' @export
.add_noise.kb_fit_density_nereo <- function(fit, lp, grid) {
  theta <- as.vector(posterior::draws_of(fit$draws$bDispersion)) # length D
  b_zi <- as.vector(posterior::draws_of(fit$draws$bZeroInflation))
  zi <- 1 / (1 + exp(-b_zi))
  # rep_len() follows the column-major order of the D x N matrix, so element
  # (d, n) gets draw d's parameters.
  draws <- extras::ran_gamma_pois_zi(
    length(lp),
    lambda = exp(as.vector(lp)),
    theta = rep_len(theta, length(lp)),
    prob = rep_len(zi, length(lp))
  )
  matrix(draws, nrow = nrow(lp))
}

#' @export
.add_noise.kb_fit_density_macro <- function(fit, lp, grid) {
  theta <- as.vector(posterior::draws_of(fit$draws$bDispersion)) # length D
  draws <- extras::ran_gamma_pois(
    length(lp),
    lambda = exp(as.vector(lp)),
    theta = rep_len(theta, length(lp))
  )
  matrix(draws, nrow = nrow(lp))
}

#' @export
.add_noise.kb_fit_wetdry <- function(fit, lp, grid) {
  .add_noise_beta_mean(fit, lp)
}

#' @export
.add_noise.kb_fit_carbon <- function(fit, lp, grid) {
  .add_noise_beta_mean(fit, lp)
}

# Lognormal around the calibration mean, with each row's log-scale SD from its
# in situ limits scaled by bScaling.
#' @export
.add_noise.kb_fit_cover_biomass <- function(fit, lp, grid) {
  .chk_biomass_limits(grid, x_name = "`new_data`")
  scaling <- as.vector(posterior::draws_of(fit$draws$bScaling)) # length D
  sd_log <- cover_log_sd(grid$lower, grid$upper, fit$meta$conf_level)
  # Element (d, n) gets draw d's scaling times row n's SD.
  sd <- outer(scaling, sd_log)
  noise <- matrix(stats::rnorm(length(lp)), nrow = nrow(lp))
  exp(lp + sd * noise)
}
