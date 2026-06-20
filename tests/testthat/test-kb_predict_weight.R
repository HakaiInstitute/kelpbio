# kb_predict_weight(): predict at supplied rows (or observed data when NULL).

test_that("new_data = NULL predicts at the observed rows, conditioned", {
  p <- kb_predict_weight(weight_fit)
  expect_s3_class(p, "kb_predictions")
  expect_true(all(c("estimate", "lower", "upper") %in% names(p)))
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
  nd <- data.frame(diameter_mm = c(20, 40, 60))
  p <- kb_predict_weight(weight_fit, new_data = nd)
  expect_equal(nrow(p), 3L)
  expect_equal(p$diameter_mm, c(20, 40, 60))
})

test_that("a new site is sampled, not errored, and is wider than a known site", {
  site1 <- weight_fit$meta$site_levels[1]
  known <- kb_predict_weight(
    weight_fit, new_data = data.frame(diameter_mm = 40, site = site1),
    new_levels = "sample"
  )
  new <- kb_predict_weight(
    weight_fit, new_data = data.frame(diameter_mm = 40, site = "brand_new_site"),
    new_levels = "sample"
  )
  expect_equal(nrow(new), 1L)
  expect_gt(new$upper - new$lower, known$upper - known$lower)
})

test_that("a mix of known and new sites resolves in one call", {
  site1 <- weight_fit$meta$site_levels[1]
  nd <- data.frame(diameter_mm = 40, site = c(site1, "new_reef"))
  p <- kb_predict_weight(weight_fit, new_data = nd, new_levels = "sample")
  expect_equal(nrow(p), 2L)
  # the new reef carries more between-site uncertainty than the known site
  expect_gt((p$upper - p$lower)[2], (p$upper - p$lower)[1])
})

test_that("new_data must have a diameter_mm column", {
  expect_error(kb_predict_weight(weight_fit, new_data = data.frame(x = 1)))
})
