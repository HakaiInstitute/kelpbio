test_that(".epred is the inverse log link for macro and the nereo median", {
  lp <- matrix(c(0, 1, -1, 2), nrow = 2)
  expect_equal(.epred(weight_macro_fit, lp), exp(lp))
  expect_equal(.epred(weight_macro_fit, lp, expectation = FALSE), exp(lp))
  expect_equal(.epred(weight_fit, lp, expectation = FALSE), exp(lp))
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

test_that(".epred returns the type it was given for the size models", {
  for (fit in list(size_nereo_fit, size_macro_fit)) {
    nd <- posterior::ndraws(fit$draws)
    rv <- posterior::rvar(matrix(rnorm(nd * 2), nrow = nd))
    expect_s3_class(.epred(fit, rv), "rvar")
    expect_equal(
      posterior::draws_of(.epred(fit, rv)),
      .epred(fit, posterior::draws_of(rv)),
      ignore_attr = TRUE
    )
  }
})

test_that("the nereo size mean is the inverse log link", {
  lp <- matrix(c(3, 3.5, 3.2, 3.8), nrow = 2)
  expect_equal(.epred(size_nereo_fit, lp), exp(lp))
})

test_that("the macro size mean is the truncated mean, above the untruncated one", {
  nd <- data.frame(site = c("site1", "site2"))
  ep <- posterior_epred(size_macro_fit, new_data = nd, new_levels = "average")
  mu <- posterior_linpred(
    size_macro_fit,
    transform = TRUE,
    new_data = nd,
    new_levels = "average"
  )
  theta <- as.vector(posterior::draws_of(size_macro_fit$draws$bDispersion))
  expect_equal(ep, mu / (1 - (1 + mu * theta)^(-1 / theta)))
  expect_true(all(ep > mu))
  expect_true(all(ep >= 1))
})
