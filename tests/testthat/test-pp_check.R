fits <- list(
  weight_nereo = weight_nereo_fit,
  weight_macro = weight_macro_fit,
  size_nereo = size_nereo_fit,
  wetdry_nereo = wetdry_nereo_fit,
  wetdry_macro = wetdry_macro_fit,
  carbon_nereo = carbon_nereo_fit,
  carbon_macro = carbon_macro_fit,
  cover_calibration_nereo = cover_calibration_nereo_fit,
  cover_calibration_macro = cover_calibration_macro_fit
)

# The replicate values a bayesplot density overlay was built from, D x N.
yrep_of <- function(gg) {
  d <- gg$data[!gg$data$is_y, ]
  out <- matrix(NA_real_, max(d$rep_id), max(d$y_id))
  out[cbind(d$rep_id, d$y_id)] <- d$value
  out
}

y_of <- function(gg) gg$data$value[gg$data$is_y]

test_that("pp_check is available after library(kelpbio)", {
  expect_true("pp_check" %in% getNamespaceExports("kelpbio"))
})

test_that("pp_check plots the response for every model", {
  withr::local_seed(1)
  for (nm in names(fits)) {
    fit <- fits[[nm]]
    gg <- pp_check(fit, ndraws = 5)
    expect_s3_class(gg, "ggplot")
    yrep <- yrep_of(gg)
    expect_identical(dim(yrep), c(5L, nrow(fit$data)), label = nm)
    expect_identical(gg$labels$x, axis_label(fit$meta$response), label = nm)
  }
})

test_that("response replicates follow the observation family", {
  withr::local_seed(1)
  biomass <- yrep_of(pp_check(cover_calibration_nereo_fit, ndraws = 5))
  expect_true(all(biomass >= 0))
  ratio <- yrep_of(pp_check(wetdry_nereo_fit, ndraws = 5))
  expect_true(all(ratio > 0 & ratio < 1))
  expect_equal(
    y_of(pp_check(weight_nereo_fit, ndraws = 1)),
    weight_nereo_fit$data$weight_kg
  )
})

test_that("pp_check plots residuals for every model", {
  withr::local_seed(1)
  for (nm in names(fits)) {
    fit <- fits[[nm]]
    gg <- pp_check(fit, "residual", ndraws = 3)
    expect_identical(gg$labels$x, "Deviance residual", label = nm)
    expect_equal(y_of(gg), residuals(fit), label = nm)
    expect_true(all(is.finite(yrep_of(gg))), label = nm)
  }
})

test_that("pp_check defaults to 50 replicates", {
  withr::local_seed(1)
  expect_identical(nrow(yrep_of(pp_check(weight_macro_fit))), 50L)
})

test_that("pp_check is reproducible under a seed", {
  a <- withr::with_seed(3, yrep_of(pp_check(size_nereo_fit, ndraws = 4)))
  b <- withr::with_seed(3, yrep_of(pp_check(size_nereo_fit, ndraws = 4)))
  expect_identical(a, b)
})

test_that("pp_check validates its arguments", {
  expect_snapshot(pp_check(weight_nereo_fit, ndraws = 2.5), error = TRUE)
  expect_snapshot(
    pp_check(weight_nereo_fit, ndraws = posterior::ndraws(weight_nereo_fit$draws) + 1),
    error = TRUE
  )
  expect_snapshot(pp_check(weight_nereo_fit, "bars"), error = TRUE)
  expect_snapshot(pp_check(weight_nereo_fit, ndraw = 5), error = TRUE)
})

test_that("pp_check errors for a zero-observation fit", {
  fit0 <- weight_nereo_fit
  fit0$data <- fit0$data[0, ]
  expect_error(pp_check(fit0), "zero-observation fit")
})
