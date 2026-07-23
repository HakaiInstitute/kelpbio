# kb_predict_weight_by(): allometric curve(s) over a diameter sequence.

test_that("population curve spans the observed diameter range", {
  p <- kb_predict_weight_by(weight_fit, new_levels = "average")
  expect_s3_class(p, "kb_predictions")
  expect_true(all(c("estimate", "lower", "upper") %in% names(p)))
  rng <- range(weight_fit$data$diameter)
  expect_gte(min(p$diameter), rng[1] - 1e-6)
  expect_lte(max(p$diameter), rng[2] + 1e-6)
})

test_that("default new_levels is \"average\" (deterministic band)", {
  d1 <- kb_predict_weight_by(weight_fit, by = "site")
  d2 <- kb_predict_weight_by(weight_fit, by = "site", new_levels = "average")
  expect_equal(d1$lower, d2$lower)
  expect_equal(d1$upper, d2$upper)
})

test_that("sample band is at least as wide as average (the population band)", {
  set.seed(1)
  avg <- kb_predict_weight_by(weight_fit, new_levels = "average")
  smp <- kb_predict_weight_by(weight_fit, new_levels = "sample")
  expect_true(all((smp$upper - smp$lower) >= (avg$upper - avg$lower)))
})

test_that("predictions are ordered within the band", {
  p <- kb_predict_weight_by(weight_fit, new_levels = "average")
  expect_true(all(p$lower <= p$estimate & p$estimate <= p$upper))
})

test_that("by produces one curve per group", {
  bs <- kb_predict_weight_by(weight_fit, by = "site")
  expect_true("site" %in% names(bs))
  expect_setequal(unique(as.character(bs$site)), weight_fit$meta$site_levels)
  bsy <- kb_predict_weight_by(weight_fit, by = c("site", "year"))
  expect_true(all(c("site", "year") %in% names(bsy)))
})

test_that("by = c(site, year) uses only observed site-year combinations", {
  bsy <- kb_predict_weight_by(weight_fit, by = c("site", "year"))
  got <- unique(paste(bsy$site, bsy$year))
  observed <- unique(paste(weight_fit$data$site, weight_fit$data$year))
  expect_setequal(got, observed)
})

test_that("custom diameter sequence is honoured", {
  p <- kb_predict_weight_by(weight_fit, diameter = c(25, 50, 75))
  expect_equal(p$diameter, c(25, 50, 75))
})

test_that("wider conf_level gives a wider interval", {
  p90 <- kb_predict_weight_by(weight_fit, new_levels = "average", conf_level = 0.90)
  p99 <- kb_predict_weight_by(weight_fit, new_levels = "average", conf_level = 0.99)
  expect_true(all((p99$upper - p99$lower) >= (p90$upper - p90$lower)))
})

test_that("invalid by errors", {
  expect_error(kb_predict_weight_by(weight_fit, by = "year"), "not available")
  expect_error(kb_predict_weight_by(weight_fit, by = "bogus"), "Invalid")
})
