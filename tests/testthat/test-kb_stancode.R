test_that("kb_stancode returns the Stan source with comments stripped", {
  code <- kb_stancode(weight_fit)
  expect_type(code, "character")
  expect_match(code, "bWeight")
  # comments are stripped; the raw source on the fit keeps them
  expect_false(grepl("//", as.character(code)))
  expect_true(grepl("//", as.character(weight_fit$meta$stancode)))
})

test_that("kb_stancode is a kb_stancode object that prints readably", {
  code <- kb_stancode(weight_fit)
  expect_s3_class(code, "kb_stancode")
  # prints the source with real line breaks, not an escaped one-liner
  expect_output(print(code), "data \\{")
})
