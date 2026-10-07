#' Assemble the Stan Data List for the Nereocystis Weight Model
#'
#' Map validated weight data and a resolved prior list to the `data` block of
#' `inst/stan/weight_nereo.stan`. `site` and `year` are encoded as integer factor
#' codes; the raw `diameter_mm` and `weight_kg` vectors are passed through (the Stan
#' model applies the `log(diameter) - log(diameter_ref)` and `log(weight)`
#' transforms). Zero-row data is supported (for prior-only fits): `n_obs` is `0`
#' and `n_site` / `n_year` fall back to `1`.
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
  n_obs <- nrow(data)

  c(
    list(
      n_obs = n_obs,
      n_site = max(1L, nlevels(site)),
      n_year = max(1L, nlevels(year)),
      site = as.integer(site),
      year = as.integer(year),
      diameter_mm = as.numeric(data$diameter_mm),
      weight_kg = as.numeric(data$weight_kg),
      diameter_ref = diameter_ref,
      density = standardised_density(
        data,
        density$on,
        density$mean,
        density$sd,
        density$levels
      ),
      prior_only = as.integer(prior_only),
      site_year_on = as.integer(site_year_on),
      density_on = as.integer(density$on),
      floor_on = as.integer(floor_on)
    ),
    prior_data(priors)
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
