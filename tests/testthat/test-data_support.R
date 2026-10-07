test_that("data_support names the most local data a fit has", {
  fit <- list(meta = list(
    site_levels = c("a", "b"),
    year_levels = c("2019", "2020"),
    site_year_levels = c("a:2019", "b:2020")
  ))
  got <- data_support(
    fit,
    site = c("a", "a", "a", "c", "c"),
    year = c("2019", "2020", "2025", "2020", "2025")
  )
  expect_identical(got, c("site-year", "site, year", "site", "year", "none"))
})

test_that("data_support accepts factors", {
  fit <- list(meta = list(
    site_levels = "a",
    year_levels = "2019",
    site_year_levels = "a:2019"
  ))
  expect_identical(data_support(fit, factor("a"), factor("2019")), "site-year")
})

test_that("cover_support names the data the cover fit has, without site-year", {
  fit <- cover_biomass_nereo_fit
  support <- cover_support(
    fit,
    c(rep(fitted_sites(fit), 2), "new", "new"),
    c("2019", "1999", "2019", "1999")
  )
  expect_identical(support, c("site, year", "site", "year", "none"))
})
