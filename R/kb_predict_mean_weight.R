#' Predict mean plant weight
#'
#' Combine a weight and a size fit into the expected weight per plant of each
#' site-year: wet or dry (kg) or carbon (g C).
#'
#' @details
#' For each posterior draw, mean plant weight is the expected weight at size
#' averaged over the site-year's size distribution. The size distribution is
#' truncated above at the largest size in the size fit's data; above the
#' largest weighed size, the weight allometry is extrapolated. Dry weight is
#' wet weight times the expected dry:wet ratio from `wetdry`, and carbon dry
#' weight times the expected carbon fraction from `carbon`.
#'
#' `weight_support` and `size_support` show the data each fit has for the
#' site-year, from most to least local: `"site-year"`, `"site, year"` (its site
#' and its year, but not together), `"site"`, `"year"`, or `"none"`.
#'
#' The fits must be of the same species and have the same number of draws.
#'
#' @inheritParams derived_params
#' @inheritParams params
#' @param size A `kb_fit_size` object.
#' @param new_data A data frame of the rows to predict at, with `site` and
#'   `year` columns (either may be absent, as in a grid from [kb_new_data()]),
#'   or `NULL` for the site-years in the size fit's data.
#' @param measure A string, one of `"wet"` (kg), `"dry"` (kg), or `"carbon"`
#'   (g C), giving the weight to predict.
#'
#' @returns A `kb_predictions` object: the rows of `new_data` with added `weight_support` and
#'   `size_support`, the draws of the mean weight in a `weight_kg`,
#'   `dry_weight_kg`, or `carbon_weight_g` column, and `estimate`, `lower`, and
#'   `upper`.
#' @family prediction functions
#' @seealso [kb_predict_biomass_survey()] for the biomass of in situ surveys.
#' @export
#'
#' @examples
#' set.seed(1)
#' kb_predict_mean_weight(fit_weight_sim_nereo, fit_size_sim_nereo)
#'
#' # The typical year at each site
#' kb_predict_mean_weight(
#'   fit_weight_sim_nereo,
#'   fit_size_sim_nereo,
#'   kb_new_data(fit_size_sim_nereo, by = "site"),
#'   new_levels = "average"
#' )
kb_predict_mean_weight <- function(
  weight,
  size,
  new_data = NULL,
  wetdry = NULL,
  carbon = NULL,
  ...,
  measure = c("wet", "dry", "carbon"),
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
  .with_call(.chk_progress_dir(progress_dir), rlang::current_env())
  .chk_kb_fit(weight, "kb_fit_weight")
  .chk_kb_fit(size, "kb_fit_size")
  .chk_observed_data(
    size,
    hint = "{.arg size} must be fitted to observed plant sizes."
  )
  .chk_measure_fits(measure, wetdry, carbon)
  .chk_derived_fits(list(weight = weight, size = size, wetdry = wetdry, carbon = carbon))
  .chk_representative_site(weight, representative_site)
  .chk_representative_site(size, representative_site)
  .chk_n_plants(n_plants)
  .chk_summary_args(conf_level, estimate, sig_fig)

  if (is.null(new_data)) {
    grid <- dplyr::distinct(tibble::as_tibble(size$data), .data$site, .data$year)
    grid$site <- factor(as.character(grid$site), levels = size$meta$site_levels)
    grid$year <- factor(as.character(grid$year), levels = size$meta$year_levels)
    grid <- dplyr::arrange(grid, .data$site, .data$year)
  } else {
    .with_call(
      {
        .chk_new_data(size, new_data)
        .chk_rows(new_data, "`new_data`")
        .chk_new_data_groups(new_data)
      },
      rlang::current_env()
    )
    grid <- tibble::as_tibble(new_data)
  }
  site <- grid[["site"]] %||% rep(NA_character_, nrow(grid))
  year <- grid[["year"]] %||% rep(NA_character_, nrow(grid))
  grid$weight_support <- data_support(weight, site, year)
  grid$size_support <- data_support(size, site, year)

  draws <- mean_weight_draws(
    weight,
    size,
    grid,
    new_levels,
    representative_site,
    n_plants,
    progress,
    progress_dir
  )
  draws <- draws * measure_factor(measure, wetdry, carbon, carbon_scale = 1000)

  summarise_draws_rows(
    grid,
    posterior::rvar(draws, nchains = posterior::nchains(weight$draws)),
    group_vars = intersect(.group_vars(), names(grid)),
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    curve = FALSE,
    predictor = NULL,
    response = c(wet = "weight_kg", dry = "dry_weight_kg", carbon = "carbon_weight_g")[[measure]],
    keep_draws = TRUE
  )
}
