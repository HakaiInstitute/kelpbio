test_that("ids_as_character converts numeric year and survey_id", {
  d <- data.frame(site = 1, year = c(2021, 2022), survey_id = c(100000, 2.5))
  out <- ids_as_character(d)
  expect_identical(out$year, c("2021", "2022"))
  expect_identical(out$survey_id, c("100000", "2.5"))
  expect_identical(out$site, c(1, 1))
})

test_that("ids_as_character keeps character and factor columns", {
  d <- data.frame(year = factor("2021"), survey_id = "s1")
  expect_identical(ids_as_character(d), d)
})
