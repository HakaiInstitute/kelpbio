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

test_that("pp_check plots the observed response against its replicates", {
  withr::local_seed(1)
  gg <- pp_check(wetdry_nereo_fit, ndraws = 5)
  expect_s3_class(gg, "ggplot")
  expect_identical(dim(yrep_of(gg)), c(5L, nrow(wetdry_nereo_fit$data)))
  expect_identical(gg$labels$x, axis_label(wetdry_nereo_fit$meta$response))
  expect_equal(
    y_of(pp_check(weight_nereo_fit, ndraws = 1)),
    weight_nereo_fit$data$weight_kg
  )
})

test_that("pp_check plots residuals against their replicates", {
  withr::local_seed(1)
  gg <- pp_check(size_nereo_fit, "residual", ndraws = 3)
  expect_identical(gg$labels$x, "Deviance residual")
  expect_equal(y_of(gg), residuals(size_nereo_fit))
  expect_true(all(is.finite(yrep_of(gg))))
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
