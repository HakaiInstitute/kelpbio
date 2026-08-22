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

test_that("kb_stancode errors on an object that is not a fit", {
  # the message wording is pinned once in test-chk.R; what matters here is that
  # the verb rejects a non-fit and the condition names the verb, not the default
  expect_error(kb_stancode(1), "must be a <kb_fit> object")
  expect_equal(rlang::catch_cnd(kb_stancode(1))$call, quote(kb_stancode(1)))
})
