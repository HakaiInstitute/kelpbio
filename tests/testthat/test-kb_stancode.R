test_that("kb_stancode returns the Stan source with comments stripped", {
  code <- kb_stancode(weight_nereo_fit)
  expect_type(code, "character")
  expect_match(code, "intercept")
  expect_false(grepl("//", as.character(code)))
  expect_true(grepl("//", as.character(weight_nereo_fit$meta$stancode)))
})

test_that("kb_stancode is a kb_stancode object that prints readably", {
  code <- kb_stancode(weight_nereo_fit)
  expect_s3_class(code, "kb_stancode")
  # Real line breaks, not an escaped one-liner.
  expect_output(print(code), "data \\{")
})

test_that("kb_stancode errors on an object that is not a fit", {
  expect_error(kb_stancode(1), "must be a <kb_fit> object")
  expect_equal(rlang::catch_cnd(kb_stancode(1))$call, quote(kb_stancode(1)))
})
