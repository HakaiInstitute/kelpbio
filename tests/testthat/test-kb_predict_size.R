test_that("kb_predict_size at the observed data matches augment", {
  for (fit in list(size_nereo_fit, size_macro_fit)) {
    p <- kb_predict_size(fit)
    expect_s3_class(p, "kb_predictions")
    expect_equal(nrow(p), nobs(fit))
    expect_equal(p$estimate, signif(augment(fit)$fitted, 3))
  }
})

test_that("new_data needs no columns", {
  site <- kb_predict_size(
    size_nereo_fit,
    data.frame(site = fitted_sites(size_nereo_fit, 2)),
    new_levels = "average"
  )
  expect_equal(nrow(site), 2L)
  expect_named(site, c("site", "estimate", "lower", "upper"))
  bare <- kb_predict_size(
    size_nereo_fit,
    data.frame(row.names = 1:3),
    new_levels = "average"
  )
  expect_equal(nrow(bare), 3L)
  # the typical site and year, so every row is the same
  expect_length(unique(bare$estimate), 1L)
})

test_that("a kb_new_data() grid gives one row per group", {
  site <- kb_predict_size(size_nereo_fit, kb_new_data(size_nereo_fit, by = "site"))
  expect_equal(nrow(site), length(size_nereo_fit$meta$site_levels))
  expect_named(site, c("site", "estimate", "lower", "upper"))
  expect_equal(attr(site, "kb_group_vars"), "site")
  expect_null(attr(site, "kb_predictor", exact = TRUE))
  expect_identical(attr(site, "kb_response"), "diameter_mm")

  pop <- kb_predict_size(size_macro_fit, kb_new_data(size_macro_fit))
  expect_equal(nrow(pop), 1L)
})

test_that("a new site is sampled or averaged, and a representative site stands in", {
  withr::local_seed(1)
  nd <- data.frame(site = "new_site")
  sampled <- kb_predict_size(size_nereo_fit, nd, new_levels = "sample")
  averaged <- kb_predict_size(size_nereo_fit, nd, new_levels = "average")
  expect_gte(sampled$upper - sampled$lower, averaged$upper - averaged$lower)

  rep <- kb_predict_size(
    size_nereo_fit,
    nd,
    new_levels = "average",
    representative_site = fitted_sites(size_nereo_fit)
  )
  known <- kb_predict_size(
    size_nereo_fit,
    data.frame(site = fitted_sites(size_nereo_fit)),
    new_levels = "average"
  )
  expect_equal(rep$estimate, known$estimate)
})

test_that("the macro estimate is the truncated mean, at least 1", {
  p <- kb_predict_size(size_macro_fit, data.frame(site = fitted_sites(size_macro_fit)))
  expect_gte(p$lower, 1)
})

test_that("kb_predict_size errors on a weight fit and a non-fit", {
  expect_error(kb_predict_size(weight_fit), "must be a <kb_fit_size> object")
  expect_error(kb_predict_size(1), "must be a <kb_fit_size> object")
  expect_error(kb_predict_weight(size_nereo_fit), "must be a <kb_fit_weight>")
  expect_error(kb_predict_size(size_nereo_fit, 1), "must be a data frame")
})

test_that("predict() wraps kb_predict_size()", {
  nd <- data.frame(site = fitted_sites(size_nereo_fit))
  expect_equal(
    predict(size_nereo_fit, nd, new_levels = "average"),
    kb_predict_size(size_nereo_fit, nd, new_levels = "average")
  )
})
