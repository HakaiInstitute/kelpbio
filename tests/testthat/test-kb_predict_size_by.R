test_that("kb_predict_size_by returns one row per group", {
  site <- kb_predict_size_by(size_nereo_fit, by = "site")
  expect_s3_class(site, "kb_predictions")
  expect_equal(nrow(site), length(size_nereo_fit$meta$site_levels))
  expect_named(site, c("site", "estimate", "lower", "upper"))
  expect_equal(attr(site, "kb_group_vars"), "site")
  expect_null(attr(site, "kb_predictor", exact = TRUE))
  expect_identical(attr(site, "kb_response"), "diameter")

  pop <- kb_predict_size_by(size_macro_fit)
  expect_equal(nrow(pop), 1L)
  sy <- kb_predict_size_by(size_macro_fit, by = c("site", "year"))
  expect_equal(nrow(sy), length(size_macro_fit$meta$site_year_levels))
})

test_that("kb_predict_size_by rejects a bad by and a weight fit", {
  expect_error(kb_predict_size_by(size_nereo_fit, by = "month"), "Invalid")
  expect_error(kb_predict_size_by(weight_fit), "must be a <kb_fit_size> object")
  expect_error(
    kb_predict_size_by(size_nereo_fit, diameter = 30),
    class = "rlib_error_dots_nonempty"
  )
})
