test_that("valid nereo size data passes invisibly", {
  data <- data.frame(
    diameter = c(22, 41),
    site = factor(c("a", "b")),
    year = factor(c("2020", "2021"))
  )
  expect_silent(kb_check_data_size_nereo(data))
  expect_identical(kb_check_data_size_nereo(data), data)
})

test_that("missing, mistyped, and impossible values error", {
  good <- data.frame(diameter = 30, site = factor("a"), year = factor("2020"))
  expect_snapshot(
    kb_check_data_size_nereo(good[c("site", "year")]),
    error = TRUE
  )
  bad <- good
  bad$diameter <- -1
  expect_snapshot(kb_check_data_size_nereo(bad), error = TRUE)
  bad$diameter <- NA_real_
  expect_error(kb_check_data_size_nereo(bad), "missing")
  bad <- good
  bad$site <- 1
  expect_error(kb_check_data_size_nereo(bad))
})

test_that("diameter in centimetres warns but still passes", {
  data <- data_size_sim_nereo
  data$diameter <- data$diameter / 10
  expect_warning(out <- kb_check_data_size_nereo(data), "millimetres")
  expect_identical(out, data)
})
