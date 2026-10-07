all_fits <- function() {
  list(
    weight_nereo = weight_nereo_fit,
    weight_macro = weight_macro_fit,
    size_nereo = size_nereo_fit,
    size_macro = size_macro_fit,
    density_nereo = density_nereo_fit,
    density_macro = density_macro_fit,
    wetdry_nereo = wetdry_nereo_fit,
    wetdry_macro = wetdry_macro_fit,
    carbon_nereo = carbon_nereo_fit,
    carbon_macro = carbon_macro_fit,
    cover_biomass_nereo = cover_biomass_nereo_fit,
    cover_biomass_macro = cover_biomass_macro_fit
  )
}

test_that("priorsense assesses every model's paired parameters", {
  skip_if_not_installed("priorsense")
  for (fit in all_fits()) {
    out <- priorsense::powerscale_sensitivity(fit)
    expect_identical(out$variable, fit$meta$terms$fixed)
    expect_true(all(is.finite(out$prior)))
    expect_true(all(is.finite(out$likelihood)))
  }
})

test_that("the priorsense data carry the fit's chains and draws", {
  skip_if_not_installed("priorsense")
  psd <- priorsense::create_priorsense_data(wetdry_nereo_fit)
  expect_s3_class(psd, "priorsense_data")
  expect_identical(
    posterior::nchains(psd$log_lik),
    posterior::nchains(wetdry_nereo_fit$draws)
  )
  expect_identical(
    posterior::ndraws(psd$log_prior),
    posterior::ndraws(wetdry_nereo_fit$draws)
  )
  expect_identical(
    posterior::nvariables(psd$log_lik),
    nrow(wetdry_nereo_fit$data)
  )
})

test_that("priorsense plots run on a fit", {
  skip_if_not_installed("priorsense")
  expect_s3_class(
    priorsense::powerscale_plot_dens(wetdry_nereo_fit),
    "ggplot"
  )
})

test_that("a prior-only fit is refused", {
  skip_if_not_installed("priorsense")
  fit <- wetdry_nereo_fit
  fit$meta$prior_only <- TRUE
  expect_snapshot(priorsense::create_priorsense_data(fit), error = TRUE)
})
