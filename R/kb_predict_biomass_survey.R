#' Predict the biomass of in situ surveys
#'
#' Combine a weight fit with the plants counted by each in situ survey into
#' the biomass of the area searched: wet or dry (kg/m² or kg) or carbon
#' (g C/m² or kg C).
#'
#' @details
#' A plant is one individual (sporophyte), identified by its holdfast. Plant
#' sizes come from one of two sources:
#'
#' - A size fit, when plants were tallied and a sample of them measured. A
#'   survey's biomass is its `plants` count times its site-year's mean plant
#'   weight (see [kb_predict_mean_weight()]).
#' - A table of every counted plant, when each was measured. A survey's biomass
#'   is the sum of its plants' expected weights, half for a `partial` plant. A
#'   survey with no plant rows has no biomass, and a message lists such
#'   surveys.
#'
#' Biomass per m² divides by `survey_area_m2`, the area searched. A survey's
#' drone cover is measured over `plot_area_m2`, the plot polygon; for a full
#' census of the plot the two are equal.
#'
#' Dry biomass is wet biomass times the expected dry:wet ratio from `wetdry`,
#' and carbon dry biomass times the expected carbon fraction from `carbon`. The
#' fits must be of the same species and have the same number of draws.
#'
#' @inheritParams derived_params
#' @inheritParams params
#' @param size A `kb_fit_size` object, when plants were tallied, or a data
#'   frame of every counted plant, one row per plant (see
#'   [kb_check_data_plants_nereo()] and [kb_check_data_plants_macro()]).
#' @param survey A data frame of in situ surveys, one row per survey of a plot
#'   (see [kb_check_data_survey()] for the columns).
#' @param measure A string, one of `"wet"`, `"dry"`, or `"carbon"`, giving the
#'   biomass to predict.
#' @param per_area A flag specifying whether to give biomass per m² of the area
#'   searched, or else the biomass in that area.
#' @param n_plants A whole number of sizes averaged per draw to compute the
#'   mean plant weight from a size fit; larger values are more precise and
#'   slower. Not used with a table of counted plants.
#' @param progress_dir A string giving an existing directory in which to record
#'   progress for [kb_progress()], or `NULL` (the default) to record none.
#'
#' @returns A `kb_predictions` object. Without `sum_by`, the rows of `survey`
#'   with added `year` (from `date`), `weight_support`, `size_support` (with a
#'   size fit), the draws of the biomass in a column named for it
#'   (`biomass_kg_m2`, `dry_biomass_kg_m2`, or `carbon_biomass_g_m2` per m², and
#'   `biomass_kg`, `dry_biomass_kg`, or `carbon_biomass_kg` in total), and
#'   `estimate`, `lower`, and `upper`; with `sum_by`, one row per group with its
#'   `sum_by` columns, the draws, and the summary.
#' @family prediction functions
#' @seealso [kb_fit_cover_calibration_nereo()] to calibrate drone cover on the
#'   result.
#' @export
#'
#' @examples
#' # Tallied plants, sizes from a size fit
#' set.seed(1)
#' kb_predict_biomass_survey(
#'   fit_weight_sim_nereo,
#'   fit_size_sim_nereo,
#'   data_survey_sim_nereo
#' )
#'
#' # Every counted plant measured
#' set.seed(1)
#' kb_predict_biomass_survey(
#'   fit_weight_sim_macro,
#'   data_plants_sim_macro,
#'   data_survey_sim_macro,
#'   sum_by = c("site", "year")
#' )
kb_predict_biomass_survey <- function(
  weight,
  size,
  survey,
  wetdry = NULL,
  carbon = NULL,
  ...,
  measure = c("wet", "dry", "carbon"),
  per_area = TRUE,
  sum_by = NULL,
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
  census <- !inherits(size, "kb_fit")
  if (census) {
    if (!missing(n_plants)) {
      cli::cli_abort(c(
        "{.arg n_plants} applies only with a size fit.",
        i = "With a table of counted plants, every plant's own size is used."
      ))
    }
  } else {
    .chk_kb_fit(size, "kb_fit_size")
    .chk_observed_data(
      size,
      hint = "{.arg size} must be fitted to observed plant sizes."
    )
    .chk_representative_site(size, representative_site)
    .chk_n_plants(n_plants)
  }
  .with_call(
    .chk_survey_data(survey, if (census) size, "`survey`", "`size`"),
    rlang::current_env()
  )
  if (census) {
    .chk_census_size(weight, size)
  }
  .chk_measure_fits(measure, wetdry, carbon)
  fits <- list(weight = weight, size = if (!census) size, wetdry = wetdry, carbon = carbon)
  .chk_derived_fits(fits)
  .chk_representative_site(weight, representative_site)
  .chk_summary_args(conf_level, estimate, sig_fig)

  grid <- tibble::as_tibble(survey)
  grid$year <- date_year(grid$date)
  if (!is.null(sum_by)) {
    .chk_sum_by(sum_by, grid, data_name = "survey")
  }
  grid <- dplyr::relocate(grid, "year", .after = "site")
  grid$weight_support <- data_support(weight, grid$site, grid$year)
  if (!census) {
    grid$size_support <- data_support(size, grid$site, grid$year)
  }

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
  carbon_scale <- if (per_area) 1000 else 1
  kg <- kg * measure_factor(measure, wetdry, carbon, carbon_scale = carbon_scale)
  area <- if (per_area) grid$survey_area_m2

  if (is.null(sum_by)) {
    draws <- if (per_area) sweep(kg, 2L, area, "/") else kg
    group_vars <- .group_vars()
  } else {
    summed <- sum_draws_by(grid, kg, sum_by, area = area)
    grid <- summed$groups
    draws <- summed$draws
    group_vars <- sum_by
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
# are resolved per site-year, so the plants of one site-year share them.
census_biomass_draws <- function(
  weight,
  plants,
  grid,
  new_levels,
  representative_site,
  progress
) {
  plants <- tibble::as_tibble(plants)
  plants$year <- date_year(plants$date)
  predictor <- weight$meta$predictor
  warn_outside_range(weight, plants[[predictor]], predictor)

  sy_key <- site_year_key(grid$site, grid$year)
  first <- !duplicated(sy_key)
  effects <- .group_effects(
    weight,
    grid[first, c("site", "year")],
    new_levels,
    representative_site
  )
  plant_sy <- match(site_year_key(plants$site, plants$year), sy_key[first])
  lp <- .linpred(weight, plants, new_levels, effects = effects[plant_sy])
  plant_kg <- posterior::draws_of(.epred(weight, lp))
  if ("partial" %in% names(plants)) {
    plant_kg <- sweep(plant_kg, 2L, ifelse(plants$partial, 0.5, 1), "*")
  }

  survey <- match(
    survey_key(plants$site, plants$plot_id, plants$date),
    survey_key(grid$site, grid$plot_id, grid$date)
  )
  kg <- matrix(0, nrow = nrow(plant_kg), ncol = nrow(grid))
  if (length(survey)) {
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
  surveys <- survey_key(grid$site[empty], grid$plot_id[empty], grid$date[empty])
  cli::cli_inform(c(
    i = "{n} survey{?s} with no plant rows {cli::qty(n)}{?has/have} no biomass.",
    " " = "Survey{?s}: {.val {surveys}}."
  ))
  invisible(empty)
}
