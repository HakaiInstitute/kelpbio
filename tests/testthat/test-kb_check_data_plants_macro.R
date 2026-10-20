plants <- function(...) {
  data.frame(
    site = "a", plot_id = "1", date = as.Date("2021-08-01"),
    fronds = c(3, 12), partial = c(FALSE, TRUE), ...
  )
}

test_that("valid macro plant data pass invisibly", {
  expect_silent(kb_check_data_plants_macro(plants()))
  expect_identical(kb_check_data_plants_macro(plants()), plants())
  expect_silent(kb_check_data_plants_macro(plants()[setdiff(names(plants()), "partial")]))
})

test_that("bad columns error naming them", {
  expect_error(kb_check_data_plants_macro(plants()[setdiff(names(plants()), "fronds")]), "fronds")
  expect_error(kb_check_data_plants_macro(transform(plants(), fronds = -1)), "fronds")
  expect_error(kb_check_data_plants_macro(transform(plants(), partial = c(NA, TRUE))), "partial")
  expect_error(kb_check_data_plants_macro(transform(plants(), date = "2021-08-01")), "date")
})

test_that("a plant with no frond at 1 m errors", {
  expect_snapshot(kb_check_data_plants_macro(transform(plants(), fronds = c(0, 3))), error = TRUE)
  expect_error(kb_check_data_plants_macro(transform(plants(), fronds = c(2.5, 3))), "fronds")
})
