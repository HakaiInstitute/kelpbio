#' Predict the biomass of in situ surveys
#'
#' Combine a weight fit with the plants counted by each in situ survey into
#' the biomass of the surveyed area: wet or dry (kg/m² or kg), or carbon or
#' nitrogen (g/m² or kg).
#'
#' @details
#' A plant is one individual (sporophyte), identified by its holdfast. Plant
#' sizes come from one of two sources:
#'
#' - A size fit, when plants were tallied and a sample of them measured. A
#'   survey's biomass is its `plants` count times its site-year's mean plant
#'   weight (see [kb_predict_mean_weight()]).
#' - A size census of every counted plant, when each was measured, joined to
#'   its survey by `survey_id`. A survey's biomass is the sum of its plants'
#'   expected weights, half for a `partial` plant. A survey with no census rows
#'   has no biomass, and a message lists such surveys.
#'
#' Dry biomass is wet biomass times the expected dry:wet ratio from `wetdry`,
#' and carbon or nitrogen dry biomass times the expected carbon fraction from
#' `carbon` or nitrogen fraction from `nitrogen`. The fits must be of the same
#' species and have the same number of draws.
#'
#' With `pool_by` and `per_area = TRUE`, a group's biomass per m² is its summed
#' biomass over its summed `survey_area_m2`: an area-weighted mean, not the
#' mean of its surveys' values.
#'
#' @inheritParams two_fit_params
#' @inheritParams derived_params
#' @inheritParams params
#' @param size A `kb_fit_size` object, when plants were tallied, or a size
#'   census, a data frame of every counted plant, one row per plant (see
#'   [kb_check_data_size_census_nereo()] and
#'   [kb_check_data_size_census_macro()] for the columns).
#' @param survey A data frame of in situ surveys, one row per survey (see
#'   [kb_check_data_in_situ()] for the columns).
#' @param per_area A flag specifying whether to give biomass per m² of the
#'   surveyed area, or else the biomass in that area.
#' @param n_plants A whole number of sizes averaged per draw to compute the
#'   mean plant weight from a size fit; larger values are more precise and
#'   slower. Not used with a size census.
#'
#' @returns A `kb_predictions` object. Without `pool_by`, the rows of `survey`
#'   (a numeric `year` or `survey_id` as character) with added
#'   `weight_support` and, with a size fit,
#'   `size_support` (as in `kb_predict_mean_weight()`), the draws of the
#'   biomass in a column named for it (`biomass_kg_m2`, `dry_biomass_kg_m2`,
#'   `carbon_biomass_g_m2`, or `nitrogen_biomass_g_m2` per m², and
#'   `biomass_kg`, `dry_biomass_kg`, `carbon_biomass_kg`, or
#'   `nitrogen_biomass_kg` in total), and
#'   `estimate`, `lower`, and `upper`; with `pool_by`, one row per group with its
#'   `pool_by` columns, the support columns when `pool_by` includes `site` and
#'   `year`, the draws, and the summary.
#' @family prediction functions
#' @seealso [kb_fit_cover_calibration_nereo()] to calibrate drone cover on the
#'   result.
#' @export
#'
#' @examples
#' # Tallied plants, sizes from a size fit
#' set.seed(1)
#' kb_predict_biomass_in_situ(
#'   fit_weight_sim_nereo,
#'   fit_size_sim_nereo,
#'   data_in_situ_sim_nereo
#' )
#'
#' # A site the weight fit has no data for, weighed like a fitted site
#' set.seed(1)
#' kb_predict_biomass_in_situ(
#'   fit_weight_sim_nereo,
#'   fit_size_sim_nereo,
#'   subset(data_in_situ_sim_nereo, site == "fog_islet"),
#'   representative_site = list(weight = "otter_cove")
#' )
#'
#' # Every counted plant measured
#' set.seed(1)
#' kb_predict_biomass_in_situ(
#'   fit_weight_sim_macro,
#'   data_size_census_sim_macro,
#'   data_in_situ_sim_macro,
#'   pool_by = c("site", "year")
#' )
kb_predict_biomass_in_situ <- function(
  weight,
  size,
  survey,
  wetdry = NULL,
  carbon = NULL,
  nitrogen = NULL,
  ...,
  measure = c("wet", "dry", "carbon", "nitrogen"),
  per_area = TRUE,
  pool_by = NULL,
  new_levels = c("sample", "average"),
  representative_site = NULL,
  n_plants = 100L,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3,
  progress = c("bar", "none"),
  progress_dir = NULL
) {
  rlang::check_dots_empty()
  measure <- rlang::arg_match(measure)
  new_levels <- rlang::arg_match(new_levels)
  progress <- rlang::arg_match(progress)
  chk::chk_flag(per_area)
  .with_call(.chk_progress_dir(progress_dir), rlang::current_env())
  .chk_kb_fit(weight, "kb_fit_weight")
  .chk_size_input(size, n_plants_given = !missing(n_plants))
  census <- !inherits(size, "kb_fit")
  .chk_representative_site_fits(
    representative_site,
    if (census) "weight" else c("weight", "size")
  )
  if (!census) {
    .chk_kb_fit(size, "kb_fit_size")
    .chk_observed_data(
      size,
      hint = "{.arg size} must be fitted to observed plant sizes."
    )
    .chk_representative_site(size, representative_sites(representative_site)$size)
    .chk_n_plants(n_plants)
  }
  .with_call(
    .chk_survey_data(survey, if (census) size, "`survey`", "`size`"),
    rlang::current_env()
  )
  if (census) {
    .chk_census_size(weight, size)
  }
  .chk_measure_fits(measure, wetdry, carbon, nitrogen)
  fits <- list(
    weight = weight,
    size = if (!census) size,
    wetdry = wetdry,
    carbon = carbon,
    nitrogen = nitrogen
  )
  .chk_derived_fits(fits)
  .chk_representative_site(weight, representative_sites(representative_site)$weight)
  .chk_summary_args(conf_level, estimate, sig_fig)

  grid <- ids_as_character(tibble::as_tibble(survey))
  if (!is.null(pool_by)) {
    .chk_pool_by(pool_by, grid, data_name = "survey")
    pool_by <- unique(pool_by)
  }
  grid <- dplyr::relocate(grid, "year", .after = "site")

  kg <- if (census) {
    census_biomass_draws(weight, size, grid, new_levels, representative_site, progress)
  } else {
    tallied_biomass_draws(
      weight,
      size,
      grid,
      new_levels,
      representative_site,
      n_plants,
      progress,
      progress_dir
    )
  }
  write_prediction_progress(progress_dir, 1L, 1L)
  element_scale <- if (per_area) 1000 else 1
  kg <- kg *
    measure_factor(measure, wetdry, carbon, nitrogen, element_scale = element_scale)
  area <- if (per_area) grid$survey_area_m2

  if (is.null(pool_by)) {
    draws <- if (per_area) sweep(kg, 2L, area, "/") else kg
    group_vars <- .group_vars()
  } else {
    pooled <- pool_draws_by(grid, kg, pool_by, area = area)
    grid <- pooled$groups
    draws <- pooled$draws
    group_vars <- pool_by
  }
  grid <- with_support(grid, weight)
  if (!census) {
    grid <- with_support(grid, size)
  }
  summarise_draws_rows(
    grid,
    posterior::rvar(draws, nchains = posterior::nchains(weight$draws)),
    group_vars = group_vars,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = FALSE,
    predictor = NULL,
    response = derived_response(measure, per_area),
    keep_draws = TRUE
  )
}

# Wet kg per survey (D x N) from tallied plants: the count times the
# site-year's mean plant weight, computed once per site-year.
tallied_biomass_draws <- function(
  weight,
  size,
  grid,
  new_levels,
  representative_site,
  n_plants,
  progress,
  progress_dir
) {
  key <- site_year_key(grid$site, grid$year)
  first <- !duplicated(key)
  site_years <- grid[first, c("site", "year")]
  mean_weight <- mean_weight_draws(
    weight,
    size,
    site_years,
    new_levels,
    representative_site,
    n_plants,
    progress,
    progress_dir
  )
  mean_weight <- mean_weight[, match(key, key[first]), drop = FALSE]
  sweep(mean_weight, 2L, grid$plants, "*")
}

# Wet kg per survey (D x N) from every counted plant's own size. Group effects
# are resolved per site-year, so the plants of one site-year share them; each
# plant takes its survey's site and year.
census_biomass_draws <- function(
  weight,
  size_census,
  grid,
  new_levels,
  representative_site,
  progress
) {
  census <- tibble::as_tibble(size_census)
  predictor <- weight$meta$predictor
  warn_outside_range(weight, census[[predictor]], predictor)

  kg <- matrix(0, nrow = posterior::ndraws(weight$draws), ncol = nrow(grid))
  survey <- match(id_text(census$survey_id), id_text(grid$survey_id))
  census$site <- grid$site[survey]
  census$year <- grid$year[survey]
  if (length(survey)) {
    sy_key <- site_year_key(grid$site, grid$year)
    first <- !duplicated(sy_key)
    effects <- .group_effects(
      weight,
      grid[first, c("site", "year")],
      new_levels,
      representative_sites(representative_site, "weight")$weight
    )
    plant_sy <- match(site_year_key(census$site, census$year), sy_key[first])
    lp <- .linpred(weight, census, new_levels, effects = effects[plant_sy])
    plant_kg <- posterior::draws_of(.epred(weight, lp))
    if ("partial" %in% names(census)) {
      plant_kg <- sweep(plant_kg, 2L, ifelse(census$partial, 0.5, 1), "*")
    }
    kg[, sort(unique(survey))] <- t(rowsum(t(plant_kg), survey))
  }
  notify_empty_surveys(grid, setdiff(seq_len(nrow(grid)), survey), progress)
  kg
}

# Silent when progress = "none".
notify_empty_surveys <- function(grid, empty, progress = "bar") {
  n <- length(empty)
  if (identical(progress, "none") || n == 0L) {
    return(invisible(empty))
  }
  surveys <- id_text(grid$survey_id[empty])
  cli::cli_inform(c(
    i = "{n} survey{?s} with no size census rows {cli::qty(n)}{?has/have} no biomass.",
    " " = "Survey{?s}: {.val {surveys}}."
  ))
  invisible(empty)
}
