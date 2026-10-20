input <- function() calibration_input(cover_calibration_nereo_fit)

test_that("kb_fit_cover_calibration_nereo returns a correctly-structured object", {
  skip_on_cran()
  withr::local_seed(1)
  survey <- subset(data_survey_sim_nereo, as.integer(site) <= 4)
  biomass <- kb_predict_biomass_survey(
    fit_weight_sim_nereo,
    fit_size_sim_nereo,
    survey,
    progress = "none"
  )
  fit <- kb_fit_cover_calibration_nereo(
    biomass,
    chains = 2,
    niters = 100,
    cores = 2,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, c("kb_fit_cover_calibration_nereo", "kb_fit_cover_calibration", "kb_fit"))
  expect_named(fit, c("draws", "diagnostics", "data", "meta"))
  expect_setequal(
    posterior::variables(fit$draws),
    c(
      "cover_slope",
      "biomass_floor",
      "tide_height_slope",
      "sd_residual",
      "cv_residual",
      "sd_site",
      "sd_year",
      "site_effect",
      "year_effect"
    )
  )
  expect_equal(niterations(fit), 100L)
})

test_that("the fit records the species, response, predictor, and no site:year", {
  local_fit_stan_stub(cover_calibration_nereo_fit)
  fit <- kb_fit_cover_calibration_nereo(input(), progress = "none")
  expect_identical(fit$meta$species, "nereocystis")
  expect_identical(fit$meta$response, "biomass_kg_m2")
  # curves run over tide-corrected cover, which the data do not hold
  expect_identical(fit$meta[["predictor"]], "cover")
  expect_identical(fit$meta$predictor_range, c(0, 1))
  expect_false(fit$meta$site_year_on)
  expect_identical(fit$meta$terms$random, c("site_effect", "year_effect"))
})

test_that("the fit stores each survey's biomass as its mean and SD", {
  local_fit_stan_stub(cover_calibration_nereo_fit)
  data <- input()
  fit <- kb_fit_cover_calibration_nereo(data, progress = "none")
  draws <- posterior::draws_of(data$biomass_kg_m2)
  expect_equal(fit$data$biomass_kg_m2, unname(colMeans(draws)))
  expect_equal(fit$data$biomass_sd_kg_m2, unname(apply(draws, 2, stats::sd)))
  expect_false(any(vapply(fit$data, posterior::is_rvar, logical(1))))
})

test_that("surveys without drone cover are not fitted, with a message", {
  local_fit_stan_stub(cover_calibration_nereo_fit)
  data <- input()
  data[1, c("plot_area_m2", "canopy_area_m2", "tide_height_m")] <- NA
  expect_snapshot(fit <- kb_fit_cover_calibration_nereo(data))
  expect_equal(nobs(fit), nrow(data) - 1L)
  expect_no_message(kb_fit_cover_calibration_nereo(data, progress = "none"))
})

test_that("multi-year data fit no site:year effect and raise no site:year message", {
  local_fit_stan_stub(cover_calibration_nereo_fit)
  expect_no_message(kb_fit_cover_calibration_nereo(input()))
})

test_that("invalid data and wrong priors error before sampling", {
  local_fit_stan_stub(cover_calibration_nereo_fit)
  expect_error(kb_fit_cover_calibration_nereo(data.frame(site = "a", year = "2020")), "biomass_kg_m2")
  p <- kb_priors_cover_calibration_nereo()
  p$biomass_floor <- kb_prior_exponential(1)
  expect_error(
    kb_fit_cover_calibration_nereo(input(), priors = p, progress = "none"),
    "wrong family"
  )
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_cover_calibration_nereo(
    input()[0, ],
    prior_only = TRUE,
    chains = 1,
    niters = 100,
    cores = 1,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, "kb_fit_cover_calibration_nereo")
})

test_that("zero-row data error unless prior_only", {
  expect_error(
    kb_fit_cover_calibration_nereo(input()[0, ], progress = "none"),
    "prior_only = TRUE"
  )
})

test_that("data and prior errors name kb_fit_cover_calibration_nereo()", {
  local_fit_stan_stub(cover_calibration_nereo_fit)
  err <- expect_error(kb_fit_cover_calibration_nereo(
    data.frame(site = "a", year = "2020"),
    progress = "none"
  ))
  expect_identical(err$call[[1]], quote(kb_fit_cover_calibration_nereo))
  err <- expect_error(kb_fit_cover_calibration_nereo(
    input(),
    priors = list(nope = kb_prior_normal(0, 1)),
    progress = "none"
  ))
  expect_identical(err$call[[1]], quote(kb_fit_cover_calibration_nereo))
})
