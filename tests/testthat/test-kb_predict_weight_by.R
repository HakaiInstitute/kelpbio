# kb_predict_weight_by(): allometric curve(s) over a diameter sequence.

test_that("population curve spans the observed diameter range", {
  p <- kb_predict_weight_by(weight_fit, new_levels = "average")
  expect_s3_class(p, "kb_predictions")
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
