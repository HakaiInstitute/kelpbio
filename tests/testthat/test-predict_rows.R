test_that("errors from the shared checks name the prediction verb", {
  expect_snapshot(error = TRUE, {
    kb_predict_weight(weight_nereo_fit, data.frame(site = "a"))
    kb_predict_weight(weight_nereo_fit, conf_level = 2)
    kb_predict_size(size_nereo_fit, new_levels = "bogus")
    kb_predict_size(size_nereo_fit, representative_site = "bogus")
  })
})

test_that("the model verbs add a support column for rows with site and year", {
  rows <- data.frame(site = c(fitted_sites(weight_nereo_fit), "new"), year = "2019")
  weight <- kb_predict_weight(weight_nereo_fit, transform(rows, diameter_mm = 40))
  expect_identical(
    weight$weight_support,
    data_support(weight_nereo_fit, rows$site, rows$year)
  )
  expect_named(
    kb_predict_size(size_nereo_fit, rows),
    c("site", "year", "size_support", "estimate", "lower", "upper")
  )
  cover <- kb_predict_cover_calibration(
    cover_calibration_nereo_fit,
    data.frame(
      site = fitted_sites(cover_calibration_nereo_fit),
      year = "2019",
      canopy_area_m2 = 80,
      plot_area_m2 = 200,
      tide_height_m = 0.5
    )
  )
  expect_identical(cover$cover_support, "site, year")
  site_only <- kb_predict_weight(weight_nereo_fit, data.frame(site = "new", diameter_mm = 40))
  expect_false("weight_support" %in% names(site_only))
})
