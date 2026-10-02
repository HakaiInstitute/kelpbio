#' Assemble the Stan Data List for the Nereocystis Density Model
#'
#' Map validated density data and a resolved prior list to the `data` block of
#' `inst/stan/density_nereo.stan`. `site` and `year` are encoded as integer factor
#' codes, `stipes` is passed as an integer count, and `area_m2` as the survey area
#' (the model takes its log as the offset). Zero-row data is supported (for
#' prior-only fits): `nObs` is `0` and `nSite` / `nYear` fall back to `1`.
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#'
#' @return A named list suitable for `rstan::sampling(stanmodels$density_nereo, data = .)`.
#' @noRd
assemble_density_nereo_data <- function(
  data,
  priors,
  prior_only = FALSE,
  site_year_on = TRUE
) {
  site <- factor(data$site)
  year <- factor(data$year)

  list(
    nObs = nrow(data),
    nSite = max(1L, nlevels(site)),
    nYear = max(1L, nlevels(year)),
    site = as.integer(site),
    year = as.integer(year),
    stipes = as.integer(data$stipes),
    area = as.numeric(data$area_m2),
    prior_intercept_mu = priors$intercept$mean,
    prior_intercept_sd = priors$intercept$sd,
    prior_zero_inflation_mu = priors$zero_inflation$mean,
    prior_zero_inflation_sd = priors$zero_inflation$sd,
    prior_dispersion_rate = priors$dispersion$rate,
    prior_sd_site_rate = priors$sd_site$rate,
    prior_sd_year_rate = priors$sd_year$rate,
    prior_sd_site_year_rate = priors$sd_site_year$rate,
    prior_only = as.integer(prior_only),
    site_year_on = as.integer(site_year_on)
  )
}
