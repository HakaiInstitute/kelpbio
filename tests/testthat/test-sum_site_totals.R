grid <- tibble::tibble(
  site = c("a", "b", "c"),
  year = "2020",
  region = factor(c("south", "north", "south"), levels = c("south", "north"))
)
totals <- matrix(1:6, nrow = 2)

test_that("totals are summed on each draw within groups", {
  res <- sum_site_totals(grid, totals, "region")
  expect_identical(as.character(res$groups$region), c("south", "north"))
  expect_equal(res$draws, cbind(c(1, 2) + c(5, 6), c(3, 4)), ignore_attr = TRUE)
})

test_that("character(0) sums every row", {
  res <- sum_site_totals(grid, totals, character(0))
  expect_equal(nrow(res$groups), 1L)
  expect_equal(as.vector(res$draws), c(9, 12))
})

test_that("character groups are ordered alphabetically", {
  res <- sum_site_totals(transform(grid, region = as.character(region)), totals, "region")
  expect_identical(res$groups$region, c("north", "south"))
})

test_that("a group holding one site-year twice warns", {
  twice <- tibble::tibble(site = c("a", "a"), year = "2020", region = "north")
  expect_warning(
    sum_site_totals(twice, matrix(1:4, nrow = 2), "region"),
    "overlap"
  )
  apart <- transform(twice, region = c("north", "south"))
  expect_no_warning(sum_site_totals(apart, matrix(1:4, nrow = 2), "region"))
})
