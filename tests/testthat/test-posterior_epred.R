test_that("posterior_epred returns a D x N matrix of positive expected weights", {
  m <- posterior_epred(weight_fit, new_data = data.frame(diameter = c(20, 40, 60)))
  expect_true(is.matrix(m))
  expect_equal(ncol(m), 3L)
  expect_equal(nrow(m), posterior::ndraws(weight_fit$draws))
  expect_true(all(m > 0))
})

test_that("new_data = NULL conditions on observed groups, agreeing with augment", {
  # Observed data carries site/year, so the generic conditions on each row's
  # random effects; one column per row, and its median matches augment's fitted.
  # (Site conditioning, new-level sampling, and representative_site are proven at
  # the engine level in test-weight_nereo_linpred.R / test-kb_predict_weight.R.)
  m <- posterior_epred(weight_fit)
  expect_equal(ncol(m), nrow(weight_fit$data))
  med <- apply(m, 2, stats::median)
  expect_equal(med, augment(weight_fit)$fitted, tolerance = 1e-8)
})
