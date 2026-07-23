test_that("posterior_linpred returns the log-scale linear predictor", {
  nd <- data.frame(diameter = c(20, 40))
  lp <- posterior_linpred(weight_fit, new_data = nd)
  expect_true(is.matrix(lp))
  expect_equal(dim(lp), c(posterior::ndraws(weight_fit$draws), 2L))
})

test_that("transform = TRUE is exp of the log-scale linear predictor", {
  # new_levels = "average" zeroes the random effects, so the two calls share a
  # deterministic linear predictor and the exp relationship is exact.
  nd <- data.frame(diameter = c(20, 40))
  lp <- posterior_linpred(weight_fit, new_data = nd, new_levels = "average")
  lpt <- posterior_linpred(
    weight_fit,
    transform = TRUE, new_data = nd, new_levels = "average"
  )
  expect_equal(lpt, exp(lp))
  # untransformed is genuinely the log scale, not the response scale
  expect_false(isTRUE(all.equal(lp, lpt)))
  # response scale equals posterior_epred (both exp of the same predictor)
  expect_equal(
    lpt,
    posterior_epred(weight_fit, new_data = nd, new_levels = "average")
  )
})
