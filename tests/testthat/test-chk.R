test_that(".chk_kb_fit passes a fit through invisibly and errors on a non-fit", {
  expect_invisible(.chk_kb_fit(weight_nereo_fit))
  expect_identical(.chk_kb_fit(weight_nereo_fit), weight_nereo_fit)
  expect_error(.chk_kb_fit(1), "must be a <kb_fit> object")
})

test_that(".chk_kb_fit with class kb_fit_weight passes a fit through invisibly and errors on a non-fit", {
  expect_invisible(.chk_kb_fit(weight_nereo_fit, "kb_fit_weight"))
  expect_identical(.chk_kb_fit(weight_nereo_fit, "kb_fit_weight"), weight_nereo_fit)
  expect_snapshot(error = TRUE, .chk_kb_fit(1, "kb_fit_weight"))
})

test_that("the fit checkers attribute the error to the supplied call", {
  caller <- function(x) .chk_kb_fit(x, call = rlang::current_env())
  expect_equal(
    rlang::catch_cnd(caller(1))$call,
    quote(caller(1))
  )
  caller_weight <- function(x) {
    .chk_kb_fit(x, "kb_fit_weight", call = rlang::current_env())
  }
  expect_equal(
    rlang::catch_cnd(caller_weight(1))$call,
    quote(caller_weight(1))
  )
})

test_that(".chk_new_data_weight_nereo passes valid new_data through invisibly", {
  d <- data.frame(diameter_mm = c(20, 40))
  expect_invisible(.chk_new_data_weight_nereo(d))
  expect_identical(.chk_new_data_weight_nereo(d), d)
})

test_that(".chk_new_data_weight_nereo errors on a non-data-frame or missing diameter", {
  not_df <- 1
  no_diameter <- data.frame(x = 1)
  expect_snapshot(error = TRUE, .chk_new_data_weight_nereo(not_df))
  expect_snapshot(error = TRUE, .chk_new_data_weight_nereo(no_diameter))
})

test_that(".chk_progress passes a valid mode through invisibly and errors otherwise", {
  expect_invisible(.chk_progress("bar"))
  expect_identical(.chk_progress("none"), "none")
  expect_snapshot(error = TRUE, .chk_progress("loud"))
})

test_that(".chk_progress_dir accepts NULL/an existing directory and errors otherwise", {
  d <- withr::local_tempdir()
  expect_invisible(.chk_progress_dir(NULL))
  expect_identical(.chk_progress_dir(d), d)
  missing_dir <- file.path(withr::local_tempdir(), "nope")
  expect_snapshot(error = TRUE, .chk_progress_dir(missing_dir))
  expect_snapshot(error = TRUE, .chk_progress_dir(1))
})

test_that(".chk_sampler_args validates progress, progress_dir, and the numeric args", {
  expect_null(.chk_sampler_args(
    prior_only = FALSE,
    chains = 4L,
    niters = 1000L,
    nthin = 1L,
    cores = NULL,
    seed = NULL,
    progress = "bar",
    progress_dir = NULL
  ))
  expect_error(
    .chk_sampler_args(
      prior_only = FALSE,
      chains = 4L,
      niters = 1000L,
      nthin = 1L,
      cores = NULL,
      seed = NULL,
      progress = "loud",
      progress_dir = NULL
    ),
    "progress"
  )
  expect_error(
    .chk_sampler_args(
      prior_only = FALSE,
      chains = Inf,
      niters = 1000L,
      nthin = 1L,
      cores = NULL,
      seed = NULL,
      progress = "bar",
      progress_dir = NULL
    ),
    "finite"
  )
  expect_error(
    .chk_sampler_args(
      prior_only = FALSE,
      chains = 4L,
      niters = 1000L,
      nthin = 1L,
      cores = NULL,
      seed = 3e9,
      progress = "bar",
      progress_dir = NULL
    ),
    "seed"
  )
  expect_error(.chk_sampler_args(
    prior_only = FALSE,
    chains = 0L,
    niters = 1000L,
    nthin = 1L,
    cores = NULL,
    seed = NULL,
    progress = "bar",
    progress_dir = NULL
  ))
})

test_that(".chk_representative_site passes NULL/known sites and errors on unknown", {
  expect_invisible(.chk_representative_site(weight_nereo_fit, NULL))
  site1 <- weight_nereo_fit$meta$site_levels[1]
  expect_identical(.chk_representative_site(weight_nereo_fit, site1), site1)
  expect_snapshot(
    error = TRUE,
    .chk_representative_site(weight_nereo_fit, "not_a_site")
  )
})

test_that(".chk_observed_data rejects a fit with no rows to predict at", {
  # Otherwise .linpred() fails with a posterior broadcast error.
  fit0 <- weight_nereo_fit
  fit0$data <- fit0$data[0, ]
  expect_error(.chk_observed_data(fit0), "no observed data")
  expect_invisible(.chk_observed_data(weight_nereo_fit))
})

test_that(".chk_fit_rows points zero-row data to prior_only", {
  data <- data.frame(x = 1)
  expect_invisible(.chk_fit_rows(data, prior_only = FALSE))
  expect_invisible(.chk_fit_rows(data[0, , drop = FALSE], prior_only = TRUE))
  expect_snapshot(error = TRUE, .chk_fit_rows(data[0, , drop = FALSE], prior_only = FALSE))
})

test_that(".chk_new_data_weight_nereo errors on a negative density", {
  d <- data.frame(diameter_mm = 30, stipes_m2 = -2)
  expect_snapshot(error = TRUE, .chk_new_data_weight_nereo(d))
})

test_that(".chk_new_data errors name the invalid predictor column", {
  expect_snapshot(error = TRUE, .chk_new_data_weight_nereo(data.frame(diameter_mm = 0)))
  expect_snapshot(error = TRUE, .chk_new_data_weight_nereo(data.frame(diameter_mm = "30")))
  expect_snapshot(error = TRUE, .chk_new_data_weight_nereo(data.frame(diameter_mm = NA_real_)))
  expect_snapshot(error = TRUE, .chk_new_data_weight_macro(data.frame(fronds = 2.5)))
})

test_that(".chk_kb_fit with class kb_fit_density passes a density fit through and errors otherwise", {
  expect_invisible(.chk_kb_fit(density_nereo_fit, "kb_fit_density"))
  expect_error(.chk_kb_fit(weight_nereo_fit, "kb_fit_density"), "must be a <kb_fit_density> object")
})

test_that(".chk_kb_fit_grouped errors for a non-fit and a model without groups", {
  expect_invisible(.chk_kb_fit_grouped(size_nereo_fit))
  expect_error(.chk_kb_fit_grouped(1), "must be a <kb_fit> object")
  expect_snapshot(error = TRUE, .chk_kb_fit_grouped(wetdry_nereo_fit))
})

test_that(".chk_grid_dots accepts the predictor and grouping values and rejects others", {
  expect_invisible(.chk_grid_dots(weight_nereo_fit, list(), NULL))
  expect_invisible(.chk_grid_dots(weight_nereo_fit, list(diameter_mm = 30), NULL))
  expect_invisible(.chk_grid_dots(weight_macro_fit, list(fronds = 1:3), NULL))
  expect_invisible(.chk_grid_dots(weight_nereo_fit, list(year = 2021), "site"))
  expect_invisible(.chk_grid_dots(size_nereo_fit, list(site = "a", year = "2020"), NULL))
  expect_snapshot(
    error = TRUE,
    .chk_grid_dots(weight_nereo_fit, list(fronds = 3), NULL)
  )
  expect_snapshot(
    error = TRUE,
    .chk_grid_dots(weight_nereo_fit, list(30), NULL)
  )
  expect_snapshot(
    error = TRUE,
    .chk_grid_dots(size_nereo_fit, list(diameter_mm = 30), NULL)
  )
  twice <- stats::setNames(list(30, 40), c("diameter_mm", "diameter_mm"))
  expect_snapshot(
    error = TRUE,
    .chk_grid_dots(weight_nereo_fit, twice, NULL)
  )
  expect_snapshot(
    error = TRUE,
    .chk_grid_dots(weight_nereo_fit, list(diameter_mm = "a"), NULL)
  )
  expect_snapshot(
    error = TRUE,
    .chk_grid_dots(weight_nereo_fit, list(year = 2021), "year")
  )
  expect_snapshot(
    error = TRUE,
    .chk_grid_dots(weight_nereo_fit, list(year = TRUE), NULL)
  )
  expect_error(
    .chk_grid_dots(weight_nereo_fit, list(year = NA_character_), NULL),
    "missing"
  )
})
test_that(".chk_new_data_density errors name the area column", {
  expect_invisible(.chk_new_data_density(data.frame(area_m2 = 40)))
  expect_invisible(.chk_new_data_density(data.frame(site = "a")))
  expect_snapshot(error = TRUE, .chk_new_data_density(data.frame(area_m2 = -1)))
  expect_error(.chk_new_data_density(1), "must be a data frame")
})

test_that(".chk_kb_fit with class kb_fit_wetdry passes a wet/dry fit through and errors otherwise", {
  expect_invisible(.chk_kb_fit(wetdry_macro_fit, "kb_fit_wetdry"))
  expect_error(.chk_kb_fit(weight_nereo_fit, "kb_fit_wetdry"), "must be a <kb_fit_wetdry> object")
})

test_that(".chk_kb_fit with class kb_fit_carbon passes a carbon fit through and errors otherwise", {
  expect_invisible(.chk_kb_fit(carbon_macro_fit, "kb_fit_carbon"))
  expect_error(.chk_kb_fit(wetdry_macro_fit, "kb_fit_carbon"), "must be a <kb_fit_carbon> object")
})

test_that(".chk_same_species and .chk_same_ndraws name the fits", {
  expect_invisible(.chk_same_species(list(weight = weight_nereo_fit, size = size_nereo_fit)))
  expect_snapshot(
    .chk_same_species(list(weight = weight_nereo_fit, size = size_macro_fit)),
    error = TRUE
  )
  expect_invisible(.chk_same_ndraws(list(weight = weight_nereo_fit, size = size_nereo_fit)))
  expect_snapshot(
    .chk_same_ndraws(list(weight = weight_nereo_fit, size = fit_size_sim_nereo)),
    error = TRUE
  )
})


test_that(".chk_kb_fit with class kb_fit_cover_biomass passes a cover biomass fit through and errors otherwise", {
  expect_invisible(.chk_kb_fit(cover_biomass_macro_fit, "kb_fit_cover_biomass"))
  expect_error(.chk_kb_fit(carbon_macro_fit, "kb_fit_cover_biomass"), "must be a <kb_fit_cover_biomass> object")
})

test_that(".chk_cover_survey errors name the survey column", {
  good <- data.frame(canopy_area_m2 = 40, plot_area_m2 = 200, tide_height_m = 0.5)
  expect_invisible(.chk_cover_survey(good))
  expect_snapshot(error = TRUE, .chk_cover_survey(good[c("canopy_area_m2", "plot_area_m2")]))
  bad <- good
  bad$canopy_area_m2 <- 300
  expect_snapshot(error = TRUE, .chk_cover_survey(bad))
  bad <- good
  bad$tide_height_m <- "low"
  expect_error(.chk_cover_survey(bad), "tide_height_m")
  expect_error(.chk_cover_survey(1), "must be a data frame")
})

test_that(".chk_biomass_limits and .chk_biomass_estimate name the offending limit", {
  good <- data.frame(estimate = 2, lower = 1, upper = 4)
  expect_invisible(.chk_biomass_limits(good))
  expect_invisible(.chk_biomass_estimate(good))
  expect_snapshot(error = TRUE, .chk_biomass_limits(good["estimate"]))
  expect_error(.chk_biomass_limits(transform(good, lower = 0)), "lower")
  expect_error(.chk_biomass_limits(transform(good, upper = 1)), "less than")
  expect_error(.chk_biomass_estimate(transform(good, estimate = 0.5)), "estimate")
  expect_error(.chk_biomass_estimate(transform(good, estimate = 5)), "upper")
})

test_that(".chk_biomass_response names the recorded response", {
  good <- data.frame(site = "a", year = "2020", estimate = 2, lower = 1, upper = 4)
  expect_invisible(.chk_biomass_response(good))
  carbon <- new_kb_predictions(good, NULL, c("site", "year"), "carbon_biomass_g_m2")
  expect_snapshot(error = TRUE, .chk_biomass_response(carbon))
})

test_that(".chk_site_surveys errors name the survey column", {
  good <- data.frame(site = "a", year = "2020", canopy_area_m2 = 100, tide_height_m = 0.5)
  expect_invisible(.chk_site_surveys(good))
  expect_snapshot(error = TRUE, .chk_site_surveys(good[c("site", "year", "canopy_area_m2")]))
  expect_snapshot(error = TRUE, .chk_site_surveys(transform(good, site_area_m2 = 50)))
  expect_error(.chk_site_surveys(transform(good, site_area_m2 = 0)), "site_area_m2")
  expect_error(.chk_site_surveys(transform(good, year = NA)), "year")
  expect_error(.chk_site_surveys(1), "must be a data frame")
})

test_that(".chk_sum_by names a missing or non-grouping column", {
  data <- data.frame(region = "north", zone = 1)
  expect_invisible(.chk_sum_by("region", data))
  expect_snapshot(error = TRUE, .chk_sum_by("zone", data))
  expect_snapshot(error = TRUE, .chk_sum_by(c("region", "district"), data))
  expect_error(.chk_sum_by(1, data), "character")
})

test_that(".chk_measure_fits requires the fits a measure needs", {
  expect_invisible(.chk_measure_fits("wet", NULL, NULL))
  expect_error(.chk_measure_fits("dry", NULL, NULL), "wetdry")
  expect_error(.chk_measure_fits("carbon", wetdry_nereo_fit, NULL), "carbon")
  expect_error(.chk_measure_fits("dry", carbon_nereo_fit, NULL), "kb_fit_wetdry")
})

test_that(".chk_sampling_dots rejects sampler arguments kelpbio sets, naming the replacement", {
  expect_invisible(.chk_sampling_dots(list(control = list(), init = 0)))
  expect_snapshot(error = TRUE, .chk_sampling_dots(list(iter = 10, thin = 2)))
  expect_snapshot(error = TRUE, .chk_sampling_dots(list(pars = "intercept")))
})

test_that(".chk_predictions names the missing structure", {
  ok <- data.frame(estimate = 1, lower = 0.5, upper = 2)
  expect_invisible(.chk_predictions(ok))
  expect_error(.chk_predictions(list()), "data frame")
  expect_error(.chk_predictions(ok["estimate"]), "columns")
})

test_that(".chk_plot_x asks for x when it cannot be inferred", {
  p <- data.frame(diameter_mm = 1, estimate = 1)
  expect_invisible(.chk_plot_x("diameter_mm", p, supplied = TRUE))
  expect_error(.chk_plot_x(NULL, p, supplied = FALSE), "Supply")
  expect_error(.chk_plot_x("site", p, supplied = TRUE), "must name a column")
})

test_that(".chk_log_axis gives a message per failing axis", {
  p <- data.frame(
    cover = c(0, 1),
    site = c("a", "b"),
    estimate = c(1, 2),
    lower = c(0.5, 1),
    upper = c(2, 3)
  )
  expect_invisible(.chk_log_axis("y", p, "cover"))
  expect_error(.chk_log_axis("xy", p, "cover"), "positive cover")
  expect_error(.chk_log_axis("xy", p, "site"), "numeric x-axis")
  p$upper[1] <- -1
  expect_error(.chk_log_axis("y", p, "cover"), "log y-axis")
})

test_that(".chk_finite, .chk_rows, and .chk_new_data_groups name the problem", {
  expect_invisible(.chk_finite(c(1, NA)))
  expect_invisible(.chk_rows(data.frame(x = 1)))
  expect_invisible(.chk_new_data_groups(data.frame(site = "a", year = 2020)))
  expect_snapshot(error = TRUE, .chk_finite(c(1, Inf), "`x`"))
  expect_snapshot(error = TRUE, .chk_rows(data.frame(x = numeric(0)), "`new_data`"))
  expect_snapshot(error = TRUE, .chk_new_data_groups(data.frame(site = c("a", NA))))
})

test_that("measure checks reject infinite values", {
  expect_error(.chk_positive_measure(c(1, Inf), "`x`"), "finite")
  expect_error(.chk_density(c(1, Inf), "`x`"), "finite")
  expect_error(
    .chk_measure_columns(data.frame(weight_kg = Inf), "weight_kg", "`data`"),
    "finite"
  )
})
