cover_data <- function() {
  data.frame(
    canopy_area_m2 = c(60, 0),
    plot_area_m2 = c(200, 210),
    tide_height_m = c(0.5, -0.2),
    site = c("a", "b"),
    year = factor(c("2020", "2021"))
  )
}

cover_biomass <- function() {
  data.frame(
    site = c("a", "b"),
    year = factor(c("2020", "2021")),
    estimate = c(2.8, 0.05),
    lower = c(1.2, 0.02),
    upper = c(6.1, 0.12)
  )
}

test_that("valid nereo cover biomass data passes invisibly, including zero canopy", {
  data <- cover_data()
  expect_silent(kb_check_data_cover_biomass_nereo(data))
  expect_silent(kb_check_data_cover_biomass_nereo(data, cover_biomass()))
  expect_identical(kb_check_data_cover_biomass_nereo(data, cover_biomass()), data)
})

test_that("extra columns of the surveys and of a prediction frame are ignored", {
  data <- cover_data()
  data$month <- c("July", "August")
  biomass <- cover_biomass()
  biomass$note <- "x"
  expect_silent(kb_check_data_cover_biomass_nereo(data, biomass))
})

test_that("missing or bad survey columns error", {
  good <- cover_data()
  expect_snapshot(
    kb_check_data_cover_biomass_nereo(good[setdiff(names(good), "tide_height_m")]),
    error = TRUE
  )
  bad <- good
  bad$canopy_area_m2[1] <- 250
  expect_snapshot(kb_check_data_cover_biomass_nereo(bad), error = TRUE)
  bad <- good
  bad$canopy_area_m2[1] <- -1
  expect_error(kb_check_data_cover_biomass_nereo(bad), "canopy_area_m2")
  bad <- good
  bad$plot_area_m2[1] <- 0
  expect_error(kb_check_data_cover_biomass_nereo(bad), "plot_area_m2")
  bad <- good
  bad$tide_height_m[1] <- NA
  expect_error(kb_check_data_cover_biomass_nereo(bad), "tide_height_m")
  bad <- good
  bad$site[1] <- NA
  expect_error(kb_check_data_cover_biomass_nereo(bad), "site")
})

test_that("a response in the survey data errors, pointing to biomass", {
  data <- cover_data()
  data$estimate <- 1
  expect_snapshot(kb_check_data_cover_biomass_nereo(data), error = TRUE)
})

test_that("bad biomass limits and repeated site-years error", {
  data <- cover_data()
  good <- cover_biomass()
  bad <- good
  bad$lower[1] <- 3
  expect_snapshot(kb_check_data_cover_biomass_nereo(data, bad), error = TRUE)
  bad <- good
  bad$upper[1] <- 2
  expect_error(kb_check_data_cover_biomass_nereo(data, bad), "upper")
  bad <- good
  bad[1, c("estimate", "lower", "upper")] <- 2
  expect_error(kb_check_data_cover_biomass_nereo(data, bad), "less than")
  bad <- good
  bad$estimate[1] <- 0
  expect_error(kb_check_data_cover_biomass_nereo(data, bad), "estimate")
  expect_snapshot(
    kb_check_data_cover_biomass_nereo(data, rbind(good, good[1, ])),
    error = TRUE
  )
  expect_error(kb_check_data_cover_biomass_nereo(data, good[c("site", "estimate")]), "year")
})

test_that("a dry or carbon biomass prediction errors", {
  data <- cover_data()
  dry <- new_kb_predictions(
    cover_biomass(),
    predictor = NULL,
    group_vars = c("site", "year"),
    response = "dry_biomass_kg_m2"
  )
  expect_snapshot(kb_check_data_cover_biomass_nereo(data, dry), error = TRUE)
})

test_that("a tide height in centimetres warns", {
  data <- cover_data()
  data$tide_height_m <- c(50, 120)
  expect_warning(kb_check_data_cover_biomass_nereo(data), "tide_height_m")
})
