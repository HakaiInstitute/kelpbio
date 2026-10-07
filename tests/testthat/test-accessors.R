test_that("accessors return expected shapes", {
  expect_type(rhat(weight_fit), "double")
  expect_type(esr(weight_fit), "double")
  expect_true(all(esr(weight_fit) > 0))
  expect_type(estimates(weight_fit), "double")
  expect_equal(nobs(weight_fit), nrow(weight_fit$data))
  expect_equal(nchains(weight_fit), 2L)
  expect_equal(npars(weight_fit), length(pars(weight_fit)))
  expect_true(nterms(weight_fit) > npars(weight_fit))
  expect_setequal(
    pars(weight_fit),
    c(
      "intercept",
      "diameter_power",
      "weight_floor",
      "density_slope",
      "sd_site",
      "sd_year",
      "sd_site_year",
      "sd_residual",
      "site_effect",
      "year_effect",
      "site_year_effect"
    )
  )
})

test_that("accessors exclude an effect the fit omitted", {
  off <- weight_fit
  off$meta$density_on <- FALSE
  off$meta$terms$fixed <- setdiff(off$meta$terms$fixed, "density_slope")
  expect_false("density_slope" %in% names(rhat(off)))
  expect_false("density_slope" %in% names(esr(off)))
  expect_false("density_slope" %in% pars(off))
  expect_equal(npars(off), npars(weight_fit) - 1L)
  expect_equal(glance(off)$K, npars(off))
})
