test_that("representative_sites gives a vector to every fit", {
  expect_identical(representative_sites("a"), list(weight = "a", size = "a"))
  expect_identical(representative_sites(NULL), list(weight = NULL, size = NULL))
})

test_that("representative_sites gives each fit its own list element", {
  expect_identical(
    representative_sites(list(weight = "a")),
    list(weight = "a", size = NULL)
  )
  expect_identical(
    representative_sites(list(size = "b", weight = "a")),
    list(weight = "a", size = "b")
  )
  expect_identical(representative_sites(list(weight = "a"), "weight"), list(weight = "a"))
})
