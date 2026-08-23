test_that("residuals returns a finite deviance-residual vector", {
  r <- residuals(weight_fit)
  expect_type(r, "double")
  expect_length(r, nobs(weight_fit))
  expect_true(all(is.finite(r)))
})

test_that("residuals are deviance, not raw response residuals", {
  a <- augment(weight_fit)
  expect_false(isTRUE(all.equal(a$residual, a$weight - a$fitted)))
})

test_that("macro gets Gamma deviance residuals, not the Student-t ones", {
  # the shared shape (type, length, finiteness) is covered above; what is
  # macro-specific is that its own likelihood is used
  r <- residuals(weight_macro_fit)
  expect_length(r, nobs(weight_macro_fit))
  expect_true(all(is.finite(r)))
  mu <- posterior::draws_of(.linpred_obs(weight_macro_fit))
  expect_equal(
    r,
    as.numeric(apply(
      .deviance(weight_macro_fit, mu),
      2L,
      stats::median
    ))
  )
})

test_that("residuals rejects a non-fit and extra args", {
  expect_error(residuals.kb_fit(1), "must be a <kb_fit> object")
  expect_error(
    residuals(weight_fit, type = "pearson"),
    class = "rlib_error_dots_nonempty"
  )
})
