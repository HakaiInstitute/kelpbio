canopy <- function(...) {
  data.frame(
    site = c("a", "a", "b"),
    year = c("2021", "2021", "2022"),
    canopy_area_m2 = c(1200, 0, 800),
    tide_height_m = c(0.4, 1.1, 0.8),
    classified_area_m2 = c(5000, 5000, 3000),
    ...
  )
}

test_that("valid canopy maps pass silently and are returned", {
  expect_silent(kb_check_data_canopy(canopy()))
  expect_identical(kb_check_data_canopy(canopy()), canopy())
  expect_silent(kb_check_data_canopy(transform(canopy(), year = 2021)))
  expect_silent(kb_check_data_canopy(canopy(region = "north")))
})

test_that("the simulated canopy maps pass", {
  expect_silent(kb_check_data_canopy(data_canopy_sim_nereo))
  expect_silent(kb_check_data_canopy(data_canopy_sim_macro))
})

test_that("a canopy larger than its classified area errors", {
  maps <- transform(canopy(), canopy_area_m2 = 6000)
  expect_snapshot(kb_check_data_canopy(maps), error = TRUE)
})

test_that("a missing or invalid column errors naming it", {
  for (col in c("site", "year", "canopy_area_m2", "tide_height_m", "classified_area_m2")) {
    expect_error(kb_check_data_canopy(canopy()[setdiff(names(canopy()), col)]), col)
  }
  expect_error(kb_check_data_canopy(transform(canopy(), canopy_area_m2 = -1)), "canopy_area_m2")
  expect_error(kb_check_data_canopy(transform(canopy(), tide_height_m = NA)), "tide_height_m")
  expect_error(kb_check_data_canopy(transform(canopy(), classified_area_m2 = 0)), "classified_area_m2")
  expect_error(kb_check_data_canopy(transform(canopy(), year = 2021.5)), "year")
})

test_that("errors name the data", {
  maps <- transform(canopy(), canopy_area_m2 = 6000)
  expect_error(kb_check_data_canopy(maps), "`maps`")
  expect_error(kb_check_data_canopy(maps, x_name = "`canopy sheet`"), "canopy sheet")
})

test_that("implausible units and ambiguous group names warn", {
  expect_warning(
    kb_check_data_canopy(transform(canopy(), tide_height_m = c(40, 110, 80))),
    "tide_height_m"
  )
  expect_warning(
    kb_check_data_canopy(transform(canopy(), site = c("a,b", "a,b", "c"))),
    "comma"
  )
})

test_that("it applies the check kb_predict_biomass_canopy() applies", {
  bad <- transform(data_canopy_sim_nereo, canopy_area_m2 = classified_area_m2 + 1)
  expect_error(kb_check_data_canopy(bad), "must not exceed")
  expect_error(
    kb_predict_biomass_canopy(fit_cover_calibration_sim_nereo, bad),
    "must not exceed"
  )
})
