test_that("measure_factor converts wet to dry, carbon, and nitrogen per draw", {
  ratio <- population_draws(wetdry_nereo_fit)
  expect_identical(measure_factor("wet", NULL, NULL, NULL), 1)
  expect_equal(measure_factor("dry", wetdry_nereo_fit, NULL, NULL), ratio)
  expect_equal(
    measure_factor("carbon", wetdry_nereo_fit, carbon_nereo_fit, NULL, element_scale = 1000),
    ratio * population_draws(carbon_nereo_fit) * 1000
  )
  expect_equal(
    measure_factor("nitrogen", wetdry_nereo_fit, NULL, nitrogen_nereo_fit, element_scale = 1000),
    ratio * population_draws(nitrogen_nereo_fit) * 1000
  )
})

test_that("population draws are the expected ratio per draw", {
  expect_equal(
    population_draws(carbon_nereo_fit),
    stats::plogis(as.vector(posterior::draws_of(carbon_nereo_fit$draws$intercept)))
  )
  expect_length(population_draws(wetdry_macro_fit), posterior::ndraws(wetdry_macro_fit$draws))
})

test_that("derived_response names the measure and the scale", {
  expect_identical(derived_response("wet", TRUE), "biomass_kg_m2")
  expect_identical(derived_response("carbon", TRUE), "carbon_biomass_g_m2")
  expect_identical(derived_response("dry", FALSE), "dry_biomass_kg")
  expect_identical(derived_response("carbon", FALSE), "carbon_biomass_kg")
  expect_identical(derived_response("nitrogen", TRUE), "nitrogen_biomass_g_m2")
  expect_identical(derived_response("nitrogen", FALSE), "nitrogen_biomass_kg")
})

grid <- tibble::tibble(
  site = c("a", "b", "c"),
  year = "2020",
  region = factor(c("south", "north", "south"), levels = c("south", "north"))
)
draws <- matrix(1:6, nrow = 2)

test_that("draws are summed on each draw within groups", {
  res <- pool_draws_by(grid, draws, "region")
  expect_identical(as.character(res$groups$region), c("south", "north"))
  expect_identical(res$id, c(1L, 2L, 1L))
  expect_equal(res$draws, cbind(c(1, 2) + c(5, 6), c(3, 4)), ignore_attr = TRUE)
})

test_that("character(0) sums every row", {
  res <- pool_draws_by(grid, draws, character(0))
  expect_equal(nrow(res$groups), 1L)
  expect_equal(as.vector(res$draws), c(9, 12))
})

test_that("an area divides each sum by its group's summed area", {
  res <- pool_draws_by(grid, draws, "region", area = c(1, 2, 3))
  expect_equal(res$draws[, 1], (c(1, 2) + c(5, 6)) / 4)
  per_draw <- matrix(c(1, 2, 2, 2, 3, 2), nrow = 2)
  res <- pool_draws_by(grid, draws, "region", area = per_draw)
  expect_equal(res$draws[, 1], (c(1, 2) + c(5, 6)) / c(4, 4))
})

test_that("character groups are ordered alphabetically", {
  res <- pool_draws_by(transform(grid, region = as.character(region)), draws, "region")
  expect_identical(res$groups$region, c("north", "south"))
})

test_that("character groups sort alphabetically regardless of case", {
  mixed <- tibble::tibble(
    site = c("a", "b", "c", "d"),
    year = "2020",
    region = c("north", "South", "alpha", "Beta")
  )
  res <- pool_draws_by(mixed, matrix(1:8, nrow = 2), "region")
  expect_identical(res$groups$region, c("alpha", "Beta", "north", "South"))
})

test_that("a survey's total is the bed biomass per m2 times its canopy area", {
  fit <- cover_calibration_nereo_fit
  grid <- tibble::tibble(
    site = fitted_sites(fit),
    year = "2019",
    canopy_area_m2 = 250,
    canopy_tide_height_m = 0,
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
    canopy_tide_height_m = c(0, 1),
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
    canopy_tide_height_m = 1,
    classified_area_m2 = c(1e4, 1e4, 300)
  )
  totals <- canopy_biomass_draws(fit, grid, "average", NULL)
  expect_equal(totals[, 2], 3 * totals[, 1])
  # 300 m2 of canopy, corrected upwards for the tide, is capped at the 300 m2
  # classified: the bed biomass per m2 times 300.
  untided <- canopy_biomass_draws(
    fit,
    transform(grid[3, ], canopy_tide_height_m = 0),
    "average",
    NULL
  )
  expect_equal(totals[, 3], untided[, 1])
})
