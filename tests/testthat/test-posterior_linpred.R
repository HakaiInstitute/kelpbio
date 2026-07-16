test_that("posterior_linpred returns the log-scale linear predictor", {
  nd <- data.frame(diameter = c(20, 40))
  lp <- posterior_linpred(weight_fit, new_data = nd)
  expect_true(is.matrix(lp))
  expect_equal(dim(lp), c(posterior::ndraws(weight_fit$draws), 2L))
})

test_that("transform = TRUE returns the response scale", {
  nd <- data.frame(diameter = c(20, 40))
  lpt <- posterior_linpred(weight_fit, transform = TRUE, new_data = nd)
  expect_true(all(lpt > 0))
})
