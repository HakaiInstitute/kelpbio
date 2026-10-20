survey <- function(...) {
  data.frame(
    site = c("a", "a", "b"),
    plot_id = c("1", "2", "1"),
    date = as.Date(c("2021-08-01", "2021-08-01", "2021-08-03")),
    survey_area_m2 = 120,
    plants = c(10, 0, 4),
    plot_area_m2 = c(200, NA, 210),
    canopy_area_m2 = c(50, NA, 0),
    tide_height_m = c(0.8, NA, 1.1),
    ...
  )
}
plants <- function() {
  data.frame(
    site = "a", plot_id = "1", date = as.Date("2021-08-01"),
    fronds = c(3, 12), partial = c(FALSE, TRUE)
  )
}
census <- function() survey()[setdiff(names(survey()), "plants")]

test_that("valid survey data pass, alone and with a plant table", {
  expect_silent(kb_check_data_survey(survey()))
  expect_identical(kb_check_data_survey(survey()), survey())
  expect_silent(kb_check_data_survey(census(), plants()))
  expect_silent(kb_check_data_survey(survey(year = "2021")))
  expect_silent(kb_check_data_survey(survey()[c("site", "plot_id", "date", "survey_area_m2", "plants")]))
})

test_that("a table with no rows errors", {
  expect_snapshot(kb_check_data_survey(survey()[0, ]), error = TRUE)
})

test_that("a bad or contradicting date errors", {
  expect_snapshot(kb_check_data_survey(transform(survey(), date = "2021-08-01")), error = TRUE)
  expect_snapshot(kb_check_data_survey(survey(year = "2020")), error = TRUE)
  bad <- survey()
  bad$date[1] <- NA
  expect_error(kb_check_data_survey(bad), "date")
})

test_that("counts must come from one place", {
  expect_snapshot(kb_check_data_survey(survey(), plants()), error = TRUE)
  expect_error(kb_check_data_survey(census()), "plants")
})

test_that("repeated surveys and unmatched plants error", {
  expect_snapshot(kb_check_data_survey(rbind(survey(), survey()[1, ])), error = TRUE)
  p <- plants()
  p$plot_id[1] <- "9"
  expect_snapshot(kb_check_data_survey(census(), p), error = TRUE)
})

test_that("the drone columns are given together", {
  expect_snapshot(
    kb_check_data_survey(transform(survey(), tide_height_m = c(0.8, NA, NA))),
    error = TRUE
  )
  expect_error(kb_check_data_survey(survey()[setdiff(names(survey()), "plot_area_m2")]), "plot_area_m2")
  expect_error(kb_check_data_survey(transform(survey(), canopy_area_m2 = c(300, NA, 0))), "canopy_area_m2")
})

test_that("a surveyed area above the plot area warns", {
  expect_warning(kb_check_data_survey(transform(survey(), survey_area_m2 = 250)), "survey_area_m2")
})

test_that("a plant table without a size column errors", {
  expect_error(kb_check_data_survey(census(), plants()[c("site", "plot_id", "date")]), "diameter_mm")
})
