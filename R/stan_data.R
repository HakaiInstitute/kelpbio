# The site and year indices of a grouped model's Stan data, coded by factor()
# level order, the order new_kb_fit() labels the effects with. Zero-row data
# (prior-only fits) take one level of each, so the effect vectors exist.
group_stan_data <- function(data) {
  site <- factor(data$site)
  year <- factor(data$year)
  list(
    n_site = max(1L, nlevels(site)),
    n_year = max(1L, nlevels(year)),
    site = as.integer(site),
    year = as.integer(year)
  )
}

# The geometric mean of a predictor, the reference its log is centred on. It is
# stored in the fit meta so the Stan fit and R-side predictions share it.
# `fallback` is used for zero-row (prior-only) data.
geometric_ref <- function(x, fallback) {
  if (rlang::is_empty(x)) {
    return(fallback)
  }
  exp(mean(log(x)))
}

#' Assemble the Stan Data List for the Carbon Model
#'
#' Map validated carbon data and a resolved prior list to the `data` block of
#' `inst/stan/carbon.stan`, shared by both species. The model takes the carbon
#' fraction of each sample, computed from its carbon and sample masses. Zero-row
#' data is supported (for prior-only fits).
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#'
#' @returns A named list suitable for `rstan::sampling(stanmodels$carbon, data = .)`.
#' @noRd
assemble_carbon_data <- function(data, priors, prior_only = FALSE) {
  c(
    list(
      n_obs = nrow(data),
      carbon_fraction = as.numeric(carbon_fraction(data)),
      prior_only = as.integer(prior_only)
    ),
    prior_data(priors)
  )
}

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

#' Assemble the Stan Data List for the Nitrogen Model
#'
#' Map validated nitrogen data and a resolved prior list to the `data` block of
#' `inst/stan/nitrogen.stan`, shared by both species. The model takes the nitrogen
#' fraction of each sample, computed from its nitrogen and sample masses. Zero-row
#' data is supported (for prior-only fits).
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#'
#' @returns A named list suitable for `rstan::sampling(stanmodels$nitrogen, data = .)`.
#' @noRd
assemble_nitrogen_data <- function(data, priors, prior_only = FALSE) {
  c(
    list(
      n_obs = nrow(data),
      nitrogen_fraction = as.numeric(nitrogen_fraction(data)),
      prior_only = as.integer(prior_only)
    ),
    prior_data(priors)
  )
}

#' Assemble the Stan Data List for the Nereocystis Size Model
#'
#' Map validated size data and a resolved prior list to the `data` block of
#' `inst/stan/size_nereo.stan`. `site` and `year` are encoded as integer factor
#' codes and `diameter_mm` is passed through. Zero-row data is supported (for
#' prior-only fits): `n_obs` is `0` and `n_site` / `n_year` fall back to `1`.
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#'
#' @returns A named list suitable for `rstan::sampling(stanmodels$size_nereo, data = .)`.
#' @noRd
assemble_size_nereo_data <- function(
  data,
  priors,
  prior_only = FALSE
) {
  c(
    group_stan_data(data),
    list(
      n_obs = nrow(data),
      diameter_mm = as.numeric(data$diameter_mm),
      prior_only = as.integer(prior_only)
    ),
    prior_data(priors)
  )
}

#' Assemble the Stan Data List for the Macrocystis Weight Model
#'
#' Map validated weight data and a resolved prior list to the `data` block of
#' `inst/stan/weight_macro.stan`. `site` and `year` are encoded as integer factor
#' codes; the raw `fronds` and `weight_kg` vectors are passed through (the Stan model
#' applies the `log(fronds) - log(fronds_ref)` transform). `fronds_ref` is the
#' geometric mean of the observed frond count. Zero-row data is supported (for
#' prior-only fits): `n_obs` is `0` and `n_site` / `n_year` fall back to `1`.
#'
#' @inheritParams params
#' @param priors A resolved named prior list (see `resolve_priors()`).
#'
#' @returns A named list suitable for `rstan::sampling(stanmodels$weight_macro, data = .)`.
#' @noRd
assemble_weight_macro_data <- function(
  data,
  priors,
  prior_only = FALSE
) {
  c(
    group_stan_data(data),
    list(
      n_obs = nrow(data),
      fronds = as.numeric(data$fronds),
      weight_kg = as.numeric(data$weight_kg),
      # 5 fronds, the Macrocystis median, for zero-row data.
      fronds_ref = geometric_ref(data$fronds, fallback = 5),
      prior_only = as.integer(prior_only)
    ),
    prior_data(priors)
  )
}

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
#'   `geometric_ref()`.
#'
#' @returns A named list suitable for `rstan::sampling(stanmodels$weight_nereo, data = .)`.
#' @noRd
assemble_weight_nereo_data <- function(
  data,
  priors,
  diameter_ref,
  prior_only = FALSE,
  floor_on = TRUE
) {
  c(
    group_stan_data(data),
    list(
      n_obs = nrow(data),
      diameter_mm = as.numeric(data$diameter_mm),
      weight_kg = as.numeric(data$weight_kg),
      diameter_ref = diameter_ref,
      prior_only = as.integer(prior_only),
      floor_on = as.integer(floor_on)
    ),
    prior_data(priors)
  )
}


#' Assemble the Stan Data List for the Wet/Dry Model
#'
#' Map validated wet/dry data and a resolved prior list to the `data` block of
#' `inst/stan/wetdry.stan`, shared by both species. The model takes the dry:wet
#' mass ratio of each sample. Zero-row data is supported (for prior-only fits).
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#'
#' @returns A named list suitable for `rstan::sampling(stanmodels$wetdry, data = .)`.
#' @noRd
assemble_wetdry_data <- function(data, priors, prior_only = FALSE) {
  c(
    list(
      n_obs = nrow(data),
      dry_wet_ratio = as.numeric(data$dry_mass_g / data$wet_mass_g),
      prior_only = as.integer(prior_only)
    ),
    prior_data(priors)
  )
}
