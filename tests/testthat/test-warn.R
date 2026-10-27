test_that("warn_carbon_fraction counts samples outside 0.10 to 0.50 and keeps them", {
  ok <- data.frame(sample_mass_mg = c(2, 2), carbon_mass_ug = c(500, 700))
  expect_no_warning(warn_carbon_fraction(ok, "`d`"))
  odd <- data.frame(sample_mass_mg = c(2, 2, 2), carbon_mass_ug = c(500, 1200, 100))
  expect_snapshot(out <- warn_carbon_fraction(odd, "`d`"))
  expect_identical(out, odd)
})

test_that("warn_nitrogen_fraction counts samples outside 0.002 to 0.05 and keeps them", {
  ok <- data.frame(sample_mass_mg = c(2, 2), nitrogen_mass_ug = c(30, 50))
  expect_no_warning(warn_nitrogen_fraction(ok, "`d`"))
  odd <- data.frame(sample_mass_mg = c(2, 2, 2), nitrogen_mass_ug = c(30, 200, 2))
  expect_snapshot(out <- warn_nitrogen_fraction(odd, "`d`"))
  expect_identical(out, odd)
})

test_that("warn_dry_wet_ratio counts samples outside 0.02 to 0.5 and keeps them", {
  ok <- data.frame(wet_mass_g = c(4, 10), dry_mass_g = c(0.4, 0.8))
  expect_no_warning(warn_dry_wet_ratio(ok, "`d`"))
  odd <- data.frame(wet_mass_g = c(4, 4, 4), dry_mass_g = c(0.4, 2.8, 0.04))
  expect_snapshot(out <- warn_dry_wet_ratio(odd, "`d`"))
  expect_identical(out, odd)
})

test_that("a site or year with a comma or bracket warns, naming the values", {
  expect_snapshot(warn_group_names(
    data.frame(site = c("North Reef, inner", "b", "North Reef, inner"), year = "2020"),
    "`d`"
  ))
  expect_warning(
    warn_group_names(data.frame(site = "a", year = "2020[a]"), "`d`"),
    "2020\\[a\\]"
  )
})

test_that("plain names, including spaces, raise no warning", {
  expect_no_warning(
    warn_group_names(data.frame(site = c("North Reef", "b"), year = "2020"), "`d`")
  )
  expect_no_warning(warn_group_names(data.frame(x = "a,b"), "`d`"))
})

test_that("the data checks warn on ambiguous group names", {
  data <- data_size_sample_sim_nereo
  data$site <- as.character(data$site)
  data$site[1] <- "North Reef, inner"
  expect_warning(kb_check_data_size_sample_nereo(data), "comma or square bracket")
})

test_that("a column in the wrong unit warns, naming it and the expected unit", {
  expect_snapshot(warn_implausible_units(data.frame(diameter_mm = c(2.5, 3.4, 4)), "`d`"))
  expect_snapshot(warn_implausible_units(data.frame(weight_kg = c(900, 1200)), "`d`"))
  expect_snapshot(warn_implausible_units(data.frame(survey_area_m2 = c(4e5, 2e5)), "`d`"))
  expect_snapshot(warn_implausible_units(data.frame(wet_mass_g = c(4000, 5000)), "`d`"))
  expect_snapshot(warn_implausible_units(data.frame(canopy_tide_height_m = c(50, 120)), "`d`"))
  expect_warning(
    warn_implausible_units(data.frame(plot_area_m2 = c(2e6, 3e6)), "`d`"),
    "unusually large for square metres"
  )
  expect_warning(
    warn_implausible_units(data.frame(survey_area_m2 = c(0.004, 0.006)), "`d`"),
    "unusually small for square metres"
  )
  expect_warning(
    warn_implausible_units(data.frame(diameter_mm = c(300, 500)), "`d`"),
    "unusually large for millimetres"
  )
})

test_that("plausible, empty, and all-NA columns do not warn", {
  expect_no_warning(
    warn_implausible_units(
      data.frame(
        diameter_mm = c(20, 40),
        weight_kg = c(1, 3),
        survey_area_m2 = c(20, 120),
        wet_mass_g = c(2, 40),
        dry_mass_g = c(0.2, 3.5)
      ),
      "`d`"
    )
  )
  expect_no_warning(warn_implausible_units(data.frame(diameter_mm = numeric(0)), "`d`"))
  expect_no_warning(warn_implausible_units(data.frame(weight_kg = NA), "`d`"))
})

test_that("the median, not an extreme value, decides", {
  expect_no_warning(
    warn_implausible_units(data.frame(weight_kg = c(1, 2, 3, 500)), "`d`")
  )
})

test_that("a site area in hectares warns", {
  expect_warning(
    warn_implausible_units(data.frame(classified_area_m2 = c(5, 8)), "`d`"),
    "classified_area_m2"
  )
  expect_no_warning(warn_implausible_units(data.frame(classified_area_m2 = 5e4), "`d`"))
})

fit_with <- function(...) list(data = data.frame(...))

test_that("values beyond half the minimum or twice the maximum warn", {
  fit <- fit_with(diameter_mm = c(10, 50))
  expect_snapshot(warn_outside_range(fit, c(3, 30, 150), "diameter_mm"))
  expect_warning(warn_outside_range(fit, 4, "diameter_mm"), "far outside")
  expect_warning(warn_outside_range(fit, 101, "diameter_mm"), "far outside")
})

test_that("values within twice the fitted range do not warn", {
  fit <- fit_with(diameter_mm = c(10, 50))
  expect_no_warning(warn_outside_range(fit, c(5, 30, 100, NA), "diameter_mm"))
})

test_that("a column without a unit gets no unit hint", {
  expect_snapshot(warn_outside_range(fit_with(fronds = c(1, 20)), 100, "fronds"))
})

test_that("nothing is compared for a fit with no observations", {
  fit <- fit_with(diameter_mm = numeric(0))
  expect_no_warning(warn_outside_range(fit, 1000, "diameter_mm"))
})

test_that("a surveyed area above the plot area warns", {
  d <- data.frame(survey_area_m2 = c(120, 300), plot_area_m2 = c(200, 200))
  expect_snapshot(warn_survey_area(d, "`d`"))
  expect_no_warning(warn_survey_area(transform(d, survey_area_m2 = 120), "`d`"))
  expect_no_warning(warn_survey_area(transform(d, plot_area_m2 = NA), "`d`"))
})

test_that("a pool_by group holding one site-year twice warns", {
  grid <- tibble::tibble(site = c("a", "a"), year = "2020")
  expect_snapshot(warn_overlapping_canopy(grid, c(1L, 1L)))
  expect_no_warning(warn_overlapping_canopy(grid, c(1L, 2L)))
})

test_that("rows past the tide limit on more than 5% of draws warn", {
  expect_snapshot(
    warn_tide_cap(c(0.2, 0.01, 0.5), "`d`", rows = "row", cap = "the classified area", basis = "on more than 5% of draws")
  )
  expect_no_warning(warn_tide_cap(c(0, 0.05), "`d`", rows = "row", cap = "x", basis = "y"))
})

test_that("tide_cap_share counts the draws past the tide limit, zero canopy excepted", {
  slope <- posterior::rvar(c(0.2, 0.3, 0.4, 0.5))
  # one over the slope is 5, 3.33, 2.5, and 2
  expect_equal(tide_cap_share(c(10, 10, 10, 0), c(1, 2.5, 5, 5), slope), c(0, 0.5, 1, 0))
})

test_that("tide_cap_prior_share is the truncated Normal tail beyond one over the tide", {
  prior <- kb_prior_normal(mean = 0.276, sd = 0.04)
  expect_equal(tide_cap_prior_share(c(1, 1, 0), c(1, 2, 5), prior), c(0, 0, 0))
  set.seed(1)
  x <- stats::rnorm(1e6, 0.276, 0.04)
  x <- x[x >= 0 & x <= 0.5]
  expect_equal(tide_cap_prior_share(1, 3, prior), mean(x >= 1 / 3), tolerance = 0.01)
  expect_equal(tide_cap_prior_share(1, -1, prior), 0)
})

test_that("tide_cap_prior_share treats a prior off the support as its nearer bound", {
  high <- kb_prior_normal(mean = 2, sd = 0.01)
  # at the upper bound of 0.5, the tide limit is 2 m
  expect_equal(tide_cap_prior_share(c(1, 1, 0), c(1, 3, 3), high), c(0, 1, 0))
  low <- kb_prior_normal(mean = -1, sd = 0.01)
  expect_equal(tide_cap_prior_share(c(1, 1), c(1, 3), low), c(0, 0))
  expect_silent(warn_tide_cap(tide_cap_prior_share(1, 1, high), "`data`", "survey", "x", "y"))
})
