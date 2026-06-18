#' Assemble the Stan Data List for the Weight Model
#'
#' Map validated weight data and a resolved prior list to the `data` block of
#' `inst/stan/weight.stan`. `site` and `year` are encoded as integer factor
#' codes; the raw `diameter` and `weight` vectors are passed through (the Stan
#' model applies the `log(diameter) - log(30)` and `log(weight)` transforms).
#' Zero-row data is supported (for prior-only fits): `nObs` is `0` and `nSite` /
#' `nYear` fall back to `1`.
#'
#' @inheritParams params
#' @param priors A resolved named prior list (see [resolve_priors()]).
#'
#' @return A named list suitable for `rstan::sampling(stanmodels$weight, data = .)`.
#' @noRd
assemble_stan_data <- function(data, priors, prior_only = FALSE) {
  site <- factor(data$site)
  year <- factor(data$year)
  nObs <- nrow(data)

  list(
    nObs = nObs,
    nSite = max(1L, nlevels(site)),
    nYear = max(1L, nlevels(year)),
    site = as.integer(site),
    year = as.integer(year),
    diameter = as.numeric(data$diameter),
    weight = as.numeric(data$weight),
    prior_intercept_mu = priors$intercept$mean,
    prior_intercept_sd = priors$intercept$sd,
    prior_diameter_mu = priors$diameter$mean,
    prior_diameter_sd = priors$diameter$sd,
    prior_diameter2_mu = priors$diameter2$mean,
    prior_diameter2_sd = priors$diameter2$sd,
    prior_sd_site_rate = priors$sd_site$rate,
    prior_sd_site_diameter_rate = priors$sd_site_diameter$rate,
    prior_sd_site_year_rate = priors$sd_site_year$rate,
    prior_sd_residual_rate = priors$sd_residual$rate,
    prior_only = as.integer(prior_only)
  )
}
