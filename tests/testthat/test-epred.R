# A link-scale rvar over n rows with the fit's draws and chains, as .linpred()
# returns.
lp_rvar <- function(fit, values) {
  nd <- posterior::ndraws(fit$draws)
  posterior::rvar(
    matrix(rep(values, each = nd), nrow = nd),
    nchains = posterior::nchains(fit$draws)
  )
}

test_that(".epred is the inverse log link for macro and the nereo median", {
  lp <- lp_rvar(weight_macro_fit, c(0, 1))
  expect_equal(.epred(weight_macro_fit, lp), exp(lp))
  expect_equal(.epred(weight_macro_fit, lp, expectation = FALSE), exp(lp))
  lp <- lp_rvar(weight_fit, c(0, 1))
  expect_equal(.epred(weight_fit, lp, expectation = FALSE), exp(lp))
})

test_that("the nereo weight mean carries the lognormal retransformation", {
  lp <- lp_rvar(weight_fit, c(0, 1))
  expect_equal(
    .epred(weight_fit, lp),
    exp(lp + weight_fit$draws$sWeight^2 / 2)
  )
})

test_that(".epred returns an rvar for every model", {
  fits <- list(
    weight_fit,
    weight_macro_fit,
    size_nereo_fit,
    size_macro_fit,
    density_nereo_fit,
    density_macro_fit,
    wetdry_nereo_fit,
    carbon_nereo_fit,
    cover_biomass_nereo_fit
  )
  for (fit in fits) {
    out <- .epred(fit, lp_rvar(fit, c(0.5, 1)))
    expect_s3_class(out, "rvar")
    expect_length(out, 2L)
  }
})

test_that("the nereo size mean is the inverse log link", {
  lp <- lp_rvar(size_nereo_fit, c(3, 3.5))
  expect_equal(.epred(size_nereo_fit, lp), exp(lp))
})

test_that("the macro size mean is the truncated mean, above the untruncated one", {
  nd <- data.frame(site = fitted_sites(size_macro_fit, 2))
  ep <- posterior_epred(size_macro_fit, new_data = nd)
  mu <- posterior_linpred(size_macro_fit, transform = TRUE, new_data = nd)
  theta <- as.vector(posterior::draws_of(size_macro_fit$draws$bDispersion))
  expect_equal(ep, mu / (1 - (1 + mu * theta)^(-1 / theta)))
  expect_true(all(ep > mu))
  expect_true(all(ep >= 1))
})

test_that("the nereo density mean carries the zero-inflation probability", {
  nd <- data.frame(site = fitted_sites(density_nereo_fit, 2), area_m2 = 40)
  ep <- posterior_epred(density_nereo_fit, new_data = nd)
  mu <- posterior_linpred(density_nereo_fit, transform = TRUE, new_data = nd)
  zi <- stats::plogis(
    as.vector(posterior::draws_of(density_nereo_fit$draws$bZeroInflation))
  )
  expect_equal(ep, mu * (1 - zi))
  expect_true(all(ep < mu))
})

test_that("the macro density mean is the inverse log link", {
  lp <- lp_rvar(density_macro_fit, c(3, 3.5))
  expect_equal(.epred(density_macro_fit, lp), exp(lp))
})

test_that("the wet/dry and carbon means are the inverse logit", {
  for (fit in list(wetdry_nereo_fit, carbon_nereo_fit)) {
    lp <- lp_rvar(fit, c(-2.4, -1))
    expect_equal(
      posterior::draws_of(.epred(fit, lp)),
      stats::plogis(posterior::draws_of(lp))
    )
  }
})

test_that("the cover biomass mean is the inverse log, with no retransformation", {
  lp <- lp_rvar(cover_biomass_nereo_fit, c(0.1, 0.5))
  expect_equal(.epred(cover_biomass_nereo_fit, lp), exp(lp))
  expect_equal(.epred(cover_biomass_nereo_fit, lp, expectation = FALSE), exp(lp))
})
