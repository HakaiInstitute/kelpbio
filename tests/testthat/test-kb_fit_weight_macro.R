test_that("kb_fit_weight_macro does not expose site_year_on", {
  expect_false("site_year_on" %in% names(formals(kb_fit_weight_macro)))
})

test_that("kb_fit_weight_macro returns a correctly-structured object", {
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_macro,
    as.integer(site) <= 2 & year %in% c("2019", "2020")
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

test_that("prior_only fit ignores the data", {
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_macro,
    as.integer(site) <= 2 & year %in% c("2019", "2020")
  ))
  f1 <- kb_fit_weight_macro(
    d,
    prior_only = TRUE,
    chains = 1,
    niters = 300,
    nthin = 1,
    cores = 1,
    progress = "none",
    seed = 7
  )
  d2 <- d
  d2$weight_kg <- rev(d2$weight_kg)
  f2 <- kb_fit_weight_macro(
    d2,
    prior_only = TRUE,
    chains = 1,
    niters = 300,
    nthin = 1,
    cores = 1,
    progress = "none",
    seed = 7
  )
  expect_equal(
    as.matrix(posterior::as_draws_matrix(f1$draws)),
    as.matrix(posterior::as_draws_matrix(f2$draws))
  )
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

test_that("zero-row data error unless prior_only", {
  expect_error(
    kb_fit_weight_macro(
      data_weight_sim_macro[0, ],
      progress = "none"
    ),
    "prior_only = TRUE"
  )
})

test_that("data and prior errors name kb_fit_weight_macro()", {
  local_fit_stan_stub(weight_macro_fit)
  err <- expect_error(kb_fit_weight_macro(
      data.frame(site = "a", year = "2020"),
      progress = "none"
  ))
  expect_identical(err$call[[1]], quote(kb_fit_weight_macro))
  err <- expect_error(kb_fit_weight_macro(
    data_weight_sim_macro,
    priors = list(nope = kb_prior_normal(0, 1)),
    progress = "none"
  ))
  expect_identical(err$call[[1]], quote(kb_fit_weight_macro))
})
