test_that("valid weight data passes invisibly", {
  data <- data.frame(
    diameter_mm = c(20, 35), weight_kg = c(0.5, 2),
    site = factor(c("a", "b")), year = factor(c("2020", "2021"))
  )
  expect_silent(kb_check_data_weight(data))
  expect_identical(kb_check_data_weight(data), data)
})

test_that("character site/year is accepted", {
  data <- data.frame(
    diameter_mm = 20, weight_kg = 0.5, site = "a", year = "2020",
    stringsAsFactors = FALSE
  )
  expect_silent(kb_check_data_weight(data))
})

test_that("missing, mistyped, and impossible values error via cli", {
  good <- data.frame(
    diameter_mm = 20, weight_kg = 0.5, site = factor("a"), year = factor("2020")
  )
  expect_snapshot(kb_check_data_weight(good[c("weight_kg", "site", "year")]), error = TRUE)

  bad_type <- good
  bad_type$diameter_mm <- "x"
  expect_snapshot(kb_check_data_weight(bad_type), error = TRUE)

  bad_value <- good
  bad_value$weight_kg <- -1
  expect_snapshot(kb_check_data_weight(bad_value), error = TRUE)
})
