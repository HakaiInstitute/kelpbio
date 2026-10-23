test_that("valid nereo size data passes invisibly", {
  data <- data.frame(
    diameter_mm = c(22, 41),
    site = factor(c("a", "b")),
    year = c("2020", "2021")
  )
  expect_silent(kb_check_data_size_sample_nereo(data))
  expect_identical(kb_check_data_size_sample_nereo(data), data)
})

test_that("missing, mistyped, and impossible values error", {
  good <- data.frame(diameter_mm = 30, site = factor("a"), year = "2020")
  expect_snapshot(
    kb_check_data_size_sample_nereo(good[c("site", "year")]),
    error = TRUE
  )
  bad <- good
  bad$diameter_mm <- -1
  expect_snapshot(kb_check_data_size_sample_nereo(bad), error = TRUE)
  bad$diameter_mm <- NA_real_
  expect_error(kb_check_data_size_sample_nereo(bad), "missing")
  bad <- good
  bad$site <- 1
  expect_error(kb_check_data_size_sample_nereo(bad))
  expect_error(kb_check_data_size_sample_nereo(transform(good, year = 2020.5)), "year")
})

test_that("diameter in centimetres warns but still passes", {
  data <- data_size_sample_sim_nereo
  data$diameter_mm <- data$diameter_mm / 10
  expect_warning(out <- kb_check_data_size_sample_nereo(data), "millimetres")
  expect_identical(out, data)
})

test_that("x_name must be a string", {
  expect_error(kb_check_data_size_sample_nereo(data.frame(), x_name = 1), "x_name")
})
