# kb_predict_weight(): predict at supplied rows (or observed data when NULL).

test_that("new_data = NULL predicts at the observed rows, conditioned", {
  p <- kb_predict_weight(weight_fit)
  expect_s3_class(p, "kb_predictions")
  expect_equal(nrow(p), nrow(weight_fit$data))
  # conditioned on observed groups -> matches augment's fitted values
  expect_equal(
    p$estimate,
    signif(augment(weight_fit)$fitted, 3),
    tolerance = 1e-6
  )
})

test_that("predicts at supplied rows", {
  nd <- data.frame(diameter_mm = c(20, 40, 60))
  p <- kb_predict_weight(weight_fit, new_data = nd)
  expect_equal(nrow(p), 3L)
  expect_equal(p$diameter_mm, c(20, 40, 60))
})

test_that("a new site is averaged by default; sample gives a wider interval", {
  new_site <- data.frame(diameter_mm = 40, site = "brand_new_site")
  default <- kb_predict_weight(weight_fit, new_site)
  averaged <- kb_predict_weight(weight_fit, new_site, new_levels = "average")
  # the default is deterministic, with no seed
  expect_identical(default, kb_predict_weight(weight_fit, new_site))
  expect_identical(default, averaged)
  set.seed(1)
  sampled <- kb_predict_weight(weight_fit, new_site, new_levels = "sample")
  expect_gt(sampled$upper - sampled$lower, averaged$upper - averaged$lower)
})

test_that("predictions at a kb_new_data() grid are marked as curves", {
  expect_true(attr(kb_predict_weight(weight_fit, kb_new_data(weight_fit)), "kb_curve"))
  expect_false(attr(kb_predict_weight(weight_fit), "kb_curve"))
})

test_that("a by argument is redirected to kb_new_data()", {
  expect_error(kb_predict_weight(weight_fit, by = "site"), "kb_new_data")
  expect_error(kb_predict_weight(weight_fit, "site"), "kb_new_data")
})

test_that("estimate reduces each row's draws (custom function, matches posterior_epred)", {
  nd <- data.frame(diameter_mm = c(20, 40), site = weight_fit$meta$site_levels[1])
  # A trimmed mean has no rvar method; it must be applied to the numeric draws.
  trimmed <- function(x) mean(x, trim = 0.1)
  p <- kb_predict_weight(
    weight_fit,
    nd,
    new_levels = "average",
    estimate = trimmed
  )
  ep <- posterior_epred(weight_fit, new_data = nd, new_levels = "average")
  expect_equal(p$estimate, signif(apply(ep, 2L, trimmed), 3))
})

test_that("macro predicts on the fronds predictor and rejects a diameter column", {
  nd <- data.frame(fronds = c(2, 5, 10))
  p <- kb_predict_weight(weight_macro_fit, new_data = nd)
  expect_s3_class(p, "kb_predictions")
  expect_equal(p$fronds, c(2, 5, 10))
  expect_equal(attr(p, "kb_predictor"), "fronds")
  expect_true(all(p$estimate > 0))
  expect_error(
    kb_predict_weight(weight_macro_fit, new_data = data.frame(diameter_mm = 30)),
    "fronds"
  )
})

test_that("representative_site borrows a known site's main effects for a new site", {
  site1 <- weight_fit$meta$site_levels[1]
  diameter <- c(20, 40, 60)
  # With new_levels = "average" and no year column, the site:year term is zero
  # for both, so a new site borrowing site1 must match predicting site1 itself.
  rep <- kb_predict_weight(
    weight_fit,
    data.frame(diameter_mm = diameter, site = "brand_new_site"),
    new_levels = "average",
    representative_site = site1
  )
  known <- kb_predict_weight(
    weight_fit,
    data.frame(diameter_mm = diameter, site = site1),
    new_levels = "average"
  )
  expect_equal(rep$estimate, known$estimate)
})

test_that("representative_site rejects sites not in the fit", {
  nd <- data.frame(diameter_mm = 40, site = "brand_new_site")
  # the message itself is pinned in test-chk.R
  expect_error(
    kb_predict_weight(weight_fit, nd, representative_site = "not_a_site"),
    "representative_site"
  )
})

test_that("kb_predict_weight errors on an object that is not a weight fit", {
  # the message wording is pinned once in test-chk.R; what matters here is that
  # the verb rejects a non-fit and the condition names the verb, not the default
  expect_error(kb_predict_weight(1), "must be a <kb_fit_weight> object")
  expect_equal(
    rlang::catch_cnd(kb_predict_weight(1))$call,
    quote(kb_predict_weight(1))
  )
})

test_that("kb_predict_weight errors on a weight fit with no species method", {
  fake <- structure(
    list(data = data.frame(diameter_mm = 30), meta = list()),
    class = c("kb_fit_weight_other", "kb_fit_weight", "kb_fit")
  )
  expect_error(kb_predict_weight(fake), "no method for.*<kb_fit_weight_other>")
})

test_that("new_data far outside the fitted range warns but still predicts", {
  expect_warning(
    p <- kb_predict_weight(
      weight_fit,
      data.frame(diameter_mm = min(weight_fit$data$diameter_mm) / 4),
      new_levels = "average"
    ),
    "far outside"
  )
  expect_equal(nrow(p), 1L)
})

test_that("a fitted site-year recorded without density uses the fitted mean", {
  # The first fitted site-year; dropping its stored density makes it one recorded
  # as NA
  fit <- weight_fit
  levels <- fit$meta$density_levels
  site_year <- strsplit(names(levels)[1], ":", fixed = TRUE)[[1]]
  fit$meta$density_levels <- levels[-1]
  bare <- kb_predict_weight(
    fit,
    data.frame(diameter_mm = 30, site = site_year[1], year = site_year[2]),
    new_levels = "average"
  )
  at_mean <- kb_predict_weight(
    fit,
    data.frame(
      diameter_mm = 30,
      site = site_year[1],
      year = site_year[2],
      stipes_m2 = fit$meta$density_mean
    ),
    new_levels = "average"
  )
  expect_equal(bare$estimate, at_mean$estimate)
})

test_that("density far above the fitted range warns; a sparse density does not", {
  nd <- function(density) data.frame(diameter_mm = 30, stipes_m2 = density)
  expect_warning(
    kb_predict_weight(weight_fit, nd(40000), new_levels = "average"),
    "far outside"
  )
  expect_no_warning(kb_predict_weight(weight_fit, nd(0.2), new_levels = "average"))
})
