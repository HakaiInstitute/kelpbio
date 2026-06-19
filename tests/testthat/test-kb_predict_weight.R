test_that("auto-generated sequence spans the observed diameter range", {
  p <- kb_predict_weight(weight_fit, new_levels = "average")
  expect_s3_class(p, "kb_predictions")
  expect_true(all(c("estimate", "lower", "upper") %in% names(p)))
  rng <- range(weight_fit$data$diameter)
  expect_gte(min(p$diameter), rng[1] - 1e-6)
  expect_lte(max(p$diameter), rng[2] + 1e-6)
})

test_that("predictions are ordered and positive", {
  p <- kb_predict_weight(weight_fit)
  expect_true(all(p$lower <= p$estimate & p$estimate <= p$upper))
  expect_true(all(p$estimate > 0))
})

test_that("sample interval is at least as wide as average", {
  avg <- kb_predict_weight(weight_fit, new_levels = "average")
  smp <- kb_predict_weight(weight_fit, new_levels = "sample")
  expect_true(all((smp$upper - smp$lower) >= (avg$upper - avg$lower)))
})

test_that("wider conf_level gives a wider interval", {
  p90 <- kb_predict_weight(weight_fit, new_levels = "average", conf_level = 0.90)
  p99 <- kb_predict_weight(weight_fit, new_levels = "average", conf_level = 0.99)
  expect_true(all((p99$upper - p99$lower) >= (p90$upper - p90$lower)))
})

test_that("by produces one curve per group", {
  bs <- kb_predict_weight(weight_fit, by = "site")
  expect_true("site" %in% names(bs))
  expect_setequal(unique(as.character(bs$site)), weight_fit$meta$site_levels)
  bsy <- kb_predict_weight(weight_fit, by = c("site", "year"), new_levels = "average")
  expect_true(all(c("site", "year") %in% names(bsy)))
})

test_that("invalid by / new_levels combinations error", {
  expect_error(kb_predict_weight(weight_fit, by = c("site", "year"), new_levels = "sample"))
  expect_error(kb_predict_weight(weight_fit, by = "year"))
  expect_error(kb_predict_weight(weight_fit, by = "bogus"))
})

test_that("new_data predicts at the supplied rows", {
  p <- kb_predict_weight(weight_fit, new_data = data.frame(diameter = c(20, 40, 60)))
  expect_equal(nrow(p), 3L)
  expect_equal(p$diameter, c(20, 40, 60))
})
