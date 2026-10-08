test_that("kb_influence returns one row per observation for every model", {
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
    out <- kb_influence(fit)
    expect_s3_class(out, "tbl_df")
    expect_identical(nrow(out), nrow(fit$data))
    expect_named(
      out,
      c(names(fit$data), "elpd_loo", "pareto_k", "influential")
    )
    expect_type(out$influential, "logical")
  }
})

test_that("kb_influence matches loo's pointwise values", {
  out <- kb_influence(size_nereo_fit)
  psis <- suppressWarnings(loo::loo(size_nereo_fit))
  expect_equal(out$elpd_loo, unname(psis$pointwise[, "elpd_loo"]))
  expect_equal(out$pareto_k, loo::pareto_k_values(psis))
})

test_that("the threshold sets the flag and leaves the values unchanged", {
  default <- kb_influence(weight_nereo_fit)
  expect_identical(default$influential, default$pareto_k > 0.7)

  strict <- kb_influence(weight_nereo_fit, threshold = 1e6)
  expect_equal(strict$pareto_k, default$pareto_k)
  expect_equal(strict$elpd_loo, default$elpd_loo)
  expect_false(any(strict$influential))
})

test_that("kb_influence does not warn about high Pareto k", {
  fit <- weight_nereo_fit
  fit$data$weight_kg[1] <- fit$data$weight_kg[1] * 1000
  expect_no_warning(out <- kb_influence(fit))
  expect_true(out$influential[1])
})

test_that("kb_influence refuses fits with no likelihood", {
  prior_only <- wetdry_nereo_fit
  prior_only$meta$prior_only <- TRUE
  expect_snapshot(kb_influence(prior_only), error = TRUE)

  empty <- wetdry_nereo_fit
  empty$data <- empty$data[0, ]
  expect_snapshot(kb_influence(empty), error = TRUE)
})

test_that("kb_influence validates its arguments", {
  expect_snapshot(kb_influence(1), error = TRUE)
  expect_snapshot(kb_influence(wetdry_nereo_fit, threshold = 0), error = TRUE)
  expect_snapshot(kb_influence(wetdry_nereo_fit, 0.7), error = TRUE)
})
