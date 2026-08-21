test_that("posterior_epred returns a D x N matrix of positive expected weights", {
  m <- posterior_epred(
    weight_fit,
    new_data = data.frame(diameter = c(20, 40, 60))
  )
  expect_true(is.matrix(m))
  expect_equal(ncol(m), 3L)
  expect_equal(nrow(m), posterior::ndraws(weight_fit$draws))
  expect_true(all(m > 0))
})

test_that("new_data = NULL conditions on observed groups, agreeing with augment", {
  # observed data carries site/year, so each row is conditioned on its random
  # effects; one column per row, and the median matches augment's fitted
  m <- posterior_epred(weight_fit)
  expect_equal(ncol(m), nrow(weight_fit$data))
  med <- apply(m, 2, stats::median)
  expect_equal(med, augment(weight_fit)$fitted, tolerance = 1e-8)
})

test_that("posterior_epred agrees with posterior_linpred(transform = TRUE)", {
  # They coincide by model property, not construction: the two differ only for a
  # mixture likelihood, so a zero-inflated model must make this fail deliberately.
  for (fit in list(weight_fit, weight_macro_fit)) {
    expect_equal(
      posterior_epred(fit, new_data = NULL, new_levels = "average"),
      posterior_linpred(
        fit,
        transform = TRUE,
        new_data = NULL,
        new_levels = "average"
      )
    )
  }
})
