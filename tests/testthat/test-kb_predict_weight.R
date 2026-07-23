# kb_predict_weight(): predict at supplied rows (or observed data when NULL).

test_that("new_data = NULL predicts at the observed rows, conditioned", {
  p <- kb_predict_weight(weight_fit)
  expect_s3_class(p, "kb_predictions")
  expect_equal(nrow(p), nrow(weight_fit$data))
  # conditioned on observed groups -> matches augment's fitted values
  expect_equal(p$estimate, signif(augment(weight_fit)$fitted, 3), tolerance = 1e-6)
})

test_that("predictions are ordered and positive", {
  p <- kb_predict_weight(weight_fit)
  expect_true(all(p$lower <= p$estimate & p$estimate <= p$upper))
  expect_true(all(p$estimate > 0))
})

test_that("predicts at supplied rows", {
  nd <- data.frame(diameter = c(20, 40, 60))
  p <- kb_predict_weight(weight_fit, new_data = nd)
  expect_equal(nrow(p), 3L)
  expect_equal(p$diameter, c(20, 40, 60))
})

test_that("a new site is sampled, not errored, and is wider than a known site", {
  set.seed(1)
  site1 <- weight_fit$meta$site_levels[1]
  known <- kb_predict_weight(
    weight_fit,
    new_data = data.frame(diameter = 40, site = site1),
    new_levels = "sample"
  )
  new <- kb_predict_weight(
    weight_fit,
    new_data = data.frame(diameter = 40, site = "brand_new_site"),
    new_levels = "sample"
  )
  expect_equal(nrow(new), 1L)
  expect_gt(new$upper - new$lower, known$upper - known$lower)
})

test_that("default new_levels is \"sample\", and set.seed makes it reproducible", {
  nd <- data.frame(diameter = c(20, 40), site = "brand_new_site")
  set.seed(1)
  default <- kb_predict_weight(weight_fit, nd)
  set.seed(1)
  sampled <- kb_predict_weight(weight_fit, nd, new_levels = "sample")
  expect_equal(default$lower, sampled$lower)
  expect_equal(default$upper, sampled$upper)
})

test_that("estimate reduces each row's draws (custom function, matches posterior_epred)", {
  nd <- data.frame(diameter = c(20, 40), site = weight_fit$meta$site_levels[1])
  # A trimmed mean has no rvar method; it must be applied to the numeric draws.
  trimmed <- function(x) mean(x, trim = 0.1)
  p <- kb_predict_weight(weight_fit, nd, new_levels = "average", estimate = trimmed)
  ep <- posterior_epred(weight_fit, new_data = nd, new_levels = "average")
  expect_equal(p$estimate, signif(apply(ep, 2L, trimmed), 3))
})

test_that("new_data must have a diameter column", {
  expect_error(
    kb_predict_weight(weight_fit, new_data = data.frame(x = 1)),
    "diameter"
  )
})

test_that("representative_site borrows a known site's main effects for a new site", {
  site1 <- weight_fit$meta$site_levels[1]
  diameter <- c(20, 40, 60)
  # With new_levels = "average" and no year column, the site:year term is zero
  # for both, so a new site borrowing site1 must match predicting site1 itself.
  rep <- kb_predict_weight(
    weight_fit, data.frame(diameter = diameter, site = "brand_new_site"),
    new_levels = "average", representative_site = site1
  )
  known <- kb_predict_weight(
    weight_fit, data.frame(diameter = diameter, site = site1),
    new_levels = "average"
  )
  expect_equal(rep$estimate, known$estimate)
})

test_that("multiple representative sites differ from a single one", {
  sl <- weight_fit$meta$site_levels
  nd <- data.frame(diameter = c(20, 40, 60), site = "brand_new_site")
  one <- kb_predict_weight(weight_fit, nd, new_levels = "average", representative_site = sl[1])
  many <- kb_predict_weight(weight_fit, nd, new_levels = "average", representative_site = sl[1:2])
  expect_false(isTRUE(all.equal(one$estimate, many$estimate)))
})

test_that("representative_site rejects sites not in the fit", {
  nd <- data.frame(diameter = 40, site = "brand_new_site")
  expect_snapshot(
    kb_predict_weight(weight_fit, nd, representative_site = "not_a_site"),
    error = TRUE
  )
})
