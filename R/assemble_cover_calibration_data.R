#' Assemble the Stan Data List for the Cover Calibration Model
#'
#' Map calibration rows (from `survey_calibration_rows()`) and a resolved prior
#' list to the `data` block of `inst/stan/cover_calibration.stan`, shared by
#' both species. `site` and `year` are encoded as integer factor codes. A survey
#' with no biomass is flagged as empty. Zero-row data is supported (for
#' prior-only fits): `n_obs` is `0` and `n_site` / `n_year` fall back to `1`.
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#' @param presence_on Whether to fit the presence part.
#'
#' @returns A named list suitable for `rstan::sampling(stanmodels$cover_calibration, data = .)`.
#' @noRd
assemble_cover_calibration_data <- function(
  data,
  priors,
  prior_only = FALSE,
  presence_on = FALSE
) {
  biomass <- as.numeric(data$biomass_kg_m2)
  c(
    group_stan_data(data),
    list(
      n_obs = nrow(data),
      canopy_area_m2 = as.numeric(data$canopy_area_m2),
      plot_area_m2 = as.numeric(data$plot_area_m2),
      canopy_tide_height_m = as.numeric(data$canopy_tide_height_m),
      biomass = biomass,
      weight_cv = survey_weight_cv(data),
      zero = as.integer(biomass == 0),
      presence_on = as.integer(presence_on),
      prior_only = as.integer(prior_only)
    ),
    prior_data(priors)
  )
}
