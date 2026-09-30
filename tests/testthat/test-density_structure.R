density_data <- function(density) {
  data.frame(
    site = c("a", "a", "b", "b", "c"),
    year = c("2020", "2020", "2020", "2021", "2021"),
    density = density
  )
}

test_that("no density column leaves the term off", {
  s <- density_structure(density_data(1)[, c("site", "year")])
  expect_false(s$has_column)
  expect_false(s$on)
  expect_length(s$levels, 0L)
})

test_that("an all-NA column or a single distinct value leaves the term off", {
  expect_false(density_structure(density_data(NA))$on)
  expect_false(density_structure(density_data(c(3, 3, 3, NA, NA)))$on)
})

test_that("recorded density is keyed by site-year and standardised over rows", {
  # a:2020 = 2 (row NA takes the recorded value), b:2020 = 4, b:2021 = 6,
  # c:2021 unrecorded
  s <- density_structure(density_data(c(2, NA, 4, 6, NA)))
  expect_true(s$on)
  expect_equal(s$levels, c("a:2020" = 2, "b:2020" = 4, "b:2021" = 6))
  expect_identical(s$n_unrecorded, 1L)
  # rows: 2, 2, 4, 6 (the c:2021 row has none)
  expect_equal(s$mean, mean(c(2, 2, 4, 6)))
  expect_equal(s$sd, stats::sd(c(2, 2, 4, 6)))
})

test_that("zero-row data leaves the term off", {
  expect_false(density_structure(density_data(1)[0, ])$on)
})

test_that("notify_density reports an omitted term and unrecorded site-years", {
  expect_snapshot(notify_density(density_structure(density_data(NA))))
  expect_snapshot(
    notify_density(density_structure(density_data(c(2, NA, 4, 6, NA))))
  )
})

test_that("notify_density is silent without a column or with progress none", {
  no_col <- density_structure(density_data(1)[, c("site", "year")])
  expect_silent(notify_density(no_col))
  partial <- density_structure(density_data(c(2, NA, 4, 6, NA)))
  expect_silent(notify_density(partial, progress = "none"))
  complete <- density_structure(density_data(c(2, 2, 4, 6, 8)))
  expect_silent(notify_density(complete))
})
