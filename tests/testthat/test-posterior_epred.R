test_that("posterior_epred returns a D x N matrix of positive expected weights", {
  m <- posterior_epred(weight_fit, newdata = data.frame(diameter = c(20, 40, 60)))
  expect_true(is.matrix(m))
  expect_equal(ncol(m), 3L)
  expect_equal(nrow(m), posterior::ndraws(weight_fit$draws))
  expect_true(all(m > 0))
})

test_that("posterior_epred at observed data has one column per observed row", {
  m <- posterior_epred(weight_fit)
  expect_equal(ncol(m), nrow(weight_fit$data))
})

test_that("newdata = NULL conditions on observed groups, agreeing with augment", {
  # The observed data carries site/year columns, so the generic conditions on
  # each row's estimated random effects; its median matches augment's fitted.
  m <- posterior_epred(weight_fit)
  med <- apply(m, 2, stats::median)
  fitted <- augment(weight_fit)$fitted
  expect_equal(med, fitted, tolerance = 1e-8)
})

test_that("a site column conditions on that site", {
  site1 <- weight_fit$meta$site_levels[1]
  nd <- data.frame(diameter = c(30, 30), site = site1)
  m_site <- posterior_epred(weight_fit, newdata = nd, new_levels = "average")
  m_bare <- posterior_epred(weight_fit, newdata = data.frame(diameter = c(30, 30)), new_levels = "average")
  expect_false(isTRUE(all.equal(m_site, m_bare)))
})

test_that("an unknown site level is sampled, not errored", {
  nd <- data.frame(diameter = c(30, 30), site = "brand_new_site")
  m <- posterior_epred(weight_fit, newdata = nd, new_levels = "sample")
  expect_equal(dim(m), c(posterior::ndraws(weight_fit$draws), 2L))
  expect_true(all(m > 0))
})

test_that("representative_site makes a new site borrow a known site's main effects", {
  site1 <- weight_fit$meta$site_levels[1]
  diameter <- c(20, 40, 60)
  rep <- posterior_epred(
    weight_fit,
    newdata = data.frame(diameter = diameter, site = "brand_new_site"),
    new_levels = "average", representative_site = site1
  )
  known <- posterior_epred(
    weight_fit,
    newdata = data.frame(diameter = diameter, site = site1),
    new_levels = "average"
  )
  expect_equal(rep, known)
})
