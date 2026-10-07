test_that("kb_sensitivity returns one row per paired parameter for every model", {
  skip_if_not_installed("priorsense")
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
    out <- kb_sensitivity(fit)
    expect_s3_class(out, "tbl_df")
    expect_named(
      out,
      c(
        "term",
        "prior_cjs",
        "likelihood_cjs",
        "weak_prior",
        "strong_data"
      )
    )
    expect_identical(out$term, fit$meta$terms$fixed)
    expect_true(all(out$term %in% names(fit$meta$priors)))
  }
})

test_that("each term names an entry of the model's default priors", {
  skip_if_not_installed("priorsense")
  out <- kb_sensitivity(weight_nereo_fit)
  expect_true(all(out$term %in% names(kb_priors_weight_nereo())))
})

test_that("kb_sensitivity matches priorsense's values", {
  skip_if_not_installed("priorsense")
  out <- kb_sensitivity(size_nereo_fit)
  ps <- priorsense::powerscale_sensitivity(size_nereo_fit)
  expect_equal(out$prior_cjs, ps$prior[match(out$term, ps$variable)])
  expect_equal(out$likelihood_cjs, ps$likelihood[match(out$term, ps$variable)])
})

test_that("the thresholds set the flags and leave the values unchanged", {
  skip_if_not_installed("priorsense")
  default <- kb_sensitivity(weight_nereo_fit)
  expect_identical(default$weak_prior, default$prior_cjs < 0.1)
  expect_identical(default$strong_data, default$likelihood_cjs >= 0.05)

  strict <- kb_sensitivity(
    weight_nereo_fit,
    prior_threshold = 1e-6,
    likelihood_threshold = 1e6
  )
  expect_equal(strict$prior_cjs, default$prior_cjs)
  expect_false(any(strict$weak_prior))
  expect_false(any(strict$strong_data))
})

test_that("an omitted effect has no row", {
  skip_if_not_installed("priorsense")
  fit <- weight_nereo_fit
  fit$meta$terms$fixed <- setdiff(fit$meta$terms$fixed, "density_slope")
  fit$meta$density_on <- FALSE
  out <- kb_sensitivity(fit)
  expect_false("density_slope" %in% out$term)
})

test_that("kb_sensitivity refuses fits with no likelihood", {
  skip_if_not_installed("priorsense")
  prior_only <- wetdry_nereo_fit
  prior_only$meta$prior_only <- TRUE
  expect_snapshot(kb_sensitivity(prior_only), error = TRUE)

  empty <- wetdry_nereo_fit
  empty$data <- empty$data[0, ]
  expect_snapshot(kb_sensitivity(empty), error = TRUE)
})

test_that("kb_sensitivity validates its arguments", {
  expect_snapshot(kb_sensitivity(1), error = TRUE)
  expect_snapshot(
    kb_sensitivity(wetdry_nereo_fit, prior_threshold = 0),
    error = TRUE
  )
  expect_snapshot(
    kb_sensitivity(wetdry_nereo_fit, likelihood_threshold = "a"),
    error = TRUE
  )
  expect_snapshot(kb_sensitivity(wetdry_nereo_fit, 0.1), error = TRUE)
})

test_that("kb_sensitivity names priorsense when it is missing", {
  local_mocked_bindings(
    check_installed = function(pkg, ...) {
      cli::cli_abort("The package {.pkg {pkg}} is required.")
    },
    .package = "rlang"
  )
  expect_error(kb_sensitivity(wetdry_nereo_fit), "priorsense")
})
