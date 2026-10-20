size_census <- function(...) {
  data.frame(
    survey_id = "s1",
    fronds = c(3, 12), partial = c(FALSE, TRUE), ...
  )
}

test_that("valid macro size census passes invisibly", {
  expect_silent(kb_check_data_size_census_macro(size_census()))
  expect_identical(kb_check_data_size_census_macro(size_census()), size_census())
  expect_silent(kb_check_data_size_census_macro(size_census()[setdiff(names(size_census()), "partial")]))
})

test_that("bad columns error naming them", {
  expect_error(kb_check_data_size_census_macro(size_census()[setdiff(names(size_census()), "fronds")]), "fronds")
  expect_error(kb_check_data_size_census_macro(transform(size_census(), fronds = -1)), "fronds")
  expect_error(kb_check_data_size_census_macro(transform(size_census(), partial = c(NA, TRUE))), "partial")
  expect_error(kb_check_data_size_census_macro(size_census()[setdiff(names(size_census()), "survey_id")]), "survey_id")
  expect_error(kb_check_data_size_census_macro(transform(size_census(), survey_id = c(NA, "s1"))), "survey_id")
  expect_silent(kb_check_data_size_census_macro(transform(size_census(), survey_id = 7)))
})

test_that("a plant with no frond at 1 m errors", {
  expect_snapshot(kb_check_data_size_census_macro(transform(size_census(), fronds = c(0, 3))), error = TRUE)
  expect_error(kb_check_data_size_census_macro(transform(size_census(), fronds = c(2.5, 3))), "fronds")
})
