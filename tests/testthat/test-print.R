test_that("prior print methods show family and hyperparameters", {
  expect_snapshot(print(kb_prior_normal(mean = 0, sd = 2)))
  expect_snapshot(print(kb_prior_exponential(rate = 1)))
})

test_that("print.kb_fit shows stable metadata", {
  expect_snapshot(print(weight_fit))
})

test_that("print.kb_fit shows the macro slim header", {
  expect_snapshot(print(weight_macro_fit))
})

test_that(".fmt_perc rounds for display and names an unknown rate", {
  expect_equal(.fmt_perc(1 / 3), "0.333%")
  expect_equal(.fmt_perc(NA_real_), "unknown")
})

test_that("print.kb_fit shows the size headers without a predictor line", {
  expect_snapshot(print(size_nereo_fit))
  expect_snapshot(print(size_macro_fit))
})

test_that("print.kb_fit shows the wet/dry header without predictor or group lines", {
  expect_snapshot(print(wetdry_nereo_fit))
})

test_that("print.kb_fit shows the carbon header", {
  expect_snapshot(print(carbon_nereo_fit))
})

test_that("print.kb_fit shows the cover biomass header without a predictor line", {
  expect_snapshot(print(cover_biomass_nereo_fit))
})

test_that("print.kb_fit shows the density headers without a predictor line", {
  expect_snapshot(print(density_nereo_fit))
  expect_snapshot(print(density_macro_fit))
})
