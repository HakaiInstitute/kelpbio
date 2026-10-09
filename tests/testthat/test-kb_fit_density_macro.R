test_that("kb_fit_density_macro returns a correctly-structured object", {
  skip_on_cran()
  d <- droplevels(subset(
    data_density_sim_macro,
    as.integer(site) <= 2 & year %in% c("2019", "2020")
  ))
  fit <- kb_fit_density_macro(
    d,
    chains = 2,
    niters = 100,
    cores = 2,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, c("kb_fit_density_macro", "kb_fit_density", "kb_fit"))
  expect_named(fit, c("draws", "diagnostics", "data", "meta"))
  expect_setequal(
    posterior::variables(fit$draws),
    c(
      "intercept",
      "dispersion",
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

test_that("the fit records the species, response, area offset, and no predictor", {
  local_fit_stan_stub(density_macro_fit)
  fit <- kb_fit_density_macro(density_macro_fit$data, progress = "none")
  expect_identical(fit$meta$species, "macrocystis")
  expect_identical(fit$meta$response, "plants")
  expect_identical(fit$meta$offset, "area_m2")
  expect_null(fit$meta[["predictor"]])
  expect_true(fit$meta$site_year_on)
  expect_true("sd_site_year" %in% fit$meta$terms$fixed)
})

test_that("single-year data omit the site:year effect with a message", {
  local_fit_stan_stub(density_macro_fit)
  d <- droplevels(subset(density_macro_fit$data, year == "2019"))
  expect_message(fit <- kb_fit_density_macro(d), "site:year effect is omitted")
  expect_false(fit$meta$site_year_on)
  expect_false("sd_site_year" %in% fit$meta$terms$fixed)
  expect_false("site_year_effect" %in% fit$meta$terms$random)
  expect_false(any(c("sd_site_year", "site_year_effect") %in% names(fit$draws)))
})

test_that("invalid data and priors error before sampling", {
  local_fit_stan_stub(density_macro_fit)
  expect_error(kb_fit_density_macro(data.frame(site = "a", year = "2020")))
  p <- kb_priors_density_macro()
  p$sd_site <- kb_prior_normal(0, 1)
  expect_error(
    kb_fit_density_macro(density_macro_fit$data, priors = p, progress = "none"),
    "wrong family"
  )
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_density_macro(
    data_density_sim_macro[0, ],
    prior_only = TRUE,
    chains = 1,
    niters = 100,
    cores = 1,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, "kb_fit_density_macro")
})

test_that("zero-row data error unless prior_only", {
  expect_error(
    kb_fit_density_macro(
      data_density_sim_macro[0, ],
      progress = "none"
    ),
    "prior_only = TRUE"
  )
})

test_that("data and prior errors name kb_fit_density_macro()", {
  local_fit_stan_stub(density_macro_fit)
  err <- expect_error(kb_fit_density_macro(
      data.frame(site = "a", year = "2020"),
      progress = "none"
  ))
  expect_identical(err$call[[1]], quote(kb_fit_density_macro))
  err <- expect_error(kb_fit_density_macro(
    data_density_sim_macro,
    priors = list(nope = kb_prior_normal(0, 1)),
    progress = "none"
  ))
  expect_identical(err$call[[1]], quote(kb_fit_density_macro))
})
