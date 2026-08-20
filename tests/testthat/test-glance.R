test_that("glance returns a one-row summary with the reportable core columns", {
  g <- glance(weight_fit)
  expect_equal(nrow(g), 1L)
  expect_named(
    g,
    c(
      "n",
      "K",
      "nchains",
      "niters",
      "nthin",
      "ess",
      "rhat",
      "perc_divergent",
      "converged"
    )
  )
  expect_type(g$converged, "logical")
  expect_equal(g$n, nobs(weight_fit))
  expect_equal(g$K, npars(weight_fit))
})

test_that("glance reports the stored divergence rate and omits the rest", {
  g <- glance(weight_fit)
  expect_equal(g$perc_divergent, weight_fit$diagnostics$perc_divergent)
  # Treedepth and E-BFMI are reported by print(summary(fit)), not here.
  expect_false(any(c("perc_max_treedepth", "ebfmi") %in% names(g)))
})

test_that("glance's converged column agrees with converged()", {
  # Guard against tibble() data-masking the rhat/esr thresholds to the columns.
  expect_equal(glance(weight_fit)$converged, converged(weight_fit))
  expect_equal(
    glance(weight_fit, rhat = 1.001, esr = 0.5)$converged,
    converged(weight_fit, rhat = 1.001, esr = 0.5)
  )
  fit <- weight_fit
  fit$diagnostics$perc_divergent <- 0.5
  expect_equal(
    glance(fit, max_perc_divergent = 0.1)$converged,
    converged(fit, max_perc_divergent = 0.1)
  )
})

test_that("glance reports NA rather than -Inf when no diagnostic is finite", {
  fit <- weight_fit
  fit$diagnostics$summary$rhat <- NA_real_
  fit$diagnostics$summary$ess_bulk <- NA_real_
  g <- expect_no_warning(glance(fit))
  expect_true(is.na(g$rhat))
  expect_true(is.na(g$ess))
})
