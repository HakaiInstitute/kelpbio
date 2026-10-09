test_that("predict wraps each model's prediction verb", {
  nd <- data.frame(diameter_mm = c(20, 40))
  expect_identical(
    predict(weight_nereo_fit, new_data = nd),
    kb_predict_weight(weight_nereo_fit, new_data = nd)
  )
  nd <- data.frame(site = fitted_sites(size_nereo_fit, 2))
  expect_identical(
    predict(size_nereo_fit, new_data = nd),
    kb_predict_size(size_nereo_fit, new_data = nd)
  )
  expect_identical(
    predict(density_nereo_fit, new_data = nd),
    kb_predict_density(density_nereo_fit, new_data = nd)
  )
  expect_identical(predict(wetdry_nereo_fit), kb_predict_wetdry(wetdry_nereo_fit))
  expect_identical(predict(carbon_nereo_fit), kb_predict_carbon(carbon_nereo_fit))
})

test_that("predict wraps kb_predict_cover_biomass", {
  nd <- data.frame(canopy_area_m2 = c(20, 80), plot_area_m2 = 200, tide_height_m = 0.5)
  expect_identical(
    predict(cover_biomass_nereo_fit, new_data = nd),
    kb_predict_cover_biomass(cover_biomass_nereo_fit, new_data = nd)
  )
})

test_that("errors name predict(), not the wrapped verb", {
  err <- expect_error(predict(weight_nereo_fit, data.frame(diameter_mm = -1)))
  expect_identical(err$call[[1]], quote(predict))
  err <- expect_error(predict(density_nereo_fit, data.frame(area_m2 = -1)))
  expect_identical(err$call[[1]], quote(predict))
})
