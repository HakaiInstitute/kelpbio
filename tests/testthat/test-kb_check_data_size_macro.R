test_that("valid macro size data passes invisibly", {
  data <- data.frame(
    fronds = c(3L, 12L),
    site = factor(c("a", "b")),
    year = factor(c("2020", "2021"))
  )
  expect_silent(kb_check_data_size_macro(data))
  expect_identical(kb_check_data_size_macro(data), data)
})

test_that("missing, fractional, and zero frond counts error", {
  good <- data.frame(fronds = 5L, site = factor("a"), year = factor("2020"))
  expect_snapshot(
    kb_check_data_size_macro(good[c("site", "year")]),
    error = TRUE
  )
  bad <- good
  bad$fronds <- 5.5
  expect_snapshot(kb_check_data_size_macro(bad), error = TRUE)
  # the model describes plants with at least one frond at 1 m
  bad$fronds <- 0
  expect_snapshot(kb_check_data_size_macro(bad), error = TRUE)
  bad$fronds <- -1
  expect_snapshot(kb_check_data_size_macro(bad), error = TRUE)
  bad$fronds <- NA_real_
  expect_error(kb_check_data_size_macro(bad), "missing")
})
