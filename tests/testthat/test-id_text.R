test_that("id_text writes whole numbers in full", {
  expect_identical(id_text(c(100000, 2021, 1234567890123456)), c("100000", "2021", "1234567890123456"))
  expect_identical(id_text(c(2.5, NA)), c("2.5", NA))
})

test_that("id_text keeps text and factor levels", {
  expect_identical(id_text(factor(c("b", "a"))), c("b", "a"))
  expect_identical(id_text("1e+05"), "1e+05")
})
