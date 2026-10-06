test_that("kb_predict_density at the observed data is the fitted count per m2", {
  for (fit in list(density_nereo_fit, density_macro_fit)) {
    p <- kb_predict_density(fit, sig_fig = 8)
    expect_s3_class(p, "kb_predictions")
    expect_equal(nrow(p), nobs(fit))
    expect_equal(
      p$estimate,
      augment(fit)$fitted / fit$data$area_m2,
      tolerance = 1e-6
    )
    expect_identical(attr(p, "kb_response"), paste0(fit$meta$response, "_m2"))
  }
})

test_that("the estimate is per m2 whatever the transect area", {
  for (fit in list(density_nereo_fit, density_macro_fit)) {
    p <- kb_predict_density(
      fit,
      data.frame(site = "site1", year = "2019", area_m2 = c(10, 20))
    )
    expect_equal(p$estimate[1], p$estimate[2])
    expect_named(p, c("site", "year", "area_m2", "estimate", "lower", "upper"))
  }
})

test_that("new_data needs no columns, and a grid gives one row per group", {
  bare <- kb_predict_density(density_nereo_fit, data.frame(site = "site1"))
  expect_named(bare, c("site", "estimate", "lower", "upper"))

  site <- kb_predict_density(
    density_nereo_fit,
    kb_new_data(density_nereo_fit, by = "site")
  )
  expect_equal(nrow(site), length(density_nereo_fit$meta$site_levels))
  expect_equal(attr(site, "kb_group_vars"), "site")
  expect_null(attr(site, "kb_predictor", exact = TRUE))

  pop <- kb_predict_density(density_macro_fit, kb_new_data(density_macro_fit))
  expect_equal(nrow(pop), 1L)
  expect_identical(attr(pop, "kb_response"), "plants_m2")
})

test_that("the per-m2 estimate summarises the expected count on 1 m2", {
  for (fit in list(density_nereo_fit, density_macro_fit)) {
    nd <- data.frame(site = c("site1", "site2"))
    p <- kb_predict_density(fit, nd, sig_fig = 8)
    ep <- posterior_epred(fit, transform(nd, area_m2 = 1))
    expect_equal(p$estimate, signif(apply(ep, 2L, stats::median), 8))
  }
})

test_that("an invalid area_m2 or new_data errors", {
  expect_error(
    kb_predict_density(density_nereo_fit, data.frame(area_m2 = 0)),
    "area_m2"
  )
  expect_error(kb_predict_density(density_nereo_fit, 1), "must be a data frame")
})

test_that("a by argument is redirected to kb_new_data()", {
  expect_snapshot(kb_predict_density(density_nereo_fit, by = "site"), error = TRUE)
})

test_that("a new site is averaged by default, and a representative site stands in", {
  withr::local_seed(1)
  nd <- data.frame(site = "new_site")
  sampled <- kb_predict_density(density_nereo_fit, nd, new_levels = "sample")
  averaged <- kb_predict_density(density_nereo_fit, nd)
  expect_gte(sampled$upper - sampled$lower, averaged$upper - averaged$lower)

  rep <- kb_predict_density(density_nereo_fit, nd, representative_site = "site1")
  known <- kb_predict_density(density_nereo_fit, data.frame(site = "site1"))
  expect_equal(rep$estimate, known$estimate)
})

test_that("kb_predict_density errors on other models and a non-fit", {
  expect_error(kb_predict_density(weight_fit), "must be a <kb_fit_density> object")
  expect_error(kb_predict_density(size_nereo_fit), "must be a <kb_fit_density> object")
  expect_error(kb_predict_density(1), "must be a <kb_fit_density> object")
  expect_error(kb_predict_weight(density_nereo_fit), "must be a <kb_fit_weight>")
})
