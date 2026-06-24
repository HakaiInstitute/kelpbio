test_that("kb_stancode returns the Stan source", {
  code <- kb_stancode(weight_fit)
  expect_type(code, "character")
  expect_match(code, "bWeight")
})

test_that("kb_stancode is a kb_stancode object that prints readably", {
  code <- kb_stancode(weight_fit)
  expect_s3_class(code, "kb_stancode")
  # prints the source with real line breaks, not an escaped one-liner
  expect_output(print(code), "data \\{")
  # as.character() recovers the plain string
  expect_identical(as.character(code), as.character(weight_fit$meta$stancode))
})
