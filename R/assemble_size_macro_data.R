#' Assemble the Stan Data List for the Macrocystis Size Model
#'
#' Map validated size data and a resolved prior list to the `data` block of
#' `inst/stan/size_macro.stan`. `site` and `year` are encoded as integer factor
#' codes and `fronds` is passed as an integer count. Zero-row data is supported
#' (for prior-only fits): `nObs` is `0` and `nSite` / `nYear` fall back to `1`.
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#'
#' @return A named list suitable for `rstan::sampling(stanmodels$size_macro, data = .)`.
#' @noRd
assemble_size_macro_data <- function(
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
    fronds = as.integer(data$fronds),
    prior_intercept_mu = priors$intercept$mean,
    prior_intercept_sd = priors$intercept$sd,
    prior_dispersion_rate = priors$dispersion$rate,
    prior_sd_site_rate = priors$sd_site$rate,
    prior_sd_year_rate = priors$sd_year$rate,
    prior_sd_site_year_rate = priors$sd_site_year$rate,
    prior_only = as.integer(prior_only),
    site_year_on = as.integer(site_year_on)
  )
}
