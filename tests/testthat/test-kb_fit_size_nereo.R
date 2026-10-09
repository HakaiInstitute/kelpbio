test_that("kb_fit_size_nereo returns a correctly-structured object", {
  skip_on_cran()
  d <- droplevels(subset(
    data_size_sim_nereo,
    as.integer(site) <= 2 & year %in% c("2019", "2020")
  ))
  fit <- kb_fit_size_nereo(
    d,
    chains = 2,
    niters = 100,
    cores = 2,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, c("kb_fit_size_nereo", "kb_fit_size", "kb_fit"))
  expect_named(fit, c("draws", "diagnostics", "data", "meta"))
  expect_setequal(
    posterior::variables(fit$draws),
    c("intercept", "shape", "sd_site", "sd_year", "sd_site_year", "site_effect", "year_effect", "site_year_effect")
  )
  expect_equal(niterations(fit), 100L)
})

test_that("the fit records the species, response, and no predictor", {
  local_fit_stan_stub(size_nereo_fit)
  fit <- kb_fit_size_nereo(size_nereo_fit$data, progress = "none")
  expect_identical(fit$meta$species, "nereocystis")
  expect_identical(fit$meta$response, "diameter_mm")
  expect_null(fit$meta[["predictor"]])
  expect_null(fit$meta$offset)
  expect_true(fit$meta$site_year_on)
  expect_true("sd_site_year" %in% fit$meta$terms$fixed)
})

test_that("single-year data omit the site:year effect with a message", {
  local_fit_stan_stub(size_nereo_fit)
  d <- droplevels(subset(size_nereo_fit$data, year == "2019"))
  expect_message(fit <- kb_fit_size_nereo(d), "site:year effect is omitted")
  expect_false(fit$meta$site_year_on)
  expect_false("sd_site_year" %in% fit$meta$terms$fixed)
  expect_false("site_year_effect" %in% fit$meta$terms$random)
  expect_false(any(c("sd_site_year", "site_year_effect") %in% names(fit$draws)))
})

test_that("invalid data and priors error before sampling", {
  local_fit_stan_stub(size_nereo_fit)
  expect_error(kb_fit_size_nereo(data.frame(site = "a", year = "2020")))
  p <- kb_priors_size_nereo()
  p$sd_site <- kb_prior_normal(0, 1)
  expect_error(
    kb_fit_size_nereo(size_nereo_fit$data, priors = p, progress = "none"),
    "wrong family"
  )
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_size_nereo(
    data_size_sim_nereo[0, ],
    prior_only = TRUE,
    chains = 1,
    niters = 100,
    cores = 1,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, "kb_fit_size_nereo")
})

test_that("zero-row data error unless prior_only", {
  expect_error(
    kb_fit_size_nereo(
      data_size_sim_nereo[0, ],
      progress = "none"
    ),
    "prior_only = TRUE"
  )
})

test_that("data and prior errors name kb_fit_size_nereo()", {
  local_fit_stan_stub(size_nereo_fit)
  err <- expect_error(kb_fit_size_nereo(
      data.frame(site = "a", year = "2020"),
      progress = "none"
  ))
  expect_identical(err$call[[1]], quote(kb_fit_size_nereo))
  err <- expect_error(kb_fit_size_nereo(
    data_size_sim_nereo,
    priors = list(nope = kb_prior_normal(0, 1)),
    progress = "none"
  ))
  expect_identical(err$call[[1]], quote(kb_fit_size_nereo))
})

test_that("a numeric year is fitted as a factor with the same levels", {
  local_fit_stan_stub(size_nereo_fit)
  d <- size_nereo_fit$data
  d$year <- as.numeric(as.character(d$year))
  fit <- kb_fit_size_nereo(d, progress = "none")
  expect_s3_class(fit$data$year, "factor")
  expect_identical(as.character(fit$data$year), as.character(size_nereo_fit$data$year))
  expect_identical(fit$meta$year_levels, size_nereo_fit$meta$year_levels)
  expect_identical(fit$meta$site_year_levels, size_nereo_fit$meta$site_year_levels)
})
