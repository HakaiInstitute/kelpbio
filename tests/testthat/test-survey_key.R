test_that("survey_key labels a survey by site, plot, and date", {
  expect_identical(
    survey_key(factor("a"), 1, as.Date("2021-08-01")),
    "a:1:2021-08-01"
  )
})
