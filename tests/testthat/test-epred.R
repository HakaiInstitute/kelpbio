test_that(".epred is the log link for both weight species", {
  for (fit in list(weight_fit, weight_macro_fit)) {
    lp <- matrix(c(0, 1, -1, 2), nrow = 2)
    expect_equal(.epred(fit, lp), exp(lp))
  }
})

test_that(".epred returns the type it was given", {
  # fitted() and the prediction verbs pass an rvar; the posterior_* generics
  # pass a D x N matrix. A method written with stats transforms instead of
  # arithmetic would error on the rvar.
  rv <- posterior::rvar(matrix(rnorm(20), nrow = 10))
  expect_s3_class(.epred(weight_fit, rv), "rvar")
  expect_true(is.matrix(.epred(weight_fit, posterior::draws_of(rv))))
  expect_equal(
    posterior::draws_of(.epred(weight_fit, rv)),
    .epred(weight_fit, posterior::draws_of(rv))
  )
})

test_that(".epred ignores expectation where the two coincide", {
  # They differ only for a mixture likelihood; neither weight model is one, so
  # both species return the inverse link either way.
  lp <- matrix(c(0.5, -0.5), nrow = 1)
  for (fit in list(weight_fit, weight_macro_fit)) {
    expect_equal(
      .epred(fit, lp, expectation = TRUE),
      .epred(fit, lp, expectation = FALSE)
    )
  }
})
