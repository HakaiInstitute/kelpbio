test_that("kb_fit_weight_macro returns a correctly-structured object", {
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_macro,
    as.integer(site) <= 2 & as.character(year) %in% c("2019", "2020")
  ))
  fit <- kb_fit_weight_macro(
    d,
    chains = 2,
    niters = 100,
    nthin = 1,
    cores = 2,
    progress = "none",
    seed = 1
  )

  expect_s3_class(fit, "kb_fit_weight_macro")
  expect_identical(fit$meta$species, "macrocystis")
  expect_identical(fit$meta$predictor, "fronds")
  expect_named(fit, c("draws", "diagnostics", "data", "meta"))
  expect_true(posterior::is_draws_rvars(fit$draws))
  expect_setequal(
    posterior::variables(fit$draws),
    c(
      "intercept",
      "fronds_slope",
      "shape",
      "sd_site",
      "sd_year",
      "sd_site_year",
      "site_effect",
      "year_effect",
      "site_year_effect"
    )
  )
  expect_equal(niterations(fit), 100L)
})

test_that("prior_only switches the likelihood off in the Stan data", {
  expect_identical(capture_stan_data(weight_macro_fit)$stan_data$prior_only, 0L)
  expect_identical(capture_stan_data(weight_macro_fit, prior_only = TRUE)$stan_data$prior_only, 1L)
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_weight_macro(
    data_weight_sim_macro[0, ],
    prior_only = TRUE,
    chains = 1,
    niters = 100,
    nthin = 1,
    cores = 1,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, "kb_fit_weight")
})

test_that("data and prior errors name kb_fit_weight_macro()", {
  local_fit_stan_stub(weight_macro_fit)
  err <- expect_error(
    kb_fit_weight_macro(data.frame(site = "a", year = "2020"), progress = "none"),
    "weight_kg"
  )
  expect_identical(err$call[[1]], quote(kb_fit_weight_macro))
  err <- expect_error(
    kb_fit_weight_macro(
      data_weight_sim_macro,
      priors = list(nope = kb_prior_normal(0, 1)),
      progress = "none"
    ),
    "Unknown prior"
  )
  expect_identical(err$call[[1]], quote(kb_fit_weight_macro))
})
