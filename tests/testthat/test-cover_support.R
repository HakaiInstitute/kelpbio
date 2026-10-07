test_that("cover_support names the data the cover fit has, without site-year", {
  fit <- cover_biomass_nereo_fit
  support <- cover_support(
    fit,
    c(rep(fitted_sites(fit), 2), "new", "new"),
    c("2019", "1999", "2019", "1999")
  )
  expect_identical(support, c("site, year", "site", "year", "none"))
})
