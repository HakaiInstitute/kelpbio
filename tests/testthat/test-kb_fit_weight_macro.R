test_that("kb_fit_weight_macro does not expose site_year_on", {
  # the site:year structure is data-determined, not a user argument
  expect_false("site_year_on" %in% names(formals(kb_fit_weight_macro)))
})

test_that("kb_fit_weight_macro returns a correctly-structured object", {
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_macro,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
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
  expect_s3_class(fit, "kb_fit_weight")
  expect_s3_class(fit, "kb_fit")
  expect_identical(fit$meta$species, "macrocystis")
  expect_identical(fit$meta$predictor, "fronds")
  expect_named(fit, c("draws", "gq", "diagnostics", "data", "meta"))
  expect_true(posterior::is_draws_rvars(fit$draws))
  expect_setequal(
    posterior::variables(fit$draws),
    c(
      "bWeight",
      "bFronds",
      "shape",
      "sSite",
      "sYear",
      "sSiteYear",
      "bSite",
      "bYear",
      "bSiteYear"
    )
  )
  expect_equal(niters(fit), 100L)
  expect_setequal(posterior::variables(fit$gq), c("log_lik", "yrep"))
  expect_false(any(vapply(fit, function(x) inherits(x, "stanfit"), logical(1))))
})

test_that("prior_only fit ignores the data", {
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_macro,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
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
  d2$weight <- rev(d2$weight)
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
  expect_null(fit$gq)
})
