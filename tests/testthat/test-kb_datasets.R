test_that("kb_datasets() describes every dataset of the data dictionary", {
  out <- kb_datasets()
  expect_s3_class(out, "tbl_df")
  expect_named(out, c("dataset", "row"))
  expect_identical(out$dataset, unique(kb_data_columns()$dataset))
  expect_false(anyNA(out$row))
})

test_that("kb_datasets() returns one dataset", {
  out <- kb_datasets("survey_canopy")
  expect_identical(nrow(out), 1L)
  expect_identical(out$dataset, "survey_canopy")
  expect_error(kb_datasets("canopy"), "dataset")
})
