#' Assemble the Stan Data List for the Cover Biomass Model
#'
#' Map validated cover biomass data and a resolved prior list to the `data` block of
#' `inst/stan/cover_biomass.stan`, shared by both species. `site` and `year` are encoded
#' as integer factor codes. The response is the log of the in situ biomass
#' estimate, with its log-scale SD derived from `lower` and `upper` at
#' `conf_level`. Zero-row data is supported (for prior-only fits): `nObs` is `0`
#' and `nSite` / `nYear` fall back to `1`.
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#' @param conf_level The level of the compatibility limits `lower` and `upper`.
#'
#' @return A named list suitable for `rstan::sampling(stanmodels$cover_biomass, data = .)`.
#' @noRd
assemble_cover_biomass_data <- function(
  data,
  priors,
  conf_level = 0.95,
  prior_only = FALSE
) {
  site <- factor(data$site)
  year <- factor(data$year)

  list(
    nObs = nrow(data),
    nSite = max(1L, nlevels(site)),
    nYear = max(1L, nlevels(year)),
    site = as.integer(site),
    year = as.integer(year),
    canopy = as.numeric(data$canopy_area_m2),
    plot = as.numeric(data$plot_area_m2),
    tide = as.numeric(data$tide_height_m),
    log_biomass = log(as.numeric(data$estimate)),
    log_biomass_sd = cover_log_sd(
      as.numeric(data$lower),
      as.numeric(data$upper),
      conf_level
    ),
    prior_canopy_mu = priors$canopy$mean,
    prior_canopy_sd = priors$canopy$sd,
    prior_floor_mu = priors$floor$mean,
    prior_floor_sd = priors$floor$sd,
    prior_tide_mu = priors$tide$mean,
    prior_tide_sd = priors$tide$sd,
    prior_scaling_mu = priors$scaling$mean,
    prior_scaling_sd = priors$scaling$sd,
    prior_sd_site_rate = priors$sd_site$rate,
    prior_sd_year_rate = priors$sd_year$rate,
    prior_only = as.integer(prior_only)
  )
}
