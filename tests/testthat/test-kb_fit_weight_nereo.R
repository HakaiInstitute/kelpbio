test_that("kb_fit_weight_nereo does not expose site_year_on", {
  # the site:year structure is data-determined, not a user argument
  expect_false("site_year_on" %in% names(formals(kb_fit_weight_nereo)))
})

test_that("kb_fit_weight returns a correctly-structured object", {
  skip_on_cran()
  d <- droplevels(subset(
    sim_weight,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  fit <- kb_fit_weight_nereo(d, chains = 2, niters = 100, nthin = 1, cores = 2, quiet = TRUE, seed = 1)

  expect_s3_class(fit, "kb_fit_weight")
  expect_s3_class(fit, "kb_fit")
  expect_named(fit, c("draws", "gq", "diagnostics", "data", "meta"))
  expect_true(posterior::is_draws_rvars(fit$draws))
  expect_setequal(
    posterior::variables(fit$draws),
    c(
      "bWeight", "bDiameter", "bDiameter2",
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

test_that("nthin > 1 still keeps exactly niters draws per chain", {
  skip_on_cran()
  d <- droplevels(subset(
    sim_weight,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  # fit_stan sets warmup = niters and total iters = niters + niters * nthin, so
  # the thinned post-warmup phase must land exactly niters draws regardless of
  # nthin. Exercised here with nthin = 2, which the nthin = 1 tests cannot catch.
  fit <- kb_fit_weight_nereo(d, chains = 1, niters = 50, nthin = 2, cores = 1, quiet = TRUE, seed = 3)
  expect_equal(niters(fit), 50L)
  expect_equal(posterior::ndraws(fit$draws), 50L)
})

test_that("prior_only fit ignores the data", {
  skip_on_cran()
  d <- droplevels(subset(
    sim_weight,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  f1 <- kb_fit_weight_nereo(d, prior_only = TRUE, chains = 1, niters = 300, nthin = 1, cores = 1, quiet = TRUE, seed = 7)
  d2 <- d
  d2$weight <- rev(d2$weight)
  f2 <- kb_fit_weight_nereo(d2, prior_only = TRUE, chains = 1, niters = 300, nthin = 1, cores = 1, quiet = TRUE, seed = 7)
  # likelihood off => permuting the response leaves the prior-only fit unchanged
  expect_equal(median(f1$draws$bWeight), median(f2$draws$bWeight), tolerance = 0.05)
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_weight_nereo(sim_weight[0, ], prior_only = TRUE, chains = 1, niters = 100, nthin = 1, cores = 1, quiet = TRUE, seed = 1)
  expect_s3_class(fit, "kb_fit_weight")
  # no observations -> no generated quantities stored
  expect_null(fit$gq)
})
