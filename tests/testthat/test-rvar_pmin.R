test_that("rvar_pmin matches pmin on numbers", {
  a <- c(1, 5, -2, 3)
  b <- c(2, 4, -2, 0)
  expect_equal(rvar_pmin(a, b), pmin(a, b))
})

test_that("rvar_pmin takes an rvar, draw by draw", {
  out <- rvar_pmin(posterior::rvar(c(60, 120)), 100)
  expect_equal(posterior::draws_of(out)[, 1], c(60, 100), ignore_attr = TRUE)
})
