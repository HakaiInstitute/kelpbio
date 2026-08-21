test_that("posterior_predict recomputes replicates at the observed data", {
  withr::local_seed(1)
  yrep <- posterior_predict(weight_fit)
  expect_true(is.matrix(yrep))
  expect_equal(ncol(yrep), nrow(weight_fit$data))
  expect_equal(nrow(yrep), posterior::ndraws(weight_fit$draws))
  expect_true(all(yrep > 0))
  # Replicates are drawn, so never assert exact values: check they sit around the
  # expected weight. A robust statistic, because nereo yrep is exp(Student-t(4)),
  # whose mean and variance are infinite.
  ep <- posterior_epred(weight_fit)
  expect_equal(
    stats::median(apply(yrep, 2, stats::median)),
    stats::median(apply(ep, 2, stats::median)),
    tolerance = 0.1
  )
})

test_that("posterior_predict is reproducible under a seed and not otherwise", {
  # The observation noise is drawn in R, so the documented contract is that
  # set.seed() makes it reproducible.
  a <- withr::with_seed(7, posterior_predict(weight_fit))
  b <- withr::with_seed(7, posterior_predict(weight_fit))
  expect_identical(a, b)
  expect_false(identical(a, withr::with_seed(8, posterior_predict(weight_fit))))
})

test_that("posterior_predict aborts at observed data for a zero-observation fit", {
  fit0 <- weight_fit
  fit0$data <- fit0$data[0, ]
  expect_error(posterior_predict(fit0), "zero-observation fit")
})

test_that("a zero-observation fit still predicts at supplied new_data", {
  # The zero-observation guard applies only to new_data = NULL.
  fit0 <- weight_fit
  fit0$data <- fit0$data[0, ]
  pp <- posterior_predict(
    fit0,
    new_data = data.frame(diameter = c(20, 40)),
    new_levels = "average"
  )
  expect_equal(dim(pp), c(posterior::ndraws(fit0$draws), 2L))
})

test_that("posterior_predict at new data is wider than posterior_epred", {
  nd <- data.frame(diameter = c(20, 40, 60))
  pp <- posterior_predict(weight_fit, new_data = nd, new_levels = "average")
  ep <- posterior_epred(weight_fit, new_data = nd, new_levels = "average")
  expect_equal(dim(pp), dim(ep))
  # observation noise widens the predictive spread relative to the mean structure
  expect_gt(mean(apply(pp, 2, stats::sd)), mean(apply(ep, 2, stats::sd)))
})

test_that("macro posterior_predict draws positive Gamma noise, wider than epred", {
  nd <- data.frame(fronds = c(2, 5, 10))
  pp <- posterior_predict(
    weight_macro_fit,
    new_data = nd,
    new_levels = "average"
  )
  ep <- posterior_epred(weight_macro_fit, new_data = nd, new_levels = "average")
  expect_equal(dim(pp), dim(ep))
  expect_true(all(pp > 0)) # Gamma support is strictly positive
  expect_gt(mean(apply(pp, 2, stats::sd)), mean(apply(ep, 2, stats::sd)))
})

test_that("the internal generic's default aborts for a fit with no method", {
  # The only guard once the public method accepts any kb_fit.
  expect_error(.add_noise(structure(list(), class = c("kb_fit_other", "kb_fit")), 1), "no method for a <kb_fit_other>")
})
