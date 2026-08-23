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

test_that("by = \"year\" errors for nereo but works for macro", {
  # nereo has no year main effect: year alone is rejected
  expect_error(kb_predict_weight_by(weight_fit, by = "year"), "not available")
  # macro has a year main effect: one curve per year over a fronds sequence
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
  expect_snapshot(error = TRUE, kb_predict_weight_by(1))
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
  expect_snapshot(error = TRUE, kb_predict_weight_by(fake))
})

# ---- curve helpers -----------------------------------------------------------

test_that("validate_by_weight enforces the valid by set", {
  # two distinct rejections: year-alone (no main effect) vs an unknown factor
  expect_error(validate_by_weight("year", "nereocystis"), "not available")
  expect_error(validate_by_weight("bogus", "nereocystis"), "Invalid")
  expect_identical(validate_by_weight(NULL, "nereocystis"), character(0))
  expect_identical(validate_by_weight("site", "nereocystis"), "site")
  expect_identical(
    validate_by_weight(c("site", "year"), "nereocystis"),
    c("site", "year")
  )
})

test_that("validate_by_weight allows year alone for macro but not nereo", {
  expect_error(validate_by_weight("year", "nereocystis"), "not available")
  expect_identical(validate_by_weight("year", "macrocystis"), "year")
  expect_identical(
    validate_by_weight(c("site", "year"), "macrocystis"),
    c("site", "year")
  )
  expect_error(validate_by_weight("bogus", "macrocystis"), "Invalid")
})

test_that("build_by_grid spans the observed predictor range by default", {
  grid <- build_by_grid(weight_fit, character(0))
  expect_named(grid, "diameter")
  expect_equal(nrow(grid), 30L)
  expect_equal(range(grid$diameter), range(weight_fit$data$diameter))
})

test_that("build_by_grid names the predictor column from the fit", {
  grid <- build_by_grid(weight_macro_fit, character(0), values = c(2, 5))
  expect_named(grid, "fronds")
  expect_equal(grid$fronds, c(2, 5))
})

test_that("build_by_grid orders rows by the fit's level order", {
  # not the (arbitrary) row order of fit$data, so curves are drawn consistently
  grid <- build_by_grid(weight_fit, "site", values = c(20, 40))
  expect_identical(levels(grid$site), weight_fit$meta$site_levels)
  expect_false(is.unsorted(as.integer(grid$site)))
  expect_equal(nrow(grid), length(weight_fit$meta$site_levels) * 2L)
})

test_that("build_by_grid crosses only the observed site-year combinations", {
  grid <- build_by_grid(weight_fit, c("site", "year"), values = 30)
  observed <- unique(paste(weight_fit$data$site, weight_fit$data$year))
  expect_setequal(unique(paste(grid$site, grid$year)), observed)
})

test_that("weight_by_linpred returns the grid, the by axis and its linpred", {
  res <- weight_by_linpred(weight_fit, "site", "average")
  expect_named(res, c("grid", "by", "linpred"))
  expect_identical(res$by, "site")
  expect_s3_class(res$linpred, "rvar")
  expect_length(res$linpred, nrow(res$grid))
})

test_that("weight_by_linpred rejects a fit that is not a weight fit", {
  expect_error(weight_by_linpred(1, NULL, "average"), "kb_fit_weight")
})
