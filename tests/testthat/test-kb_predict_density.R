test_that("kb_predict_density at the observed data matches augment", {
  for (fit in list(density_nereo_fit, density_macro_fit)) {
    p <- kb_predict_density(fit)
    expect_s3_class(p, "kb_predictions")
    expect_equal(nrow(p), nobs(fit))
    expect_equal(p$estimate, signif(augment(fit)$fitted, 3))
    expect_identical(attr(p, "kb_response"), fit$meta$response)
  }
})

test_that("the expected count scales with the transect area", {
  for (fit in list(density_nereo_fit, density_macro_fit)) {
    p <- kb_predict_density(
      fit,
      data.frame(site = "site1", year = "2019", area_m2 = c(10, 20)),
      new_levels = "average",
      sig_fig = 8
    )
    expect_equal(p$estimate[2], 2 * p$estimate[1], tolerance = 1e-6)
    expect_named(p, c("site", "year", "area_m2", "estimate", "lower", "upper"))
  }
})

test_that("new_data must carry a valid area_m2", {
  expect_snapshot(
    kb_predict_density(density_nereo_fit, data.frame(site = "site1")),
    error = TRUE
  )
  expect_error(
    kb_predict_density(density_nereo_fit, data.frame(area_m2 = 0)),
    "area_m2"
  )
  expect_error(kb_predict_density(density_nereo_fit, 1), "must be a data frame")
})

test_that("a new site is sampled or averaged, and a representative site stands in", {
  withr::local_seed(1)
  nd <- data.frame(site = "new_site", area_m2 = 40)
  sampled <- kb_predict_density(density_nereo_fit, nd, new_levels = "sample")
  averaged <- kb_predict_density(density_nereo_fit, nd, new_levels = "average")
  expect_gte(sampled$upper - sampled$lower, averaged$upper - averaged$lower)

  rep <- kb_predict_density(
    density_nereo_fit,
    nd,
    new_levels = "average",
    representative_site = "site1"
  )
  known <- kb_predict_density(
    density_nereo_fit,
    data.frame(site = "site1", area_m2 = 40),
    new_levels = "average"
  )
  expect_equal(rep$estimate, known$estimate)
})

test_that("kb_predict_density errors on other models and a non-fit", {
  expect_error(kb_predict_density(weight_fit), "must be a <kb_fit_density> object")
  expect_error(kb_predict_density(size_nereo_fit), "must be a <kb_fit_density> object")
  expect_error(kb_predict_density(1), "must be a <kb_fit_density> object")
  expect_error(kb_predict_weight(density_nereo_fit), "must be a <kb_fit_weight>")
})

test_that("predict() wraps kb_predict_density()", {
  nd <- data.frame(site = "site1", area_m2 = 40)
  expect_equal(
    predict(density_macro_fit, nd, new_levels = "average"),
    kb_predict_density(density_macro_fit, nd, new_levels = "average")
  )
})
