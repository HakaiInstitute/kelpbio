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

test_that("every model's family has all three functions", {
  for (fit in fits) {
    family <- .obs_family(fit, fit$data)$family
    for (type in c("log_lik", "res", "ran")) {
      expect_true(is.function(.family_fun(type, family)), label = family)
    }
  }
})

test_that("every parameter is one value per draw or one per row", {
  # A parameter of any other length would recycle silently over the rows.
  for (fit in fits) {
    family <- .obs_family(fit, fit$data)
    mu <- posterior::draws_of(.linpred_obs(fit))
    expect_length(family$response(fit$data), ncol(mu))
    pars <- family$pars(mu[1, ], 1L)
    expect_true(
      all(lengths(pars) %in% c(1L, ncol(mu))),
      label = class(fit)[1]
    )
  }
})

test_that(".family_fun errors for an unknown family or type", {
  expect_error(.family_fun("log_lik", "cauchy"), "cauchy")
  expect_error(.family_fun("cdf", "lnorm"), "cdf")
})

test_that(".eval_family returns D x N for every type", {
  mu <- posterior::draws_of(.linpred_obs(weight_macro_fit))
  for (type in c("log_lik", "res", "ran")) {
    out <- .eval_family(weight_macro_fit, mu, weight_macro_fit$data, type)
    expect_equal(dim(out), dim(mu), label = type)
  }
})

test_that("cover replicates need the in situ limits", {
  fit <- cover_biomass_nereo_fit
  expect_error(
    .obs_family(fit, fit$data[setdiff(names(fit$data), "lower")]),
    "lower"
  )
})
