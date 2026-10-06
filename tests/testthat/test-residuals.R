test_that("residuals returns a finite deviance-residual vector", {
  r <- residuals(weight_fit)
  expect_type(r, "double")
  expect_length(r, nobs(weight_fit))
  expect_true(all(is.finite(r)))
})

test_that("residuals are deviance, not raw response residuals", {
  a <- augment(weight_fit)
  expect_false(isTRUE(all.equal(a$residual, a$weight_kg - a$fitted)))
})

test_that("macro gets Gamma deviance residuals, not the nereo Normal ones", {
  r <- residuals(weight_macro_fit)
  mu <- posterior::draws_of(.linpred_obs(weight_macro_fit))
  expect_equal(
    r,
    as.numeric(apply(
      .deviance(weight_macro_fit, mu),
      2L,
      stats::median
    ))
  )
})

test_that("residuals rejects a non-fit and extra args", {
  expect_error(residuals.kb_fit(1), "must be a <kb_fit> object")
  expect_error(
    residuals(weight_fit, type = "pearson"),
    class = "rlib_error_dots_nonempty"
  )
})

test_that("size residuals are finite deviance residuals from the size likelihoods", {
  for (fit in list(size_nereo_fit, size_macro_fit)) {
    r <- residuals(fit)
    expect_length(r, nobs(fit))
    expect_true(all(is.finite(r)))
    mu <- posterior::draws_of(.linpred_obs(fit))
    expect_equal(r, as.numeric(apply(.deviance(fit, mu), 2L, stats::median)))
  }
})

test_that("density residuals are finite deviance residuals from the count likelihoods", {
  for (fit in list(density_nereo_fit, density_macro_fit)) {
    r <- residuals(fit)
    expect_length(r, nobs(fit))
    expect_true(all(is.finite(r)))
    mu <- posterior::draws_of(.linpred_obs(fit))
    expect_equal(r, as.numeric(apply(.deviance(fit, mu), 2L, stats::median)))
  }
})

test_that("wet/dry residuals are finite Beta deviance residuals", {
  for (fit in list(wetdry_nereo_fit, wetdry_macro_fit)) {
    r <- residuals(fit)
    expect_length(r, nobs(fit))
    expect_true(all(is.finite(r)))
    mu <- posterior::draws_of(.linpred_obs(fit))
    expect_equal(r, as.numeric(apply(.deviance(fit, mu), 2L, stats::median)))
  }
})

test_that("carbon residuals are finite Beta deviance residuals", {
  for (fit in list(carbon_nereo_fit, carbon_macro_fit)) {
    r <- residuals(fit)
    expect_length(r, nobs(fit))
    expect_true(all(is.finite(r)))
  }
})

test_that("cover residuals are the log-scale residuals over the scaled in situ SD", {
  for (fit in list(cover_biomass_nereo_fit, cover_biomass_macro_fit)) {
    r <- residuals(fit)
    expect_length(r, nobs(fit))
    expect_true(all(is.finite(r)))
  }
})
