test_that("predict wraps each model's prediction verb", {
  nd <- data.frame(diameter_mm = c(20, 40))
  expect_identical(
    predict(weight_fit, new_data = nd),
    kb_predict_weight(weight_fit, new_data = nd)
  )
  nd <- data.frame(site = c("site1", "site2"))
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
