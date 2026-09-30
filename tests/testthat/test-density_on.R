test_that(".density_on reads the recorded flag, missing as FALSE", {
  fit <- list(meta = list(density_on = TRUE))
  expect_true(.density_on(fit))
  fit$meta$density_on <- FALSE
  expect_false(.density_on(fit))
  # a fit made before the flag existed was fitted without the term
  fit$meta$density_on <- NULL
  expect_false(.density_on(fit))
})
