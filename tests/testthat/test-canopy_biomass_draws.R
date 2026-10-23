test_that("a survey's total is the bed biomass per m2 times its canopy area", {
  fit <- cover_calibration_nereo_fit
  grid <- tibble::tibble(
    site = fitted_sites(fit),
    year = "2019",
    canopy_area_m2 = 250,
    tide_height_m = 0,
    classified_area_m2 = 1e6
  )
  totals <- canopy_biomass_draws(fit, grid, "average", NULL)
  d <- fit$draws
  bed <- d$biomass_floor + d$cover_slope * exp(d$site_effect[1] + d$year_effect[1])
  expect_equal(
    totals[, 1],
    as.vector(posterior::draws_of(bed)) * 250,
    ignore_attr = TRUE
  )
})

test_that("the canopy is divided by one minus each draw's tide share", {
  fit <- cover_calibration_nereo_fit
  grid <- tibble::tibble(
    site = fitted_sites(fit),
    year = "2019",
    canopy_area_m2 = 100,
    tide_height_m = c(0, 1),
    classified_area_m2 = 1e6
  )
  totals <- canopy_biomass_draws(fit, grid, "average", NULL)
  tide <- as.vector(posterior::draws_of(fit$draws$tide_height_slope))
  expect_equal(totals[, 2], totals[, 1] / (1 - tide))
})

test_that("totals scale with canopy area, and the classified area caps the canopy", {
  fit <- cover_calibration_macro_fit
  grid <- tibble::tibble(
    site = fitted_sites(fit, 2)[2],
    year = "2020",
    canopy_area_m2 = c(100, 300, 300),
    tide_height_m = 1,
    classified_area_m2 = c(1e4, 1e4, 300)
  )
  totals <- canopy_biomass_draws(fit, grid, "average", NULL)
  expect_equal(totals[, 2], 3 * totals[, 1])
  # 300 m2 of canopy, corrected upwards for the tide, is capped at the 300 m2
  # classified: the bed biomass per m2 times 300.
  untided <- canopy_biomass_draws(
    fit,
    transform(grid[3, ], tide_height_m = 0),
    "average",
    NULL
  )
  expect_equal(totals[, 3], untided[, 1])
})
