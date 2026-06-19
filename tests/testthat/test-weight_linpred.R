# Tests for the internal .weight_linpred() engine and its by-axis validation.

test_that(".weight_linpred returns a log-scale rvar aligned to the grid", {
  grid <- data.frame(diameter = c(20, 40, 60))
  lp <- kelpbio:::.weight_linpred(weight_fit, grid, by = character(0), uncertainty = "typical")
  expect_s3_class(lp, "rvar")
  expect_length(lp, 3L)
  expect_equal(posterior::ndraws(lp), posterior::ndraws(weight_fit$draws))
})

test_that("validate_by_weight enforces the valid by set", {
  expect_error(kelpbio:::validate_by_weight("year", "marginal"))
  expect_error(kelpbio:::validate_by_weight("bogus", "marginal"))
  expect_error(kelpbio:::validate_by_weight(c("site", "year"), "marginal"))
  expect_identical(kelpbio:::validate_by_weight(NULL, "marginal"), character(0))
  expect_identical(kelpbio:::validate_by_weight("site", "marginal"), "site")
})
