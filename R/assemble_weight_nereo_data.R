#' Assemble the Stan Data List for the Nereocystis Weight Model
#'
#' Map validated weight data and a resolved prior list to the `data` block of
#' `inst/stan/weight_nereo.stan`. `site` and `year` are encoded as integer factor
#' codes; the raw `diameter` and `weight` vectors are passed through (the Stan
#' model applies the `log(diameter) - log(diameter_ref)` and `log(weight)`
#' transforms). `diameter_ref` is the geometric mean of the observed diameter;
#' centering log-diameter on it makes the diameter unit immaterial. Zero-row data
#' is supported (for prior-only fits): `nObs` is `0` and `nSite` / `nYear` fall
#' back to `1`.
#'
#' @inheritParams params
#' @param priors A resolved named prior list (see `resolve_priors()`).
#'
#' @return A named list suitable for `rstan::sampling(stanmodels$weight_nereo, data = .)`.
#' @noRd
assemble_weight_nereo_data <- function(
  data,
  priors,
  prior_only = FALSE,
  site_year_on = TRUE
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
    diameter = as.numeric(data$diameter),
    weight = as.numeric(data$weight),
    diameter_ref = weight_diameter_ref(data$diameter),
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
    prior_only = as.integer(prior_only),
    site_year_on = as.integer(site_year_on)
  )
}

# Geometric-mean centering reference for log-diameter (i.e. the value whose log
# is mean(log(diameter)), so centered log-diameter has mean zero). Computed from
# the data and stored in the fit meta, so the Stan fit and the R-side predictions
# share one reference. Falls back to 30 for zero-row (prior-only) data.
weight_diameter_ref <- function(diameter) {
  if (length(diameter) == 0L) {
    return(30)
  }
  exp(mean(log(diameter)))
}
