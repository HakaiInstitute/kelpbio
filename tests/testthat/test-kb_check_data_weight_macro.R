test_that("valid macro weight data passes invisibly", {
  data <- data.frame(
    fronds = c(3L, 8L),
    weight = c(0.4, 1.7),
    site = factor(c("a", "b")),
    year = factor(c("2020", "2021"))
  )
  expect_silent(kb_check_data_weight_macro(data))
  expect_identical(kb_check_data_weight_macro(data), data)
})

test_that("character site/year is accepted", {
  data <- data.frame(
    fronds = 5L,
    weight = 0.9,
    site = "a",
    year = "2020",
    stringsAsFactors = FALSE
  )
  expect_silent(kb_check_data_weight_macro(data))
})

test_that("missing, mistyped, and impossible values error", {
  good <- data.frame(
    fronds = 5L,
    weight = 0.9,
    site = factor("a"),
    year = factor("2020")
  )
  # distinct cli messages (missing column, wrong type, non-positive) snapshotted
  expect_snapshot(
    kb_check_data_weight_macro(good[c("weight", "site", "year")]),
    error = TRUE
  )
  bad_type <- good
  bad_type$fronds <- "x"
  expect_snapshot(kb_check_data_weight_macro(bad_type), error = TRUE)
  bad_value <- good
  bad_value$weight <- -1
  expect_snapshot(kb_check_data_weight_macro(bad_value), error = TRUE)

  # fronds must be a whole number (a count)
  frac_fronds <- good
  frac_fronds$fronds <- 5.5
  expect_snapshot(kb_check_data_weight_macro(frac_fronds), error = TRUE)

  # remaining abort branches (message keyword only)
  na_fronds <- good
  na_fronds$fronds <- NA_real_
  expect_error(kb_check_data_weight_macro(na_fronds), "missing")
  na_weight <- good
  na_weight$weight <- NA_real_
  expect_error(kb_check_data_weight_macro(na_weight), "missing")
  numeric_site <- good
  numeric_site$site <- 1
  expect_error(kb_check_data_weight_macro(numeric_site))
  zero_fronds <- good
  zero_fronds$fronds <- 0 # boundary: fronds must be > 0
  expect_error(kb_check_data_weight_macro(zero_fronds))
})
