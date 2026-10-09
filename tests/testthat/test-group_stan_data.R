test_that("group_stan_data codes site and year in factor level order", {
  data <- data.frame(site = c("b", "a", "b"), year = c("2020", "2019", "2019"))
  got <- group_stan_data(data)
  expect_identical(got$n_site, 2L)
  expect_identical(got$n_year, 2L)
  expect_identical(got$site, c(2L, 1L, 2L))
  expect_identical(got$year, c(2L, 1L, 1L))
})

test_that("zero-row data take one level of each", {
  got <- group_stan_data(data.frame(site = character(0), year = character(0)))
  expect_identical(got$n_site, 1L)
  expect_identical(got$n_year, 1L)
  expect_length(got$site, 0)
})

test_that("unused factor levels are not coded, and level order is kept", {
  data <- data.frame(
    site = factor(c("b", "a"), levels = c("b", "a", "z")),
    year = factor(c("2020", "2021"), levels = c("2019", "2020", "2021"))
  )
  got <- group_stan_data(data)
  expect_identical(got$n_site, 2L)
  expect_identical(got$n_year, 2L)
  expect_identical(got$site, c(1L, 2L))
  expect_identical(got$year, c(1L, 2L))
})
