test_that("valid nereo density data passes invisibly, including zero counts", {
  data <- data.frame(
    stipes = c(12L, 0L),
    area_m2 = c(40, 20),
    site = factor(c("a", "b")),
    year = factor(c("2020", "2021"))
  )
  expect_silent(kb_check_data_density_nereo(data))
  expect_identical(kb_check_data_density_nereo(data), data)
})

test_that("missing columns, bad counts, and bad areas error", {
  good <- data.frame(
    stipes = 5L,
    area_m2 = 40,
    site = factor("a"),
    year = factor("2020")
  )
  expect_snapshot(
    kb_check_data_density_nereo(good[c("area_m2", "site", "year")]),
    error = TRUE
  )
  bad <- good
  bad$stipes <- 2.5
  expect_snapshot(kb_check_data_density_nereo(bad), error = TRUE)
  bad$stipes <- -1
  expect_snapshot(kb_check_data_density_nereo(bad), error = TRUE)
  bad <- good
  bad$area_m2 <- 0
  expect_snapshot(kb_check_data_density_nereo(bad), error = TRUE)
  bad$area_m2 <- NA_real_
  expect_error(kb_check_data_density_nereo(bad), "missing")
})

test_that("an area in the wrong unit warns", {
  data <- data.frame(
    stipes = c(12L, 3L),
    area_m2 = c(4e5, 2e5),
    site = factor(c("a", "b")),
    year = factor(c("2020", "2021"))
  )
  expect_warning(kb_check_data_density_nereo(data), "area_m2")
})
