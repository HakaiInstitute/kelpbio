test_that("converged returns a logical and honours rhat/esr thresholds", {
  expect_type(converged(weight_fit), "logical")
  expect_true(converged(weight_fit, rhat = Inf, esr = 0))
  expect_false(converged(weight_fit, rhat = 1, esr = Inf))
})

test_that("converged fails a fit whose divergence rate reaches the threshold", {
  fit <- weight_fit
  fit$diagnostics$perc_divergent <- 0.5
  expect_false(converged(fit))
  expect_true(converged(fit, max_perc_divergent = 1))
  # The comparison is inclusive, so a rate exactly at the threshold passes.
  expect_true(converged(fit, max_perc_divergent = 0.5))
  expect_false(converged(fit, max_perc_divergent = 0.49))
})

test_that("max_perc_divergent = 0 requires no divergent transitions", {
  # Zero tolerance must be satisfiable: a clean fit passes it, which a strict `<`
  # comparison would make impossible.
  clean <- weight_fit
  clean$diagnostics$perc_divergent <- 0
  expect_equal(
    converged(clean, max_perc_divergent = 0),
    converged(clean, rhat = 1.01, esr = 0.1)
  )

  one <- weight_fit
  one$diagnostics$perc_divergent <- 0.05
  expect_false(converged(one, max_perc_divergent = 0))
})

test_that("an unknown divergence rate does not pass the verdict", {
  fit <- weight_fit
  fit$diagnostics$perc_divergent <- NA_real_
  expect_false(converged(fit, rhat = Inf, esr = 0))
})

test_that("a fit with no finite Rhat does not pass on no evidence", {
  fit <- weight_fit
  fit$diagnostics$summary$rhat <- NA_real_
  expect_false(converged(fit, esr = 0))
})

test_that("converged validates its thresholds", {
  expect_error(converged(weight_fit, max_perc_divergent = -1))
  expect_error(converged(weight_fit, max_perc_divergent = "0.2"))
})
