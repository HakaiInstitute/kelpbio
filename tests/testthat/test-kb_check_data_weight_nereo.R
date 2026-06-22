test_that("valid weight data passes invisibly", {
  data <- data.frame(
    diameter = c(20, 35), weight = c(0.5, 2),
    site = factor(c("a", "b")), year = factor(c("2020", "2021"))
  )
  expect_silent(kb_check_data_weight_nereo(data))
  expect_identical(kb_check_data_weight_nereo(data), data)
})

test_that("character site/year is accepted", {
  data <- data.frame(
    diameter = 20, weight = 0.5, site = "a", year = "2020",
    stringsAsFactors = FALSE
  )
  expect_silent(kb_check_data_weight_nereo(data))
})

test_that("missing, mistyped, and impossible values error via cli", {
  good <- data.frame(
    diameter = 20, weight = 0.5, site = factor("a"), year = factor("2020")
  )
  expect_snapshot(kb_check_data_weight_nereo(good[c("weight", "site", "year")]), error = TRUE)

  bad_type <- good
  bad_type$diameter <- "x"
  expect_snapshot(kb_check_data_weight_nereo(bad_type), error = TRUE)

  bad_value <- good
  bad_value$weight <- -1
  expect_snapshot(kb_check_data_weight_nereo(bad_value), error = TRUE)
})
