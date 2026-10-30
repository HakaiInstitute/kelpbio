test_that("resolve_priors returns defaults when priors is NULL", {
  d <- kb_priors_weight_nereo()
  expect_identical(resolve_priors(NULL, d), d)
})

test_that("resolve_priors overrides supplied entries and keeps the rest", {
  d <- kb_priors_weight_nereo()
  out <- resolve_priors(list(sd_site = kb_prior_exponential(2)), d)
  expect_equal(out$sd_site, kb_prior_exponential(2))
  expect_equal(out$intercept, d$intercept)
  expect_named(out, names(d))
})

test_that("resolve_priors errors on unknown names", {
  d <- kb_priors_weight_nereo()
  expect_error(
    resolve_priors(list(nope = kb_prior_normal(0, 1)), d),
    "Unknown prior"
  )
})

test_that("resolve_priors errors on a family mismatch", {
  d <- kb_priors_weight_nereo()
  expect_error(
    resolve_priors(list(sd_site = kb_prior_normal(0, 1)), d),
    "wrong family"
  )
})

test_that("resolve_priors rejects a non-list or unnamed priors", {
  d <- kb_priors_weight_nereo()
  expect_error(resolve_priors(1:3, d))
  expect_error(resolve_priors(list(kb_prior_normal(0, 1)), d))
})

test_that("resolve_priors rejects repeated prior names", {
  d <- kb_priors_weight_nereo()
  p <- c(list(sd_site = kb_prior_exponential(1)), list(sd_site = kb_prior_exponential(2)))
  expect_error(resolve_priors(p, d), "unique")
})

test_that("resolve_priors errors name the supplied call", {
  d <- kb_priors_weight_nereo()
  call <- quote(kb_fit_weight_nereo())
  expect_identical(expect_error(resolve_priors(1:3, d, call = call))$call, call)
  expect_identical(
    expect_error(resolve_priors(list(nope = kb_prior_normal(0, 1)), d, call = call))$call,
    call
  )
  expect_identical(
    expect_error(resolve_priors(list(sd_site = kb_prior_normal(0, 1)), d, call = call))$call,
    call
  )
})

test_that("prior_data names one field per hyperparameter after entry and argument", {
  out <- prior_data(list(
    intercept = kb_prior_normal(0.1, 1.1),
    sd_site = kb_prior_exponential(2.1),
    cover_slope = kb_prior_lognormal(0.3, 1.3)
  ))
  expect_identical(
    out,
    list(
      prior_intercept_mean = 0.1,
      prior_intercept_sd = 1.1,
      prior_sd_site_rate = 2.1,
      prior_cover_slope_meanlog = 0.3,
      prior_cover_slope_sdlog = 1.3
    )
  )
})

test_that("prior_data returns no fields for no priors", {
  expect_identical(prior_data(list()), list())
})

test_that("fit_parameters estimates every prior entry and the effects", {
  priors <- kb_priors_size_nereo()
  got <- fit_parameters(priors, GROUP_EFFECTS)
  expect_identical(got$fixed, names(priors))
  expect_identical(got$random, GROUP_EFFECTS)
})

test_that("switched-off parameters are left out", {
  priors <- kb_priors_weight_nereo()
  got <- fit_parameters(
    priors,
    GROUP_EFFECTS,
    off = "weight_floor"
  )
  expect_false("weight_floor" %in% got$fixed)
  expect_identical(got$random, GROUP_EFFECTS)
})

test_that("a model without group effects estimates its prior entries", {
  got <- fit_parameters(kb_priors_wetdry_nereo())
  expect_identical(got$fixed, c("intercept", "precision"))
  expect_identical(got$random, character(0))
})
