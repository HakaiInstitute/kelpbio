# kb_predict_weight_by(): allometric curve(s) over a diameter sequence.

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

test_that("a supplied predictor sequence is used for either species", {
  expect_equal(
    kb_predict_weight_by(weight_fit, diameter = c(25, 50, 75))$diameter,
    c(25, 50, 75)
  )
  expect_equal(
    kb_predict_weight_by(weight_macro_fit, fronds = c(2, 5, 10))$fronds,
    c(2, 5, 10)
  )
})

test_that("the wrong-species predictor argument errors", {
  # `fronds` is the Macrocystis predictor; a Nereocystis fit rejects it
  expect_error(
    kb_predict_weight_by(weight_fit, fronds = c(2, 5)),
    "diameter"
  )
  # `diameter` is the Nereocystis predictor; a Macrocystis fit rejects it
  expect_error(
    kb_predict_weight_by(weight_macro_fit, diameter = c(20, 40)),
    "fronds"
  )
})

test_that("by = \"year\" gives one curve per fitted year", {
  p <- kb_predict_weight_by(weight_macro_fit, by = "year")
  expect_s3_class(p, "kb_predictions")
  expect_true("year" %in% names(p))
  expect_true("fronds" %in% names(p))
  expect_setequal(
    unique(as.character(p$year)),
    weight_macro_fit$meta$year_levels
  )
})

test_that("wider conf_level gives a wider interval", {
  p90 <- kb_predict_weight_by(
    weight_fit,
    new_levels = "average",
    conf_level = 0.90
  )
  p99 <- kb_predict_weight_by(
    weight_fit,
    new_levels = "average",
    conf_level = 0.99
  )
  expect_true(all((p99$upper - p99$lower) >= (p90$upper - p90$lower)))
})

test_that("kb_predict_weight_by errors on an object that is not a weight fit", {
  # the message wording is pinned once in test-chk.R; what matters here is that
  # the verb rejects a non-fit and the condition names the verb, not the default
  expect_error(kb_predict_weight_by(1), "must be a <kb_fit_weight> object")
  expect_equal(
    rlang::catch_cnd(kb_predict_weight_by(1))$call,
    quote(kb_predict_weight_by(1))
  )
})

test_that("kb_predict_weight_by errors on a weight fit with no species method", {
  fake <- structure(
    list(),
    class = c("kb_fit_weight_other", "kb_fit_weight", "kb_fit")
  )
  # the enumerated-constructor wording is pinned once in test-abort.R
  err <- expect_error(
    kb_predict_weight_by(fake),
    "no method for.*<kb_fit_weight_other>"
  )
  expect_match(conditionMessage(err), "kb_fit_weight_nereo")
})

test_that("a supplied predictor sequence far outside the fitted range warns", {
  expect_warning(
    kb_predict_weight_by(weight_fit, diameter = c(30, 500)),
    "far outside"
  )
})

test_that("site-year curves use each site-year's recorded density", {
  # one site-year curve at 30 mm equals predicting that site-year with its
  # recorded density supplied explicitly
  curve <- kb_predict_weight_by(weight_fit, by = c("site", "year"), diameter = 30)
  row <- curve[curve$site == "site1" & curve$year == "2019", ]
  recorded <- weight_fit$meta$density_levels[["site1:2019"]]
  explicit <- kb_predict_weight(
    weight_fit,
    data.frame(diameter = 30, site = "site1", year = "2019", density = recorded),
    new_levels = "average"
  )
  expect_equal(row$estimate, explicit$estimate)
})
