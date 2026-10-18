grid <- tibble::tibble(
  site = c("a", "b", "c"),
  year = "2020",
  region = factor(c("south", "north", "south"), levels = c("south", "north"))
)
draws <- matrix(1:6, nrow = 2)

test_that("draws are summed on each draw within groups", {
  res <- sum_draws_by(grid, draws, "region")
  expect_identical(as.character(res$groups$region), c("south", "north"))
  expect_identical(res$id, c(1L, 2L, 1L))
  expect_equal(res$draws, cbind(c(1, 2) + c(5, 6), c(3, 4)), ignore_attr = TRUE)
})

test_that("character(0) sums every row", {
  res <- sum_draws_by(grid, draws, character(0))
  expect_equal(nrow(res$groups), 1L)
  expect_equal(as.vector(res$draws), c(9, 12))
})

test_that("an area divides each sum by its group's summed area", {
  res <- sum_draws_by(grid, draws, "region", area = c(1, 2, 3))
  expect_equal(res$draws[, 1], (c(1, 2) + c(5, 6)) / 4)
  per_draw <- matrix(c(1, 2, 2, 2, 3, 2), nrow = 2)
  res <- sum_draws_by(grid, draws, "region", area = per_draw)
  expect_equal(res$draws[, 1], (c(1, 2) + c(5, 6)) / c(4, 4))
})

test_that("character groups are ordered alphabetically", {
  res <- sum_draws_by(transform(grid, region = as.character(region)), draws, "region")
  expect_identical(res$groups$region, c("north", "south"))
})

test_that("character groups sort alphabetically regardless of case", {
  mixed <- tibble::tibble(
    site = c("a", "b", "c", "d"),
    year = "2020",
    region = c("north", "South", "alpha", "Beta")
  )
  res <- sum_draws_by(mixed, matrix(1:8, nrow = 2), "region")
  expect_identical(res$groups$region, c("alpha", "Beta", "north", "South"))
})
