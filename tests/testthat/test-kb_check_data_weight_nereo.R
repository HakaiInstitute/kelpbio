test_that("valid weight data passes invisibly", {
  data <- data.frame(
    diameter = c(20, 35),
    weight = c(0.5, 2),
    site = factor(c("a", "b")),
    year = factor(c("2020", "2021"))
  )
  expect_silent(kb_check_data_weight_nereo(data))
  expect_identical(kb_check_data_weight_nereo(data), data)
})

test_that("character site/year is accepted", {
  data <- data.frame(
    diameter = 20,
    weight = 0.5,
    site = "a",
    year = "2020",
    stringsAsFactors = FALSE
  )
  expect_silent(kb_check_data_weight_nereo(data))
})

test_that("missing, mistyped, and impossible values error", {
  good <- data.frame(
    diameter = 20,
    weight = 0.5,
    site = factor("a"),
    year = factor("2020")
  )
  # distinct cli messages (missing column, wrong type, non-positive) snapshotted
  expect_snapshot(
    kb_check_data_weight_nereo(good[c("weight", "site", "year")]),
    error = TRUE
  )
  bad_type <- good
  bad_type$diameter <- "x"
  expect_snapshot(kb_check_data_weight_nereo(bad_type), error = TRUE)
  bad_value <- good
  bad_value$weight <- -1
  expect_snapshot(kb_check_data_weight_nereo(bad_value), error = TRUE)

  # remaining abort branches (message keyword only)
  na_diameter <- good
  na_diameter$diameter <- NA_real_
  expect_error(kb_check_data_weight_nereo(na_diameter), "missing")
  na_weight <- good
  na_weight$weight <- NA_real_
  expect_error(kb_check_data_weight_nereo(na_weight), "missing")
  numeric_site <- good
  numeric_site$site <- 1
  expect_error(kb_check_data_weight_nereo(numeric_site))
  zero_weight <- good
  zero_weight$weight <- 0 # boundary: weight must be > 0
  expect_error(kb_check_data_weight_nereo(zero_weight))
})

test_that("an optional density column is validated", {
  data <- data.frame(
    diameter = c(20, 35, 40),
    weight = c(0.5, 2, 3),
    site = c("a", "a", "b"),
    year = c("2020", "2020", "2020"),
    density = c(3, NA, 5)
  )
  expect_silent(kb_check_data_weight_nereo(data))
  data$density <- NA
  expect_silent(kb_check_data_weight_nereo(data))

  bad <- data
  bad$density <- c(3, -1, 5)
  expect_snapshot(error = TRUE, kb_check_data_weight_nereo(bad))
  bad$density <- c("3", "4", "5")
  expect_snapshot(error = TRUE, kb_check_data_weight_nereo(bad))
  # two values in one site-year
  bad$density <- c(3, 4, 5)
  expect_snapshot(error = TRUE, kb_check_data_weight_nereo(bad))
})

test_that("data in the wrong unit warn but still pass", {
  data <- data_weight_sim_nereo
  data$diameter <- data$diameter / 10
  expect_warning(out <- kb_check_data_weight_nereo(data), "millimetres")
  expect_identical(out, data)
})
