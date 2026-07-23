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
  # message pins the unknown-name path (distinct from the family-mismatch path)
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
