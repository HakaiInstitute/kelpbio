test_that("loo runs on every model type with one row per observation", {
  fits <- list(
    weight_nereo_fit,
    weight_macro_fit,
    size_nereo_fit,
    size_macro_fit,
    density_nereo_fit,
    density_macro_fit,
    wetdry_nereo_fit,
    wetdry_macro_fit,
    carbon_nereo_fit,
    carbon_macro_fit,
    cover_biomass_nereo_fit,
    cover_biomass_macro_fit
  )
  for (fit in fits) {
    out <- suppressWarnings(loo::loo(fit))
    expect_s3_class(out, "psis_loo")
    expect_identical(nrow(out$pointwise), nrow(fit$data))
    expect_length(loo::pareto_k_values(out), nrow(fit$data))
  }
})

test_that("loo and loo_compare work without the loo:: prefix", {
  a <- suppressWarnings(loo(wetdry_nereo_fit))
  expect_s3_class(a, "psis_loo")
  expect_s3_class(loo_compare(a, a), "compare.loo")
})

test_that("loo uses relative efficiencies from the fit's chains", {
  fit <- wetdry_nereo_fit
  ll <- log_lik(fit)
  nchains <- posterior::nchains(fit$draws)
  r_eff <- loo::relative_eff(
    exp(ll),
    chain_id = rep(seq_len(nchains), each = nrow(ll) / nchains)
  )
  expected <- suppressWarnings(loo::loo(ll, r_eff = r_eff))
  out <- suppressWarnings(loo::loo(fit))
  expect_equal(out$estimates, expected$estimates)
  expect_equal(out$diagnostics$n_eff, expected$diagnostics$n_eff)
})

test_that("loo results of fits to the same data can be compared", {
  a <- suppressWarnings(loo::loo(wetdry_nereo_fit))
  b <- suppressWarnings(loo::loo(wetdry_nereo_fit))
  expect_s3_class(loo::loo_compare(a, b), "compare.loo")
})

test_that("loo refuses a fit without a likelihood", {
  prior_only <- wetdry_nereo_fit
  prior_only$meta$prior_only <- TRUE
  expect_snapshot(loo::loo(prior_only), error = TRUE)
  no_data <- wetdry_nereo_fit
  no_data$data <- no_data$data[0, ]
  expect_snapshot(loo::loo(no_data), error = TRUE)
})
