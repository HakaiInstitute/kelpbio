test_that("loo returns one row per observation", {
  out <- suppressWarnings(loo::loo(size_nereo_fit))
  expect_s3_class(out, "psis_loo")
  expect_identical(nrow(out$pointwise), nrow(size_nereo_fit$data))
  expect_length(loo::pareto_k_values(out), nrow(size_nereo_fit$data))
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

test_that("loo refuses a fit without a likelihood", {
  prior_only <- wetdry_nereo_fit
  prior_only$meta$prior_only <- TRUE
  expect_snapshot(loo::loo(prior_only), error = TRUE)
  no_data <- wetdry_nereo_fit
  no_data$data <- no_data$data[0, ]
  expect_snapshot(loo::loo(no_data), error = TRUE)
})
