test_that("standardised_density resolves supplied, then recorded, then mean", {
  levels <- c("a:2020" = 4, "b:2020" = 8)
  grid <- data.frame(
    site = c("a", "a", "b", "z"),
    year = c("2020", "2020", "2021", "2020"),
    stipes_m2 = c(6, NA, NA, NA)
  )
  z <- standardised_density(grid, TRUE, mean = 5, sd = 2, levels = levels)
  # supplied 6; recorded a:2020 = 4; b:2021 and z:2020 unrecorded -> mean
  expect_equal(z, c(0.5, -0.5, 0, 0))
})

test_that("standardised_density without grouping columns uses supplied or mean", {
  grid <- data.frame(diameter_mm = c(30, 40), stipes_m2 = c(9, NA))
  z <- standardised_density(grid, TRUE, 5, 2, c("a:2020" = 4))
  expect_equal(z, c(2, 0))
  expect_equal(
    standardised_density(data.frame(diameter_mm = 30), TRUE, 5, 2, numeric(0)),
    0
  )
})

test_that("standardised_density is zero when the term is off", {
  grid <- data.frame(stipes_m2 = c(1, 100))
  expect_equal(standardised_density(grid, FALSE, NA, NA, numeric(0)), c(0, 0))
})
