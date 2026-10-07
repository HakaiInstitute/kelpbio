#' Assemble the Stan Data List for the Cover Biomass Model
#'
#' Map validated cover biomass data and a resolved prior list to the `data` block of
#' `inst/stan/cover_biomass.stan`, shared by both species. `site` and `year` are encoded
#' as integer factor codes. The response is the log of the in situ biomass
#' estimate, with its log-scale SD derived from `lower` and `upper` at
#' `conf_level`. Zero-row data is supported (for prior-only fits): `n_obs` is `0`
#' and `n_site` / `n_year` fall back to `1`.
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

  c(
    list(
      n_obs = nrow(data),
      n_site = max(1L, nlevels(site)),
      n_year = max(1L, nlevels(year)),
      site = as.integer(site),
      year = as.integer(year),
      canopy_area_m2 = as.numeric(data$canopy_area_m2),
      plot_area_m2 = as.numeric(data$plot_area_m2),
      tide_height_m = as.numeric(data$tide_height_m),
      log_biomass = log(as.numeric(data$estimate)),
      log_biomass_sd = cover_log_sd(
        as.numeric(data$lower),
        as.numeric(data$upper),
        conf_level
      ),
      prior_only = as.integer(prior_only)
    ),
    prior_data(priors)
  )
}
