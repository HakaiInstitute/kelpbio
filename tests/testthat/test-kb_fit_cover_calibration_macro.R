input <- function() calibration_input(cover_calibration_macro_fit)

test_that("the fit records the species, response, predictor, and no site:year", {
  local_fit_stan_stub(cover_calibration_macro_fit)
  fit <- kb_fit_cover_calibration_macro(input(), progress = "none")
  expect_s3_class(fit, c("kb_fit_cover_calibration_macro", "kb_fit_cover_calibration", "kb_fit"))
  expect_identical(fit$meta$species, "macrocystis")
  expect_identical(fit$meta$response, "biomass_kg_m2")
  # curves run over tide-corrected cover, which the data do not hold
  expect_identical(fit$meta[["predictor"]], "cover")
  expect_identical(fit$meta$predictor_range, c(0, 1))
  expect_identical(fit$meta$informative_priors, "tide_height_slope")
  expect_false(fit$meta$site_year_on)
  expect_identical(fit$meta$terms$random, c("site_effect", "year_effect"))
})

test_that("prior_only switches the likelihood off in the Stan data", {
  expect_identical(capture_stan_data(cover_calibration_macro_fit)$stan_data$prior_only, 0L)
  expect_identical(
    capture_stan_data(cover_calibration_macro_fit, prior_only = TRUE)$stan_data$prior_only,
    1L
  )
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_cover_calibration_macro(
    input()[0, ],
    prior_only = TRUE,
    chains = 1,
    niters = 100,
    cores = 1,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, "kb_fit_cover_calibration_macro")
})

test_that("data and prior errors name kb_fit_cover_calibration_macro()", {
  local_fit_stan_stub(cover_calibration_macro_fit)
  err <- expect_error(
    kb_fit_cover_calibration_macro(data.frame(site = "a", year = "2020"), progress = "none"),
    "biomass_kg_m2"
  )
  expect_identical(err$call[[1]], quote(kb_fit_cover_calibration_macro))
  err <- expect_error(
    kb_fit_cover_calibration_macro(
      input(),
      priors = list(nope = kb_prior_normal(0, 1)),
      progress = "none"
    ),
    "Unknown prior"
  )
  expect_identical(err$call[[1]], quote(kb_fit_cover_calibration_macro))
})
