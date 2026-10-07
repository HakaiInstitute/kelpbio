# The observation distribution of a fit at the rows of `grid`, stated once per
# model and evaluated by log_lik(), residuals(), augment(), and
# posterior_predict(). Each method returns a list of
# - `family`: an extras-style distribution name, looked up in .family_fun();
# - `response(data)`: the response in the observed data on its recorded scale,
#   for the likelihood and residuals (replicates at new data have none);
# - `pars(mu_d, d)`: the family's named parameters for draw `d`, given that draw's
#   link-scale mean over the rows.
.obs_family <- function(fit, grid) {
  UseMethod(".obs_family")
}

#' @export
.obs_family.default <- function(fit, grid) {
  .abort_no_method(x = fit, call = NULL)
}

#' @export
.obs_family.kb_fit_weight_nereo <- function(fit, grid) {
  sw <- .draw_vec(fit, "sd_residual")
  list(
    family = "lnorm",
    response = function(data) data$weight_kg,
    pars = function(mu_d, d) list(meanlog = mu_d, sdlog = sw[d])
  )
}

# Constant shape across plants, matching weight_macro.stan.
#' @export
.obs_family.kb_fit_weight_macro <- function(fit, grid) {
  shape <- .draw_vec(fit, "shape")
  list(
    family = "gamma",
    response = function(data) data$weight_kg,
    pars = function(mu_d, d) list(shape = shape[d], rate = shape[d] / exp(mu_d))
  )
}

# The size model is mean-parameterised; weibull_scale() converts the mean.
#' @export
.obs_family.kb_fit_size_nereo <- function(fit, grid) {
  shape <- .draw_vec(fit, "shape")
  list(
    family = "weibull",
    response = function(data) data$diameter_mm,
    pars = function(mu_d, d) {
      list(shape = shape[d], scale = weibull_scale(exp(mu_d), shape[d]))
    }
  )
}

#' @export
.obs_family.kb_fit_size_macro <- function(fit, grid) {
  theta <- .draw_vec(fit, "dispersion")
  list(
    family = "gamma_pois_zt",
    response = function(data) data$fronds,
    pars = function(mu_d, d) list(lambda = exp(mu_d), theta = theta[d])
  )
}

#' @export
.obs_family.kb_fit_density_nereo <- function(fit, grid) {
  theta <- .draw_vec(fit, "dispersion")
  zi <- stats::plogis(.draw_vec(fit, "logit_zero_inflation"))
  list(
    family = "gamma_pois_zi",
    response = function(data) data$stipes,
    pars = function(mu_d, d) {
      list(lambda = exp(mu_d), theta = theta[d], prob = zi[d])
    }
  )
}

#' @export
.obs_family.kb_fit_density_macro <- function(fit, grid) {
  theta <- .draw_vec(fit, "dispersion")
  list(
    family = "gamma_pois",
    response = function(data) data$plants,
    pars = function(mu_d, d) list(lambda = exp(mu_d), theta = theta[d])
  )
}

#' @export
.obs_family.kb_fit_wetdry <- function(fit, grid) {
  .obs_family_beta_mean(fit, function(data) data$dry_mass_g / data$wet_mass_g)
}

#' @export
.obs_family.kb_fit_carbon <- function(fit, grid) {
  .obs_family_beta_mean(fit, carbon_fraction)
}

# Lognormal around the calibration mean, with each row's log-scale SD from its in
# situ limits scaled by error_scaling. The rows' limits are needed for replicates at
# new data too.
#' @export
.obs_family.kb_fit_cover_biomass <- function(fit, grid) {
  .chk_biomass_limits(grid, x_name = "`new_data`")
  scaling <- .draw_vec(fit, "error_scaling")
  sd_log <- cover_log_sd(grid$lower, grid$upper, fit$meta$conf_level)
  list(
    family = "lnorm",
    response = function(data) data$estimate,
    pars = function(mu_d, d) list(meanlog = mu_d, sdlog = scaling[d] * sd_log)
  )
}

# Evaluate the fit's "log_lik", "res", or "ran" function at every draw of the
# link-scale mean `mu` (D x N) over the rows of `grid`, returning D x N. A
# replicate takes the number of rows where the others take the response, so
# `grid` must be the observed data for those.
.eval_family <- function(fit, mu, grid, type) {
  family <- .obs_family(fit, grid)
  fun <- .family_fun(type, family$family)
  first <- if (identical(type, "ran")) ncol(mu) else family$response(grid)
  .per_draw(mu, function(mu_d, d) {
    rlang::exec(fun, first, !!!family$pars(mu_d, d))
  })
}

# The distribution functions in use, by family. Local functions are named and
# parameterised as extras functions would be, so a move to extras changes only
# their entries here.
.family_fun <- function(type, family) {
  funs <- list(
    lnorm = list(
      log_lik = extras::log_lik_lnorm,
      res = extras::res_lnorm,
      ran = extras::ran_lnorm
    ),
    gamma = list(
      log_lik = extras::log_lik_gamma,
      res = extras::res_gamma,
      ran = extras::ran_gamma
    ),
    weibull = list(
      log_lik = log_lik_weibull,
      res = res_weibull,
      ran = ran_weibull
    ),
    gamma_pois = list(
      log_lik = extras::log_lik_gamma_pois,
      res = extras::res_gamma_pois,
      ran = extras::ran_gamma_pois
    ),
    gamma_pois_zi = list(
      log_lik = extras::log_lik_gamma_pois_zi,
      res = extras::res_gamma_pois_zi,
      ran = extras::ran_gamma_pois_zi
    ),
    gamma_pois_zt = list(
      log_lik = log_lik_gamma_pois_zt,
      res = res_gamma_pois_zt,
      ran = ran_gamma_pois_zt
    ),
    beta = list(
      log_lik = extras::log_lik_beta,
      res = res_beta,
      ran = ran_beta
    )
  )
  fun <- funs[[family]][[type]]
  if (is.null(fun)) {
    cli::cli_abort(
      "No {.val {type}} function for the {.val {family}} family.",
      .internal = TRUE
    )
  }
  fun
}

# One parameter's draws as a plain vector of length D.
.draw_vec <- function(fit, name) {
  as.vector(posterior::draws_of(fit$draws[[name]]))
}
