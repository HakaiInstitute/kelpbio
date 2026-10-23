survey <- function(...) {
  data.frame(
    survey_id = c("s1", "s2", "s3"),
    site = c("a", "a", "b"),
    year = "2021",
    survey_area_m2 = 120,
    plants = c(10, 0, 4),
    plot_area_m2 = c(200, NA, 210),
    canopy_area_m2 = c(50, NA, 0),
    canopy_tide_height_m = c(0.8, NA, 1.1),
    ...
  )
}
size_census <- function() {
  data.frame(survey_id = "s1", fronds = c(3, 12), partial = c(FALSE, TRUE))
}
census <- function() survey()[setdiff(names(survey()), "plants")]

test_that("valid survey data pass, alone and with a size census", {
  expect_silent(kb_check_data_in_situ(survey()))
  expect_identical(kb_check_data_in_situ(survey()), survey())
  expect_silent(kb_check_data_in_situ(census(), size_census()))
  expect_silent(kb_check_data_in_situ(survey()[c("survey_id", "site", "year", "survey_area_m2", "plants")]))
})

test_that("a table with no rows errors", {
  expect_snapshot(kb_check_data_in_situ(survey()[0, ]), error = TRUE)
})

test_that("year and survey_id may be numeric", {
  expect_silent(kb_check_data_in_situ(transform(survey(), year = 2021, survey_id = 1:3)))
  expect_snapshot(kb_check_data_in_situ(transform(survey(), year = 2021.5)), error = TRUE)
  expect_error(kb_check_data_in_situ(transform(survey(), year = c(2021, NA, 2021))), "year")
  expect_error(kb_check_data_in_situ(transform(survey(), survey_id = TRUE)), "survey_id")
})

test_that("a date without a year errors naming year", {
  dated <- transform(survey(), date = as.Date("2021-08-01"))
  expect_error(kb_check_data_in_situ(dated[setdiff(names(dated), "year")]), "year")
})

test_that("counts must come from one place", {
  expect_snapshot(kb_check_data_in_situ(survey(), size_census()), error = TRUE)
  expect_error(kb_check_data_in_situ(census()), "plants")
})

test_that("repeated survey ids and unmatched plants error", {
  expect_snapshot(kb_check_data_in_situ(rbind(survey(), survey()[1, ])), error = TRUE)
  p <- size_census()
  p$survey_id[1] <- "s9"
  expect_snapshot(kb_check_data_in_situ(census(), p), error = TRUE)
})

test_that("repeat surveys in a site-year pass", {
  expect_silent(kb_check_data_in_situ(transform(survey(), site = "a")))
})

test_that("the drone columns are given together", {
  expect_snapshot(
    kb_check_data_in_situ(transform(survey(), canopy_tide_height_m = c(0.8, NA, NA))),
    error = TRUE
  )
  expect_error(kb_check_data_in_situ(survey()[setdiff(names(survey()), "plot_area_m2")]), "plot_area_m2")
  expect_error(kb_check_data_in_situ(transform(survey(), canopy_area_m2 = c(300, NA, 0))), "canopy_area_m2")
})

test_that("a surveyed area above the plot area warns", {
  expect_warning(kb_check_data_in_situ(transform(survey(), survey_area_m2 = 250)), "survey_area_m2")
})

test_that("a size census without a size column errors", {
  expect_error(kb_check_data_in_situ(census(), size_census()["survey_id"]), "diameter_mm")
})

test_that("numeric and text survey ids compare by the same text", {
  numbered <- transform(census(), survey_id = c(100000, 2, 3))
  expect_silent(kb_check_data_in_situ(numbered, data.frame(survey_id = "100000", fronds = 3)))
  long <- transform(survey(), survey_id = c(1234567890123456, 1234567890123457, 1))
  expect_silent(kb_check_data_in_situ(long))
})
