test_that(".chk_kb_fit passes a fit through invisibly and errors on a non-fit", {
  expect_invisible(.chk_kb_fit(weight_fit))
  expect_identical(.chk_kb_fit(weight_fit), weight_fit)
  expect_error(.chk_kb_fit(1), "must be a <kb_fit> object")
})

test_that(".chk_kb_fit_weight passes a fit through invisibly and errors on a non-fit", {
  expect_invisible(.chk_kb_fit_weight(weight_fit))
  expect_identical(.chk_kb_fit_weight(weight_fit), weight_fit)
  expect_snapshot(error = TRUE, .chk_kb_fit_weight(1))
})

test_that("the fit checkers attribute the error to the supplied call", {
  caller <- function(x) .chk_kb_fit(x, call = rlang::current_env())
  expect_equal(
    rlang::catch_cnd(caller(1))$call,
    quote(caller(1))
  )
  caller_weight <- function(x) {
    .chk_kb_fit_weight(x, call = rlang::current_env())
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
  expect_invisible(.chk_representative_site(weight_fit, NULL))
  site1 <- weight_fit$meta$site_levels[1]
  expect_identical(.chk_representative_site(weight_fit, site1), site1)
  expect_snapshot(
    error = TRUE,
    .chk_representative_site(weight_fit, "not_a_site")
  )
})

test_that(".chk_observed_data rejects a fit with no rows to predict at", {
  # Without it the failure surfaces as a posterior broadcast error from .linpred().
  fit0 <- weight_fit
  fit0$data <- fit0$data[0, ]
  expect_error(.chk_observed_data(fit0), "no observed data")
  expect_invisible(.chk_observed_data(weight_fit))
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

test_that(".chk_kb_fit_density passes a density fit through and errors otherwise", {
  expect_invisible(.chk_kb_fit_density(density_nereo_fit))
  expect_error(.chk_kb_fit_density(weight_fit), "must be a <kb_fit_density> object")
})

test_that(".chk_kb_fit_grouped errors for a non-fit and a model without groups", {
  expect_invisible(.chk_kb_fit_grouped(size_nereo_fit))
  expect_error(.chk_kb_fit_grouped(1), "must be a <kb_fit> object")
  expect_snapshot(error = TRUE, .chk_kb_fit_grouped(wetdry_nereo_fit))
})

test_that(".chk_grid_predictor accepts the fit's predictor and rejects others", {
  expect_invisible(.chk_grid_predictor(weight_fit, list()))
  expect_invisible(.chk_grid_predictor(weight_fit, list(diameter_mm = 30)))
  expect_invisible(.chk_grid_predictor(weight_macro_fit, list(fronds = 1:3)))
  expect_snapshot(
    error = TRUE,
    .chk_grid_predictor(weight_fit, list(fronds = 3))
  )
  expect_snapshot(
    error = TRUE,
    .chk_grid_predictor(weight_macro_fit, list(diameter_mm = 30))
  )
  expect_snapshot(
    error = TRUE,
    .chk_grid_predictor(weight_fit, list(30))
  )
  expect_snapshot(
    error = TRUE,
    .chk_grid_predictor(size_nereo_fit, list(diameter_mm = 30))
  )
  expect_snapshot(
    error = TRUE,
    .chk_grid_predictor(weight_fit, list(diameter_mm = 30, diameter_mm = 40))
  )
  expect_snapshot(
    error = TRUE,
    .chk_grid_predictor(weight_fit, list(diameter_mm = "a"))
  )
})

test_that(".chk_by_habit redirects a by argument to kb_new_data()", {
  expect_invisible(.chk_by_habit(NULL, verb = "kb_predict_size"))
  expect_invisible(.chk_by_habit(data.frame(site = "a"), verb = "kb_predict_size"))
  expect_snapshot(
    error = TRUE,
    .chk_by_habit(NULL, by = "site", verb = "kb_predict_density")
  )
  expect_snapshot(
    error = TRUE,
    .chk_by_habit(c("site", "year"), verb = "kb_predict_size")
  )
})

test_that(".chk_new_data_density errors name the area column", {
  expect_invisible(.chk_new_data_density(data.frame(area_m2 = 40)))
  expect_invisible(.chk_new_data_density(data.frame(site = "a")))
  expect_snapshot(error = TRUE, .chk_new_data_density(data.frame(area_m2 = -1)))
  expect_error(.chk_new_data_density(1), "must be a data frame")
})

test_that(".chk_kb_fit_wetdry passes a wet/dry fit through and errors otherwise", {
  expect_invisible(.chk_kb_fit_wetdry(wetdry_macro_fit))
  expect_error(.chk_kb_fit_wetdry(weight_fit), "must be a <kb_fit_wetdry> object")
})

test_that(".chk_kb_fit_carbon passes a carbon fit through and errors otherwise", {
  expect_invisible(.chk_kb_fit_carbon(carbon_macro_fit))
  expect_error(.chk_kb_fit_carbon(wetdry_macro_fit), "must be a <kb_fit_carbon> object")
})

test_that(".chk_same_species and .chk_same_ndraws name the fits", {
  expect_invisible(.chk_same_species(list(weight = weight_fit, size = size_nereo_fit)))
  expect_snapshot(
    .chk_same_species(list(weight = weight_fit, size = size_macro_fit)),
    error = TRUE
  )
  expect_invisible(.chk_same_ndraws(list(weight = weight_fit, size = size_nereo_fit)))
  expect_snapshot(
    .chk_same_ndraws(list(weight = weight_fit, size = fit_size_sim_nereo)),
    error = TRUE
  )
})
