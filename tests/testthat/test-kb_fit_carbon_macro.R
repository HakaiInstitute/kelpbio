test_that("the fit records the species, a derived response, and no effects", {
  local_fit_stan_stub(carbon_macro_fit)
  fit <- kb_fit_carbon_macro(carbon_macro_fit$data, progress = "none")
  expect_s3_class(fit, c("kb_fit_carbon_macro", "kb_fit_carbon", "kb_fit"))
  expect_identical(fit$meta$species, "macrocystis")
  expect_identical(fit$meta$response, "carbon_fraction")
  expect_null(fit$meta[["predictor"]])
  expect_identical(fit$meta$terms$fixed, c("intercept", "precision"))
  expect_length(fit$meta$terms$random, 0L)
})

test_that("prior_only switches the likelihood off in the Stan data", {
  expect_identical(capture_stan_data(carbon_macro_fit)$stan_data$prior_only, 0L)
  expect_identical(capture_stan_data(carbon_macro_fit, prior_only = TRUE)$stan_data$prior_only, 1L)
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_carbon_macro(
    data_carbon_sim_macro[0, ],
    prior_only = TRUE,
    chains = 1,
    niters = 100,
    cores = 1,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, "kb_fit_carbon_macro")
})

test_that("data and prior errors name kb_fit_carbon_macro()", {
  local_fit_stan_stub(carbon_macro_fit)
  err <- expect_error(
    kb_fit_carbon_macro(data.frame(site = "a", year = "2020"), progress = "none"),
    "carbon_mass_ug"
  )
  expect_identical(err$call[[1]], quote(kb_fit_carbon_macro))
  err <- expect_error(
    kb_fit_carbon_macro(
      data_carbon_sim_macro,
      priors = list(nope = kb_prior_normal(0, 1)),
      progress = "none"
    ),
    "Unknown prior"
  )
  expect_identical(err$call[[1]], quote(kb_fit_carbon_macro))
})
