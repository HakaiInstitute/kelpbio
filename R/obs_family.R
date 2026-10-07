# The observation distribution at the rows of `grid` (decisions/architecture.md).
# Returns a list of `family` (a .family_fun() name), `response(data)` (the
# recorded response), and `pars(mu_d, d)` (the family's parameters for draw `d`
# given its link-scale mean).
.obs_family <- function(fit, grid) {
  UseMethod(".obs_family")
}

#' @export
.obs_family.default <- function(fit, grid) {
  .abort_no_method(fit, call = NULL)
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

#' @export
.obs_family.kb_fit_weight_macro <- function(fit, grid) {
  shape <- .draw_vec(fit, "shape")
  list(
    family = "gamma",
    response = function(data) data$weight_kg,
    pars = function(mu_d, d) list(shape = shape[d], rate = shape[d] / exp(mu_d))
  )
}

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

# Beta with a logit mean and a precision, for the proportion models.
.obs_family_beta_mean <- function(fit, response) {
  precision <- .draw_vec(fit, "precision")
  list(
    family = "beta",
    response = response,
    pars = function(mu_d, d) {
      m <- stats::plogis(mu_d)
      list(alpha = m * precision[d], beta = (1 - m) * precision[d])
    }
  )
}

# Each row's log-scale SD comes from its in situ limits, so replicates at new
# data need the limits too.
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

# Evaluates the "log_lik", "res", or "ran" function at every draw of `mu`
# (D x N), returning D x N. Except for "ran", `grid` must hold the response.
.eval_family <- function(fit, mu, grid, type) {
  family <- .obs_family(fit, grid)
  fun <- .family_fun(type, family$family)
  first <- if (identical(type, "ran")) ncol(mu) else family$response(grid)
  .per_draw(mu, function(mu_d, d) {
    rlang::exec(fun, first, !!!family$pars(mu_d, d))
  })
}

# Local functions mirror extras, so a move to extras changes only these entries.
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

.draw_vec <- function(fit, name) {
  as.vector(posterior::draws_of(fit$draws[[name]]))
}
