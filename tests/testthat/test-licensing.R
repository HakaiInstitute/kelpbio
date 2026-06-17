test_that("licensing_md works", {
  # jarl-ignore internal_function: testing an internal package helper
  expect_type(kelpbio:::licensing_md(), "character")
})
