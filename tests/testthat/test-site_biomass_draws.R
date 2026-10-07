test_that("a survey's total is the bed biomass per m2 times its canopy area", {
  fit <- cover_biomass_nereo_fit
  grid <- tibble::tibble(
    site = fitted_sites(fit),
    year = "2019",
    canopy_area_m2 = 250,
    tide_height_m = 0
  )
  totals <- site_biomass_draws(fit, grid, "average", NULL)
  d <- fit$draws
  bed <- d$biomass_floor + d$cover_slope * exp(d$site_effect[1] + d$year_effect[1])
  expect_equal(
    totals[, 1],
    as.vector(posterior::draws_of(bed)) * 250,
    ignore_attr = TRUE
  )
})

test_that("the canopy is tide-corrected with each draw's tide_height_slope", {
  fit <- cover_biomass_nereo_fit
  grid <- tibble::tibble(
    site = fitted_sites(fit),
    year = "2019",
    canopy_area_m2 = 100,
    tide_height_m = c(0, 1)
  )
  totals <- site_biomass_draws(fit, grid, "average", NULL)
  tide <- as.vector(posterior::draws_of(fit$draws$tide_height_slope))
  expect_equal(totals[, 2], totals[, 1] * (1 + tide))
})

test_that("totals scale with canopy area, and the site area caps the canopy", {
  fit <- cover_biomass_macro_fit
  grid <- tibble::tibble(
    site = fitted_sites(fit, 2)[2],
    year = "2020",
    canopy_area_m2 = c(100, 300, 300),
    tide_height_m = 1,
    site_area_m2 = c(1e4, 1e4, 300)
  )
  totals <- site_biomass_draws(fit, grid, "average", NULL)
  expect_equal(totals[, 2], 3 * totals[, 1])
  # 300 m2 of canopy, corrected upwards for the tide, is capped at the site's 300
  # m2: the bed biomass per m2 times 300.
  untided <- site_biomass_draws(
    fit,
    transform(grid[3, ], tide_height_m = 0),
    "average",
    NULL
  )
  expect_equal(totals[, 3], untided[, 1])
})

test_that("rows naming one new site share its sampled effect", {
  withr::local_seed(1)
  grid <- tibble::tibble(
    site = c("new", "new", "other"),
    year = "2019",
    canopy_area_m2 = c(100, 200, 100),
    tide_height_m = 0
  )
  totals <- site_biomass_draws(cover_biomass_nereo_fit, grid, "sample", NULL)
  expect_equal(totals[, 2], 2 * totals[, 1])
  expect_false(isTRUE(all.equal(totals[, 3], totals[, 1])))
})
