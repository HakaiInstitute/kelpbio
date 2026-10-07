test_that("warn_carbon_fraction counts samples outside 0.10 to 0.50 and keeps them", {
  ok <- data.frame(sample_mass_mg = c(2, 2), carbon_mass_ug = c(500, 700))
  expect_no_warning(warn_carbon_fraction(ok, "`d`"))
  odd <- data.frame(sample_mass_mg = c(2, 2, 2), carbon_mass_ug = c(500, 1200, 100))
  expect_snapshot(out <- warn_carbon_fraction(odd, "`d`"))
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
  data <- data_size_sim_macro
  data$site <- as.character(data$site)
  data$site[1] <- "North Reef, inner"
  expect_warning(kb_check_data_size_macro(data), "comma or square bracket")
})

test_that("a column in the wrong unit warns, naming it and the expected unit", {
  expect_snapshot(warn_implausible_units(data.frame(diameter_mm = c(2.5, 3.4, 4)), "`d`"))
  expect_snapshot(warn_implausible_units(data.frame(weight_kg = c(900, 1200)), "`d`"))
  expect_snapshot(warn_implausible_units(data.frame(stipes_m2 = c(20000, 30000)), "`d`"))
  expect_snapshot(warn_implausible_units(data.frame(area_m2 = c(4e5, 2e5)), "`d`"))
  expect_snapshot(warn_implausible_units(data.frame(wet_mass_g = c(4000, 5000)), "`d`"))
  expect_snapshot(warn_implausible_units(data.frame(tide_height_m = c(50, 120)), "`d`"))
  expect_warning(
    warn_implausible_units(data.frame(plot_area_m2 = c(2e6, 3e6)), "`d`"),
    "unusually large for square metres"
  )
  expect_warning(
    warn_implausible_units(data.frame(area_m2 = c(0.004, 0.006)), "`d`"),
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
        stipes_m2 = c(2, 5),
        area_m2 = c(20, 120),
        wet_mass_g = c(2, 40),
        dry_mass_g = c(0.2, 3.5)
      ),
      "`d`"
    )
  )
  expect_no_warning(warn_implausible_units(data.frame(diameter_mm = numeric(0)), "`d`"))
  expect_no_warning(warn_implausible_units(data.frame(stipes_m2 = NA), "`d`"))
})

test_that("the median, not an extreme value, decides", {
  expect_no_warning(
    warn_implausible_units(data.frame(weight_kg = c(1, 2, 3, 500)), "`d`")
  )
})

test_that("a site area in hectares warns", {
  expect_warning(
    warn_implausible_units(data.frame(site_area_m2 = c(5, 8)), "`d`"),
    "site_area_m2"
  )
  expect_no_warning(warn_implausible_units(data.frame(site_area_m2 = 5e4), "`d`"))
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

test_that("lower = FALSE checks only the upper side", {
  fit <- fit_with(stipes_m2 = c(1, 8))
  expect_no_warning(warn_outside_range(fit, 0.1, "stipes_m2", lower = FALSE))
  expect_warning(warn_outside_range(fit, 20, "stipes_m2", lower = FALSE), "far outside")
})
