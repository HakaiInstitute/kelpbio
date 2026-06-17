test_that("release_questions() works", {
  # jarl-ignore internal_function: testing an internal package helper
  expect_message(kelpbio:::release_questions())
})
