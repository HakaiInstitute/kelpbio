test_that("kb_model_describe renders the nereo notation block", {
  expect_snapshot(kb_model_describe(weight_fit))
})

test_that("kb_model_describe renders the macro notation block", {
  expect_snapshot(kb_model_describe(weight_macro_fit))
})

test_that("kb_model_describe renders a methods paragraph with prose = TRUE", {
  expect_snapshot(kb_model_describe(weight_fit, prose = TRUE))
})

test_that("custom stored priors are reflected", {
  fit <- weight_macro_fit
  fit$meta$priors$fronds_slope <- kb_prior_normal(mean = 1.5, sd = 0.05)
  out <- capture.output(kb_model_describe(fit))
  expect_true(any(grepl("Normal\\(1.5, 0.05\\)", out)))
})

test_that("a dropped site:year effect is omitted from the description", {
  fit <- weight_fit
  fit$meta$site_year_on <- FALSE
  out <- capture.output(kb_model_describe(fit))
  expect_false(any(grepl("SiteYear", out)))
})

test_that("prose = TRUE returns the lines invisibly", {
  expect_invisible(kb_model_describe(weight_fit, prose = TRUE))
  expect_type(
    withVisible(kb_model_describe(weight_fit))$value,
    "character"
  )
})

test_that("a weight fit with no species method errors rather than returning", {
  fake <- structure(
    list(),
    class = c("kb_fit_weight_other", "kb_fit_weight", "kb_fit")
  )
  err <- expect_error(
    kb_model_describe(fake),
    "no method for.*<kb_fit_weight_other>"
  )
  # the hint names the constructors that do have a method
  expect_match(conditionMessage(err), "kb_fit_weight_nereo")
})

test_that("an object that is not a fit errors, attributed to the generic", {
  cnd <- rlang::catch_cnd(kb_model_describe(1))
  expect_match(conditionMessage(cnd), "must be a <kb_fit> object")
  expect_equal(cnd$call, quote(kb_model_describe(1)))
})

test_that("the density term is left out when not fitted", {
  # the fitted case is pinned by the nereo notation snapshot
  off <- weight_fit
  off$meta$density_on <- FALSE
  out <- capture.output(kb_model_describe(off))
  expect_false(any(grepl("density", out, ignore.case = TRUE)))
})

test_that("kb_model_describe renders the size notation blocks", {
  expect_snapshot(kb_model_describe(size_nereo_fit))
  expect_snapshot(kb_model_describe(size_macro_fit))
  expect_snapshot(kb_model_describe(size_macro_fit, prose = TRUE))
})

test_that("kb_model_describe renders the density notation blocks", {
  expect_snapshot(kb_model_describe(density_nereo_fit))
  expect_snapshot(kb_model_describe(density_nereo_fit, prose = TRUE))
  expect_snapshot(kb_model_describe(density_macro_fit))
})

test_that("kb_model_describe renders the wet/dry model without random effects", {
  expect_snapshot(kb_model_describe(wetdry_nereo_fit))
  expect_snapshot(kb_model_describe(wetdry_macro_fit, prose = TRUE))
})

test_that("kb_model_describe renders the carbon model", {
  expect_snapshot(kb_model_describe(carbon_nereo_fit))
  expect_snapshot(kb_model_describe(carbon_macro_fit, prose = TRUE))
})

test_that("kb_model_describe renders the cover biomass model with each species' priors", {
  expect_snapshot(kb_model_describe(cover_biomass_nereo_fit))
  expect_snapshot(kb_model_describe(cover_biomass_macro_fit))
  expect_snapshot(kb_model_describe(cover_biomass_macro_fit, prose = TRUE))
})

test_that("a dropped site:year effect is omitted from the size description", {
  fit <- size_nereo_fit
  fit$meta$site_year_on <- FALSE
  out <- capture.output(kb_model_describe(fit))
  expect_false(any(grepl("SiteYear", out)))
})

test_that("kb_model_describe follows the power-law form", {
  power <- weight_fit
  power$meta$form <- "power"
  expect_snapshot(kb_model_describe(power))
  expect_snapshot(kb_model_describe(power, prose = TRUE))
})
