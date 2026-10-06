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
