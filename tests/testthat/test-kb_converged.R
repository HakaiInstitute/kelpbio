test_that("kb_converged returns a logical and honours rhat/ess thresholds", {
  expect_type(kb_converged(weight_nereo_fit), "logical")
  expect_true(kb_converged(weight_nereo_fit, rhat = Inf, ess = 0))
  expect_false(kb_converged(weight_nereo_fit, rhat = 1, ess = Inf))
})

test_that("kb_converged fails a fit whose divergence rate exceeds the threshold", {
  # rhat/ess neutralised, as the fixture's own change whenever it is refit.
  fit <- weight_nereo_fit
  fit$diagnostics$perc_divergent <- 0.5
  expect_false(kb_converged(fit, rhat = Inf, ess = 0))
  expect_true(kb_converged(fit, rhat = Inf, ess = 0, max_perc_divergent = 1))
  expect_true(kb_converged(fit, rhat = Inf, ess = 0, max_perc_divergent = 0.5))
  expect_false(kb_converged(fit, rhat = Inf, ess = 0, max_perc_divergent = 0.49))
})

test_that("max_perc_divergent = 0 requires no divergent transitions", {
  # A strict `<` would make zero tolerance unsatisfiable.
  clean <- weight_nereo_fit
  clean$diagnostics$perc_divergent <- 0
  expect_true(kb_converged(clean, rhat = Inf, ess = 0, max_perc_divergent = 0))

  one <- weight_nereo_fit
  one$diagnostics$perc_divergent <- 0.05
  expect_false(kb_converged(one, rhat = Inf, ess = 0, max_perc_divergent = 0))
})

test_that("an unknown divergence rate does not pass the verdict", {
  fit <- weight_nereo_fit
  fit$diagnostics$perc_divergent <- NA_real_
  expect_false(kb_converged(fit, rhat = Inf, ess = 0))
})

test_that("a fit with no finite Rhat does not pass on no evidence", {
  fit <- weight_nereo_fit
  fit$diagnostics$summary$rhat <- NA_real_
  expect_false(kb_converged(fit, ess = 0, max_perc_divergent = 100))
})

test_that("kb_converged validates its thresholds", {
  expect_error(kb_converged(weight_nereo_fit, max_perc_divergent = -1))
  expect_error(kb_converged(weight_nereo_fit, max_perc_divergent = "0.2"))
})


test_that("kb_converged errors on an object that is not a fit", {
  expect_error(kb_converged(1), "must be a <kb_fit> object")
})

test_that("kb_converged requires bulk and tail ESS per chain", {
  fit <- weight_nereo_fit
  fit$diagnostics$perc_divergent <- 0
  fit$diagnostics$summary$rhat <- 1
  nchains <- posterior::nchains(fit$draws)
  fit$diagnostics$summary$ess_bulk <- 100 * nchains
  fit$diagnostics$summary$ess_tail <- 100 * nchains
  expect_true(kb_converged(fit))

  low_tail <- fit
  low_tail$diagnostics$summary$ess_tail[1] <- 100 * nchains - 1
  expect_false(kb_converged(low_tail))
  # the threshold is per chain, so it scales with the chains, not the draws
  expect_true(kb_converged(low_tail, ess = 99))
})
