size_census <- function(...) {
  data.frame(
    survey_id = "s1",
    diameter_mm = c(32, 41), partial = c(FALSE, TRUE), ...
  )
}

test_that("valid nereo size census passes invisibly", {
  expect_silent(kb_check_data_size_census_nereo(size_census()))
  expect_identical(kb_check_data_size_census_nereo(size_census()), size_census())
  expect_silent(kb_check_data_size_census_nereo(size_census()[setdiff(names(size_census()), "partial")]))
})

test_that("bad columns error naming them", {
  expect_error(kb_check_data_size_census_nereo(size_census()[setdiff(names(size_census()), "diameter_mm")]), "diameter_mm")
  expect_error(kb_check_data_size_census_nereo(transform(size_census(), diameter_mm = -1)), "diameter_mm")
  expect_error(kb_check_data_size_census_nereo(transform(size_census(), partial = c(NA, TRUE))), "partial")
  expect_error(kb_check_data_size_census_nereo(size_census()[setdiff(names(size_census()), "survey_id")]), "survey_id")
  expect_error(kb_check_data_size_census_nereo(transform(size_census(), survey_id = c(NA, "s1"))), "survey_id")
  expect_silent(kb_check_data_size_census_nereo(transform(size_census(), survey_id = 7)))
})
