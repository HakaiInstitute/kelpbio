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

test_that("custom diameter sequence is honoured (nereo)", {
  p <- kb_predict_weight_by(weight_fit, diameter = c(25, 50, 75))
  expect_equal(p$diameter, c(25, 50, 75))
})

test_that("custom fronds sequence is honoured (macro)", {
  p <- kb_predict_weight_by(weight_macro_fit, fronds = c(2, 5, 10))
  expect_equal(p$fronds, c(2, 5, 10))
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

test_that("by = \"year\" works for both species", {
  # both weight models carry a year main effect, so the grouping axis no longer
  # varies by species
  pn <- kb_predict_weight_by(weight_fit, by = "year")
  expect_s3_class(pn, "kb_predictions")
  expect_true("year" %in% names(pn))
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
