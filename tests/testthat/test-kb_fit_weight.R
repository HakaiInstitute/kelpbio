test_that("kb_fit_weight returns a correctly-structured object", {
  skip_on_cran()
  d <- droplevels(subset(
    kb_data_weight,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  fit <- kb_fit_weight(d, chains = 2, iter = 100, nthin = 1, cores = 2, quiet = TRUE, seed = 1)

  expect_s3_class(fit, "kb_fit_weight")
  expect_s3_class(fit, "kb_fit")
  expect_named(fit, c("draws", "diagnostics", "data", "meta"))
  expect_true(posterior::is_draws_rvars(fit$draws))
  expect_setequal(
    posterior::variables(fit$draws),
    c(
      "bWeight30", "bDiameter", "bDiameter2",
      "sSite", "sSiteDiameter", "sSiteYear", "sWeight",
      "bSite", "bSiteDiameter", "bSiteYear"
    )
  )
  # the live stanfit is discarded
  expect_false(any(vapply(fit, function(x) inherits(x, "stanfit"), logical(1))))
})

test_that("prior_only fit ignores the data", {
  skip_on_cran()
  d <- droplevels(subset(
    kb_data_weight,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  f1 <- kb_fit_weight(d, prior_only = TRUE, chains = 1, iter = 300, nthin = 1, cores = 1, quiet = TRUE, seed = 7)
  d2 <- d
  d2$weight <- rev(d2$weight)
  f2 <- kb_fit_weight(d2, prior_only = TRUE, chains = 1, iter = 300, nthin = 1, cores = 1, quiet = TRUE, seed = 7)
  # likelihood off => permuting the response leaves the prior-only fit unchanged
  expect_equal(median(f1$draws$bWeight30), median(f2$draws$bWeight30), tolerance = 0.05)
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_weight(kb_data_weight[0, ], prior_only = TRUE, chains = 1, iter = 100, nthin = 1, cores = 1, quiet = TRUE, seed = 1)
  expect_s3_class(fit, "kb_fit_weight")
})
