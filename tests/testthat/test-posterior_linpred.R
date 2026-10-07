test_that("posterior_linpred returns the log-scale linear predictor", {
  nd <- data.frame(diameter_mm = c(20, 40))
  lp <- posterior_linpred(weight_nereo_fit, new_data = nd)
  expect_true(is.matrix(lp))
  expect_equal(dim(lp), c(posterior::ndraws(weight_nereo_fit$draws), 2L))
})

test_that("transform = TRUE is exp of the log-scale linear predictor", {
  nd <- data.frame(diameter_mm = c(20, 40))
  lp <- posterior_linpred(weight_nereo_fit, new_data = nd, new_levels = "average")
  lpt <- posterior_linpred(
    weight_nereo_fit,
    transform = TRUE,
    new_data = nd,
    new_levels = "average"
  )
  expect_equal(lpt, exp(lp))
  expect_false(isTRUE(all.equal(lp, lpt)))
})
