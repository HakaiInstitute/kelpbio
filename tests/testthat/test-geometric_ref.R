test_that("geometric_ref returns the geometric mean", {
  expect_equal(geometric_ref(c(20, 35, 50), fallback = 30), exp(mean(log(c(20, 35, 50)))))
})

test_that("geometric_ref returns the fallback for zero-row data", {
  expect_equal(geometric_ref(numeric(0), fallback = 30), 30)
})
