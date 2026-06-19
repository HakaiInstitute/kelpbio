test_that("summary returns a classed object with a coefficient table", {
  s <- summary(weight_fit)
  expect_s3_class(s, "summary_kb_fit")
  expect_s3_class(s$coefficients, "tbl_df")
  expect_named(s$coefficients, c("term", "estimate", "lower", "upper"))
})

test_that("print.summary_kb_fit shows the metadata header", {
  expect_output(print(summary(weight_fit)), "summary_kb_fit")
})
