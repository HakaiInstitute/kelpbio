#' Assemble the Stan Data List for the Nereocystis Weight Model
#'
#' Map validated weight data and a resolved prior list to the `data` block of
#' `inst/stan/weight_nereo.stan`. `site` and `year` are encoded as integer factor
#' codes; the raw `diameter_mm` and `weight_kg` vectors are passed through (the Stan
#' model applies the `log(diameter) - log(diameter_ref)` and `log(weight)`
#' transforms). Zero-row data is supported (for prior-only fits): `nObs` is `0`
#' and `nSite` / `nYear` fall back to `1`.
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#' @param diameter_ref A number of the diameter reference, from
#'   `weight_diameter_ref()`.
#' @param density A list from `density_structure()`.
#'
#' @return A named list suitable for `rstan::sampling(stanmodels$weight_nereo, data = .)`.
#' @noRd
assemble_weight_nereo_data <- function(
  data,
  priors,
  diameter_ref,
  density = density_structure(data),
  prior_only = FALSE,
  site_year_on = TRUE,
  floor_on = TRUE
) {
  site <- factor(data$site)
  year <- factor(data$year)
  nObs <- nrow(data)

  list(
    nObs = nObs,
    nSite = max(1L, nlevels(site)),
    nYear = max(1L, nlevels(year)),
    site = as.integer(site),
    year = as.integer(year),
    diameter = as.numeric(data$diameter_mm),
    weight = as.numeric(data$weight_kg),
    diameter_ref = diameter_ref,
    density = standardised_density(
      data,
      density$on,
      density$mean,
      density$sd,
      density$levels
    ),
    prior_intercept_mu = priors$intercept$mean,
    prior_intercept_sd = priors$intercept$sd,
    prior_power_mu = priors$power$mean,
    prior_power_sd = priors$power$sd,
    prior_floor_mu = priors$floor$mean,
    prior_floor_sd = priors$floor$sd,
    prior_density_mu = priors$density$mean,
    prior_density_sd = priors$density$sd,
    prior_sd_site_rate = priors$sd_site$rate,
    prior_sd_year_rate = priors$sd_year$rate,
    prior_sd_site_year_rate = priors$sd_site_year$rate,
    prior_sd_residual_rate = priors$sd_residual$rate,
    prior_only = as.integer(prior_only),
    site_year_on = as.integer(site_year_on),
    density_on = as.integer(density$on),
    floor_on = as.integer(floor_on)
  )
}

# Geometric-mean diameter reference (the value whose log is mean(log(diameter)),
# so log(diameter / diameter_ref) has mean zero). Computed from the data and
# stored in the fit meta, so the Stan fit and the R-side predictions share one
# reference. Falls back to 30 for zero-row (prior-only) data.
weight_diameter_ref <- function(diameter) {
  if (rlang::is_empty(diameter)) {
    return(30)
  }
  exp(mean(log(diameter)))
}
