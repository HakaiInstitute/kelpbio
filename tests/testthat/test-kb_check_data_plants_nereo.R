plants <- function(...) {
  data.frame(
    site = "a", plot_id = "1", date = as.Date("2021-08-01"),
    diameter_mm = c(32, 41), partial = c(FALSE, TRUE), ...
  )
}

test_that("valid nereo plant data pass invisibly", {
  expect_silent(kb_check_data_plants_nereo(plants()))
  expect_identical(kb_check_data_plants_nereo(plants()), plants())
  expect_silent(kb_check_data_plants_nereo(plants()[setdiff(names(plants()), "partial")]))
})

test_that("bad columns error naming them", {
  expect_error(kb_check_data_plants_nereo(plants()[setdiff(names(plants()), "diameter_mm")]), "diameter_mm")
  expect_error(kb_check_data_plants_nereo(transform(plants(), diameter_mm = -1)), "diameter_mm")
  expect_error(kb_check_data_plants_nereo(transform(plants(), partial = c(NA, TRUE))), "partial")
  expect_error(kb_check_data_plants_nereo(transform(plants(), date = "2021-08-01")), "date")
})
