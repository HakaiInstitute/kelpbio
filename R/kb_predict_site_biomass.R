#' Predict site biomass
#'
#' Predict the total biomass of each drone survey of a site from a cover
#' biomass fit: wet or dry (kg) or carbon (kg C), optionally summed over groups
#' of surveys.
#'
#' @details
#' A survey's total is the expected biomass per m² at full cover for its site
#' and year times its tide-corrected canopy area. The mapped canopy is taken as
#' the extent of the bed, so no biomass is counted outside it. The interval is
#' for the expected total: it carries the uncertainty in the parameters and the
#' site and year effects, not survey-to-survey variation. Dry biomass is the
#' wet total times the expected dry:wet ratio from `wetdry`, and carbon the dry
#' total times the expected carbon fraction from `carbon`.
#'
#' With `new_levels = "sample"`, the effect of a new site or year is drawn once
#' and shared by all surveys naming it.
#'
#' Totals are summed within `sum_by` groups on each draw, so do not sum
#' per-survey estimates or limits. Sum at most one survey per site-year; a group
#' with more warns.
#'
#' @inheritParams kb_predict_cover_biomass
#' @inheritParams kb_predict_plot_biomass
#' @inheritParams params
#' @param new_data A data frame with one row per drone survey of a site:
#'   `site`, `year`, `canopy_area_m2` (the canopy mapped within the site, m²),
#'   and `tide_height_m` (tide height at the survey, m), and optionally
#'   `site_area_m2` (the area within the site boundary, m²), which caps the
#'   tide-corrected canopy. Other columns are kept, and can be named in `sum_by`.
#' @param measure A string, one of `"wet"` (kg), `"dry"` (kg), or `"carbon"`
#'   (kg C), giving the biomass to predict.
#' @param sum_by A character vector naming character or factor columns of
#'   `new_data` to sum the survey totals within, `character(0)` to sum all of
#'   them, or `NULL` (the default) for one total per survey.
#' @param new_levels A string, one of `"sample"` (the default) or `"average"`,
#'   giving how a site or year not in the cover fit is treated: `"sample"` draws
#'   a new effect, so the interval includes the variation between sites or
#'   years; `"average"` uses the typical site or year. `"sample"` gives a
#'   different interval on each call; use `set.seed()` to reproduce it.
#'
#' @returns A `kb_predictions` object. Without `sum_by`, the rows of `new_data`
#'   with added `cover_support` (`"site, year"`, `"site"`, `"year"`, or `"none"`:
#'   the data the cover fit has for the survey's site and year), `estimate`,
#'   `lower`, and `upper` columns; with `sum_by`, one row per group with its
#'   `sum_by` columns, `estimate`, `lower`, and `upper`.
#' @family prediction functions
#' @seealso [kb_predict_cover_biomass()] for biomass per m² of a surveyed plot,
#'   and [kb_predict_plot_biomass()] for in situ biomass per m².
#' @export
#'
#' @examples
#' fit <- fit_cover_biomass_sim_nereo
#' surveys <- data.frame(
#'   site = c("otter_cove", "otter_cove", "gull_rock", "new_site"),
#'   year = c("2019", "2020", "2020", "2020"),
#'   canopy_area_m2 = c(1500, 1100, 4800, 900),
#'   tide_height_m = c(1.7, 0.7, 0.5, 0.9),
#'   region = c("north", "north", "south", "south")
#' )
#'
#' # One total per survey:
#' set.seed(1)
#' kb_predict_site_biomass(fit, surveys)
#'
#' # Wet totals by region:
#' set.seed(1)
#' kb_predict_site_biomass(fit, surveys, sum_by = "region")
#'
#' # Carbon stock by year:
#' set.seed(1)
#' kb_predict_site_biomass(
#'   fit,
#'   surveys,
#'   fit_wetdry_sim_nereo,
#'   fit_carbon_sim_nereo,
#'   measure = "carbon",
#'   sum_by = "year"
#' )
kb_predict_site_biomass <- function(
  fit,
  new_data,
  wetdry = NULL,
  carbon = NULL,
  ...,
  measure = c("wet", "dry", "carbon"),
  sum_by = NULL,
  new_levels = c("sample", "average"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit, "kb_fit_cover_biomass")
  rlang::check_required(new_data)
  measure <- rlang::arg_match(measure)
  new_levels <- rlang::arg_match(new_levels)
  .with_call(
    {
      .chk_site_surveys(new_data, x_name = "`new_data`")
      .chk_rows(new_data, "`new_data`")
    },
    rlang::current_env()
  )
  warn_implausible_units(new_data, "`new_data`")
  .chk_sum_by(sum_by, new_data)
  .chk_measure_fits(measure, wetdry, carbon)
  fits <- list(fit = fit, wetdry = wetdry, carbon = carbon)
  fits <- fits[!vapply(fits, is.null, logical(1))]
  .chk_same_species(fits)
  .chk_same_ndraws(fits)
  .chk_representative_site(fit, representative_site)
  .chk_summary_args(conf_level, estimate, sig_fig)

  grid <- tibble::as_tibble(new_data)
  totals <- site_biomass_draws(fit, grid, new_levels, representative_site)
  if (measure %in% c("dry", "carbon")) {
    totals <- totals * population_draws(wetdry)
  }
  if (measure == "carbon") {
    totals <- totals * population_draws(carbon)
  }
  response <- c(
    wet = "biomass_kg",
    dry = "dry_biomass_kg",
    carbon = "carbon_biomass_kg"
  )[[measure]]

  if (is.null(sum_by)) {
    grid$cover_support <- cover_support(fit, grid$site, grid$year)
    group_vars <- .group_vars()
  } else {
    summed <- sum_site_totals(grid, totals, sum_by)
    grid <- summed$groups
    totals <- summed$draws
    group_vars <- sum_by
  }
  summarise_draws_rows(
    grid,
    posterior::rvar(totals),
    group_vars = group_vars,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = FALSE,
    predictor = NULL,
    response = response
  )
}
