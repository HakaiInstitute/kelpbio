test_that(".epred is the inverse log link for macro and the nereo median", {
  lp <- matrix(c(0, 1, -1, 2), nrow = 2)
  expect_equal(.epred(weight_macro_fit, lp), exp(lp))
  expect_equal(.epred(weight_macro_fit, lp, expectation = FALSE), exp(lp))
  expect_equal(.epred(weight_fit, lp, expectation = FALSE), exp(lp))
})

test_that("nereo .epred adds the lognormal correction draw by draw", {
  sw <- as.vector(posterior::draws_of(weight_fit$draws$sWeight))
  lp <- matrix(seq(-1, 1, length.out = 3 * length(sw)), ncol = 3)
  expected <- exp(lp) * matrix(exp(sw^2 / 2), nrow = length(sw), ncol = 3)
  expect_equal(.epred(weight_fit, lp), expected)
})

test_that(".epred returns the type it was given", {
  # fitted() and the prediction verbs pass an rvar; the posterior_* generics
  # pass a D x N matrix. A method written with stats transforms instead of
  # arithmetic would error on the rvar.
  for (fit in list(weight_fit, weight_macro_fit)) {
    nd <- posterior::ndraws(fit$draws)
    rv <- posterior::rvar(matrix(rnorm(nd * 2), nrow = nd))
    expect_s3_class(.epred(fit, rv), "rvar")
    expect_true(is.matrix(.epred(fit, posterior::draws_of(rv))))
    expect_equal(
      posterior::draws_of(.epred(fit, rv)),
      .epred(fit, posterior::draws_of(rv)),
      ignore_attr = TRUE
    )
  }
})
