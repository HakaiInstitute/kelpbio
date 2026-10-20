test_that("valid nereo size data passes invisibly", {
  data <- data.frame(
    diameter_mm = c(22, 41),
    site = factor(c("a", "b")),
    date = as.Date(c("2020-08-01", "2021-08-01"))
  )
  expect_silent(kb_check_data_size_nereo(data))
  expect_identical(kb_check_data_size_nereo(data), data)
})

test_that("missing, mistyped, and impossible values error", {
  good <- data.frame(diameter_mm = 30, site = factor("a"), date = as.Date("2020-08-01"))
  expect_snapshot(
    kb_check_data_size_nereo(good[c("site", "date")]),
    error = TRUE
  )
  bad <- good
  bad$diameter_mm <- -1
  expect_snapshot(kb_check_data_size_nereo(bad), error = TRUE)
  bad$diameter_mm <- NA_real_
  expect_error(kb_check_data_size_nereo(bad), "missing")
  bad <- good
  bad$site <- 1
  expect_error(kb_check_data_size_nereo(bad))
})

test_that("diameter in centimetres warns but still passes", {
  data <- data_size_sim_nereo
  data$diameter_mm <- data$diameter_mm / 10
  expect_warning(out <- kb_check_data_size_nereo(data), "millimetres")
  expect_identical(out, data)
})

test_that("x_name must be a string", {
  expect_error(kb_check_data_size_nereo(data.frame(), x_name = 1), "x_name")
})

test_that("a date given as text or a contradicting year errors", {
  good <- data_size_sim_nereo[1:2, ]
  expect_error(kb_check_data_size_nereo(transform(good, date = as.character(date))), "Date")
  expect_error(kb_check_data_size_nereo(transform(good, year = "1999")), "year")
  expect_silent(kb_check_data_size_nereo(transform(good, year = format(date, "%Y"))))
})

test_that("plot_id is optional, and checked when present", {
  good <- data_size_sim_nereo[1:2, ]
  expect_silent(kb_check_data_size_nereo(good[setdiff(names(good), "plot_id")]))
  expect_error(kb_check_data_size_nereo(transform(good, plot_id = NA)), "plot_id")
})
