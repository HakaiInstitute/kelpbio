test_that("resolve_cores respects mc.cores, caps at available, floors at 1", {
  avail <- parallel::detectCores()
  old <- options(mc.cores = 1)
  on.exit(options(old), add = TRUE)
  expect_identical(kelpbio:::resolve_cores(NULL, 4L), 1L) # NULL -> mc.cores
  expect_identical(kelpbio:::resolve_cores(1L, 4L), 1L) # explicit honoured
  expect_gte(kelpbio:::resolve_cores(NULL, 4L), 1L) # floored at 1
  if (!is.na(avail)) {
    expect_lte(kelpbio:::resolve_cores(1000L, 4L), avail) # never oversubscribe
  }
})

test_that("kb_fit_weight returns a correctly-structured object", {
  skip_on_cran()
  d <- droplevels(subset(
    sim_weight,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  fit <- kb_fit_weight(d, chains = 2, niters = 100, nthin = 1, cores = 2, quiet = TRUE, seed = 1)

  expect_s3_class(fit, "kb_fit_weight")
  expect_s3_class(fit, "kb_fit")
  expect_named(fit, c("draws", "gq", "diagnostics", "data", "meta"))
  expect_true(posterior::is_draws_rvars(fit$draws))
  expect_setequal(
    posterior::variables(fit$draws),
    c(
      "bWeight30", "bDiameter", "bDiameter2",
      "sSite", "sSiteDiameter", "sSiteYear", "sWeight",
      "bSite", "bSiteDiameter", "bSiteYear"
    )
  )
  # niters = saved post-warmup draws per chain
  expect_equal(niters(fit), 100L)
  # log_lik / yrep generated quantities are stored for loo / pp_check
  expect_setequal(posterior::variables(fit$gq), c("log_lik", "yrep"))
  # the live stanfit is discarded
  expect_false(any(vapply(fit, function(x) inherits(x, "stanfit"), logical(1))))
})

test_that("prior_only fit ignores the data", {
  skip_on_cran()
  d <- droplevels(subset(
    sim_weight,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  f1 <- kb_fit_weight(d, prior_only = TRUE, chains = 1, niters = 300, nthin = 1, cores = 1, quiet = TRUE, seed = 7)
  d2 <- d
  d2$weight_kg <- rev(d2$weight_kg)
  f2 <- kb_fit_weight(d2, prior_only = TRUE, chains = 1, niters = 300, nthin = 1, cores = 1, quiet = TRUE, seed = 7)
  # likelihood off => permuting the response leaves the prior-only fit unchanged
  expect_equal(median(f1$draws$bWeight30), median(f2$draws$bWeight30), tolerance = 0.05)
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_weight(sim_weight[0, ], prior_only = TRUE, chains = 1, niters = 100, nthin = 1, cores = 1, quiet = TRUE, seed = 1)
  expect_s3_class(fit, "kb_fit_weight")
  # no observations -> no generated quantities stored
  expect_null(fit$gq)
})
