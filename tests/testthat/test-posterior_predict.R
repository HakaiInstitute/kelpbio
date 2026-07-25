test_that("posterior_predict returns stored yrep at observed data", {
  yrep <- posterior_predict(weight_fit)
  expect_true(is.matrix(yrep))
  expect_equal(ncol(yrep), nrow(weight_fit$data))
  expect_equal(nrow(yrep), posterior::ndraws(weight_fit$draws))
  expect_true(all(yrep > 0))
  # it is exactly the stored yrep generated quantity, not a recomputation
  expect_equal(yrep, posterior::draws_of(weight_fit$gq$yrep))
})

test_that("posterior_predict aborts at observed data for a zero-observation fit", {
  fit0 <- weight_fit
  fit0$gq <- NULL
  expect_error(posterior_predict(fit0), "zero-observation fit")
})

test_that("posterior_predict at new data is wider than posterior_epred", {
  nd <- data.frame(diameter = c(20, 40, 60))
  pp <- posterior_predict(weight_fit, new_data = nd, new_levels = "average")
  ep <- posterior_epred(weight_fit, new_data = nd, new_levels = "average")
  expect_equal(dim(pp), dim(ep))
  # observation noise widens the predictive spread relative to the mean structure
  expect_gt(mean(apply(pp, 2, stats::sd)), mean(apply(ep, 2, stats::sd)))
})
