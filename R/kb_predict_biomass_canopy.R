#' Predict biomass over mapped canopy
#'
#' Predict the biomass over each row's drone-mapped canopy from a cover
#' calibration fit: wet or dry (kg) or carbon (kg C), optionally pooled over
#' groups of rows.
#'
#' @details
#' A row's total is the expected biomass per m² of bed for its site and year
#' (the calibration at full cover) times its tide-corrected canopy area. The
#' mapped canopy is taken as the extent of the bed, so no biomass is counted
#' outside it. The interval is for the expected total: it carries the
#' uncertainty in the parameters and the site and year effects, not variation
#' between canopy maps.
#'
#' The tide-corrected canopy area is `canopy_area_m2 / (1 - tide_height_slope *
#' canopy_tide_height_m)` (Timmer et al. 2024), capped at `classified_area_m2`; at a
#' tide height at or above `1 / tide_height_slope` it is `classified_area_m2`.
#' A row past that limit on more than 5% of draws warns, since its total is
#' then set by the classified area rather than the canopy mapped. Canopy
#' already corrected for tide is passed with `canopy_tide_height_m = 0`.
#'
#' Dry biomass is the wet total times the expected dry:wet ratio from `wetdry`,
#' and carbon the dry total times the expected carbon fraction from `carbon`.
#' The fits must be of the same species and have the same number of draws.
#'
#' Pool totals with `pool_by` rather than summing per-row estimates or limits.
#' A site-year may have several rows, such as from imagery weeks apart, but pooling
#' two maps of one site-year counts its bed twice, so a group with more than one
#' row per site-year warns.
#'
#' @inheritParams derived_params
#' @inheritParams params
#' @param fit A `kb_fit_cover_calibration` object.
#' @param new_data A data frame of mapped canopy, one row per map of a site's
#'   canopy (summed over the map's polygons), with
#'   `site`, `year`, `canopy_area_m2` (the canopy mapped within the site, m²),
#'   `canopy_tide_height_m` (the tide height when the canopy was imaged, m), and
#'   `classified_area_m2` (the water area within the site that the canopy
#'   classification covered, including water where no canopy was found, m²),
#'   which caps the tide-corrected canopy. Other columns are kept and can be
#'   named in `pool_by`.
#'
#' @returns A `kb_predictions` object. Without `pool_by`, the rows of `new_data`
#'   (a numeric `year` as character) with added `cover_support` (`"site, year"`, `"site"`, `"year"`, or
#'   `"none"`: the data the calibration fit has for the row's site and year), the
#'   draws of the total in a column named for it (`biomass_kg`,
#'   `dry_biomass_kg`, or `carbon_biomass_kg`), and `estimate`,
#'   `lower`, and `upper`; with `pool_by`, one row per group with its `pool_by`
#'   columns, `cover_support` when `pool_by` includes `site` and `year`, the
#'   draws, and the summary.
#' @references Timmer, B., Reshitnyk, L. Y., Hessing-Lewis, M., Juanes, F.,
#'   Gendall, L., and Costa, M. (2024). Capturing accurate kelp canopy extent:
#'   integrating tides, currents, and species-level morphology in kelp remote
#'   sensing. *Frontiers in Environmental Science*, 12, 1338483.
#'   \doi{10.3389/fenvs.2024.1338483}
#' @family prediction functions
#' @seealso [kb_predict_cover_calibration()] for biomass per m² of a plot at a
#'   given cover; at full cover and zero tide height, the biomass per m² of bed.
#' @export
#'
#' @examples
#' fit <- fit_cover_calibration_sim_nereo
#'
#' # One total per row
#' set.seed(1)
#' kb_predict_biomass_canopy(fit, data_canopy_sim_nereo)
#'
#' # Wet totals by region and year
#' set.seed(1)
#' kb_predict_biomass_canopy(
#'   fit,
#'   data_canopy_sim_nereo,
#'   pool_by = c("region", "year")
#' )
#'
#' # Carbon stock by year
#' set.seed(1)
#' kb_predict_biomass_canopy(
#'   fit,
#'   data_canopy_sim_nereo,
#'   fit_wetdry_sim_nereo,
#'   fit_carbon_sim_nereo,
#'   measure = "carbon",
#'   pool_by = "year"
#' )
kb_predict_biomass_canopy <- function(
  fit,
  new_data,
  wetdry = NULL,
  carbon = NULL,
  ...,
  measure = c("wet", "dry", "carbon"),
  pool_by = NULL,
  new_levels = c("sample", "average"),
  representative_site = NULL,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3
) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit, "kb_fit_cover_calibration")
  rlang::check_required(new_data)
  measure <- rlang::arg_match(measure)
  new_levels <- rlang::arg_match(new_levels)
  .with_call(
    {
      .chk_canopy_maps(new_data, x_name = "`new_data`")
      .chk_rows(new_data, "`new_data`")
    },
    rlang::current_env()
  )
  new_data <- ids_as_character(new_data)
  .chk_pool_by(pool_by, new_data)
  pool_by <- unique(pool_by)
  .chk_measure_fits(measure, wetdry, carbon)
  .chk_derived_fits(list(fit = fit, wetdry = wetdry, carbon = carbon))
  .chk_representative_site(fit, representative_site)
  .chk_summary_args(conf_level, estimate, sig_fig)
  warn_implausible_units(new_data, "`new_data`")
  warn_tide_cap(
    tide_cap_share(new_data$canopy_area_m2, new_data$canopy_tide_height_m, fit$draws$tide_height_slope),
    "`new_data`",
    rows = "row",
    cap = "the classified area",
    basis = "on more than 5% of draws"
  )

  grid <- tibble::as_tibble(new_data)
  draws <- canopy_biomass_draws(fit, grid, new_levels, representative_site) *
    measure_factor(measure, wetdry, carbon)

  if (is.null(pool_by)) {
    group_vars <- .group_vars()
  } else {
    pooled <- pool_draws_by(grid, draws, pool_by)
    warn_overlapping_canopy(grid, pooled$id)
    grid <- pooled$groups
    draws <- pooled$draws
    group_vars <- pool_by
  }
  grid <- with_support(grid, fit)
  summarise_draws_rows(
    grid,
    posterior::rvar(draws, nchains = posterior::nchains(fit$draws)),
    group_vars = group_vars,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = FALSE,
    predictor = NULL,
    response = derived_response(measure, per_area = FALSE),
    keep_draws = TRUE
  )
}
