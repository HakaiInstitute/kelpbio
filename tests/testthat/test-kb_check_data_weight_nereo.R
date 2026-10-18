test_that("valid weight data passes invisibly", {
  data <- data.frame(
    diameter_mm = c(20, 35),
    weight_kg = c(0.5, 2),
    site = factor(c("a", "b")),
    date = as.Date(c("2020-08-01", "2021-08-01"))
  )
  expect_silent(kb_check_data_weight_nereo(data))
  expect_identical(kb_check_data_weight_nereo(data), data)
})

test_that("character site is accepted", {
  data <- data.frame(
    diameter_mm = 20,
    weight_kg = 0.5,
    site = "a",
    date = as.Date("2020-08-01"),
    stringsAsFactors = FALSE
  )
  expect_silent(kb_check_data_weight_nereo(data))
})

test_that("unsuffixed column names error naming the suffixed column", {
  data <- data.frame(
    diameter = 20,
    weight = 0.5,
    site = factor("a"),
    date = as.Date("2020-08-01")
  )
  expect_error(kb_check_data_weight_nereo(data), "diameter_mm")
})

test_that("missing, mistyped, and impossible values error", {
  good <- data.frame(
    diameter_mm = 20,
    weight_kg = 0.5,
    site = factor("a"),
    date = as.Date("2020-08-01")
  )
  expect_snapshot(
    kb_check_data_weight_nereo(good[c("weight_kg", "site", "date")]),
    error = TRUE
  )
  bad_type <- good
  bad_type$diameter_mm <- "x"
  expect_snapshot(kb_check_data_weight_nereo(bad_type), error = TRUE)
  bad_value <- good
  bad_value$weight_kg <- -1
  expect_snapshot(kb_check_data_weight_nereo(bad_value), error = TRUE)

  na_diameter <- good
  na_diameter$diameter_mm <- NA_real_
  expect_error(kb_check_data_weight_nereo(na_diameter), "missing")
  na_weight <- good
  na_weight$weight_kg <- NA_real_
  expect_error(kb_check_data_weight_nereo(na_weight), "missing")
  numeric_site <- good
  numeric_site$site <- 1
  expect_error(kb_check_data_weight_nereo(numeric_site))
  zero_weight <- good
  zero_weight$weight_kg <- 0 # boundary: weight must be > 0
  expect_error(kb_check_data_weight_nereo(zero_weight))
})

test_that("data in the wrong unit warn but still pass", {
  data <- data_weight_sim_nereo
  data$diameter_mm <- data$diameter_mm / 10
  expect_warning(out <- kb_check_data_weight_nereo(data), "millimetres")
  expect_identical(out, data)
})

test_that("x_name must be a string", {
  expect_error(kb_check_data_weight_nereo(data.frame(), x_name = 1), "x_name")
})

test_that("a date given as text or a contradicting year errors", {
  good <- data_weight_sim_nereo[1:2, ]
  expect_error(kb_check_data_weight_nereo(transform(good, date = as.character(date))), "Date")
  expect_error(kb_check_data_weight_nereo(transform(good, year = "1999")), "year")
  expect_silent(kb_check_data_weight_nereo(transform(good, year = format(date, "%Y"))))
})
