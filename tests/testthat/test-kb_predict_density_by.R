test_that("kb_predict_density_by returns density per m2, one row per group", {
  site <- kb_predict_density_by(density_nereo_fit, by = "site")
  expect_s3_class(site, "kb_predictions")
  expect_equal(nrow(site), length(density_nereo_fit$meta$site_levels))
  # the helper area column is dropped and the response named per m2
  expect_named(site, c("site", "estimate", "lower", "upper"))
  expect_equal(attr(site, "kb_group_vars"), "site")
  expect_null(attr(site, "kb_predictor", exact = TRUE))
  expect_identical(attr(site, "kb_response"), "stipes_m2")

  pop <- kb_predict_density_by(density_macro_fit)
  expect_equal(nrow(pop), 1L)
  expect_identical(attr(pop, "kb_response"), "plants_m2")
  sy <- kb_predict_density_by(density_macro_fit, by = c("site", "year"))
  expect_equal(nrow(sy), length(density_macro_fit$meta$site_year_levels))
})

test_that("density by group equals the expected count on one m2", {
  for (fit in list(density_nereo_fit, density_macro_fit)) {
    by_site <- kb_predict_density_by(fit, by = "site")
    rows <- kb_predict_density(
      fit,
      data.frame(site = by_site$site, area_m2 = 1),
      new_levels = "average"
    )
    expect_equal(by_site$estimate, rows$estimate)
    expect_equal(by_site$lower, rows$lower)
  }
})

test_that("kb_predict_density_by rejects a bad by and other models", {
  expect_error(kb_predict_density_by(density_nereo_fit, by = "month"), "Invalid")
  expect_error(
    kb_predict_density_by(size_nereo_fit),
    "must be a <kb_fit_density> object"
  )
  expect_error(
    kb_predict_density_by(density_nereo_fit, area_m2 = 1),
    class = "rlib_error_dots_nonempty"
  )
})
