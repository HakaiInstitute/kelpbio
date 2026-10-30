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
.obs_family.kb_fit_wetdry <- function(fit, grid) {
  .obs_family_beta_mean(fit, function(data) data$dry_mass_g / data$wet_mass_g)
}

#' @export
.obs_family.kb_fit_carbon <- function(fit, grid) {
  .obs_family_beta_mean(fit, carbon_fraction)
}

#' @export
.obs_family.kb_fit_nitrogen <- function(fit, grid) {
  .obs_family_beta_mean(fit, nitrogen_fraction)
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

# Each survey's CV adds its plant-weight CV to the residual CV. At new data
# without survey biomass, replicates carry the residual alone. With the
# presence part, a survey holds plants with log odds `logit_p`.
#' @export
.obs_family.kb_fit_cover_calibration <- function(fit, grid) {
  cv_residual <- .draw_vec(fit, "cv_residual")
  weight_cv <- survey_weight_cv(grid)
  shape <- function(d) 1 / (cv_residual[d]^2 + weight_cv^2)
  response <- function(data) data$biomass_kg_m2
  if (!.presence_on(fit)) {
    return(list(
      family = "gamma",
      response = response,
      pars = function(mu_d, d) list(shape = shape(d), rate = shape(d) / exp(mu_d))
    ))
  }
  logit_p <- posterior::draws_of(presence_logit(fit, grid))
  dim(logit_p) <- c(nrow(logit_p), nrow(grid))
  list(
    family = "hurdle_gamma",
    response = response,
    pars = function(mu_d, d) {
      list(logit_p = logit_p[d, ], shape = shape(d), rate = shape(d) / exp(mu_d))
    }
  )
}

# Each row's CV of survey biomass from plant weight, from a column of draws or
# from the mean and SD columns of a fitted survey; 0 for a survey with no
# biomass or when `grid` has neither.
survey_weight_cv <- function(grid) {
  if (posterior::is_rvar(grid[["biomass_kg_m2"]])) {
    draws <- posterior::draws_of(grid$biomass_kg_m2)
    dim(draws) <- c(nrow(draws), nrow(grid))
    mean <- colMeans(draws)
    sd <- apply(draws, 2L, stats::sd)
  } else if (all(c("biomass_kg_m2", "biomass_sd_kg_m2") %in% names(grid))) {
    mean <- as.numeric(grid$biomass_kg_m2)
    sd <- as.numeric(grid$biomass_sd_kg_m2)
  } else {
    return(rep(0, nrow(grid)))
  }
  ifelse(mean > 0, sd / mean, 0)
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
    hurdle_gamma = list(
      log_lik = log_lik_hurdle_gamma,
      res = res_hurdle_gamma,
      ran = ran_hurdle_gamma
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
