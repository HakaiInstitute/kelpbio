test_that("summary returns a classed object with a coefficient table", {
  s <- summary(weight_nereo_fit)
  expect_s3_class(s, "summary_kb_fit")
  expect_s3_class(s$coefficients, "tbl_df")
  expect_named(
    s$coefficients,
    c("term", "estimate", "lower", "upper", "rhat", "ess_bulk", "ess_tail", "converged")
  )
})

test_that("summary diagnostic columns come from the term's stored diagnostics", {
  fit <- weight_nereo_fit
  i <- match("intercept", fit$diagnostics$summary$variable)
  fit$diagnostics$summary$rhat[i] <- 1.23456
  fit$diagnostics$summary$ess_bulk[i] <- 432.6
  s <- summary(fit)$coefficients
  expect_equal(s$rhat[s$term == "intercept"], 1.235)
  expect_equal(s$ess_bulk[s$term == "intercept"], 433)
})

test_that("rhat and ess set both the column and the header verdict", {
  strict <- summary(weight_nereo_fit, rhat = 1, ess = 1e6)
  expect_false(any(strict$coefficients$converged))
  expect_false(strict$converged)
  loose <- summary(weight_nereo_fit, rhat = 10, ess = 0)
  expect_true(all(loose$coefficients$converged))
  expect_identical(
    loose$converged,
    kb_converged(weight_nereo_fit, rhat = 10, ess = 0)
  )
  expect_identical(c(loose$rhat, loose$ess), c(10, 0))
})

test_that("a term with no Rhat is not judged on it", {
  diag <- data.frame(
    rhat = c(NA, 1.001, 1.2),
    ess_bulk = c(NA, 500, 500),
    ess_tail = c(NA, 500, 500)
  )
  expect_identical(
    .term_converged(diag, rhat = 1.01, min_ess = 400),
    c(TRUE, TRUE, FALSE)
  )
})

test_that("summary validates rhat and ess", {
  expect_error(summary(weight_nereo_fit, rhat = "a"), "rhat")
  expect_error(summary(weight_nereo_fit, ess = -1), "ess")
  expect_error(summary(weight_nereo_fit, 1.05), "must be empty")
})

test_that("summary carries the slim fit metadata (no structure lines)", {
  s <- summary(weight_nereo_fit)
  expect_equal(s$model, "Weight")
  expect_equal(s$species, "Nereocystis luetkeana")
  expect_named(s$groups, c("site", "year", "site:year"))
  expect_equal(s$ndraws, posterior::ndraws(weight_nereo_fit$draws))
  expect_null(s$family)
  expect_null(s$fixed)
  expect_null(s$random)
})

test_that("print.summary_kb_fit shows the slim header, table, and footer", {
  expect_snapshot(print(summary(weight_nereo_fit)), transform = redact_fit_print)
})

test_that("summary carries the run-level diagnostics, not the raw count", {
  s <- summary(weight_nereo_fit)
  diag <- weight_nereo_fit$diagnostics
  expect_equal(s$perc_divergent, diag$perc_divergent)
  expect_equal(s$perc_max_treedepth, diag$perc_max_treedepth)
  expect_equal(s$ebfmi, diag$ebfmi)
})

test_that("fit_groups describes the data, not the fitted effects", {
  # Cover calibration fits no site:year effect, but its data have site-years.
  expect_named(fit_groups(cover_calibration_macro_fit), c("site", "year", "site:year"))
})

test_that("fit_groups is empty for data with no grouping", {
  # As for wet/dry and carbon.
  fit <- weight_nereo_fit
  fit$meta[c("site_levels", "year_levels", "site_year_levels")] <- list(
    character(0),
    character(0),
    character(0)
  )
  expect_identical(fit_groups(fit), integer(0))
})

test_that("argument errors name summary()", {
  err <- expect_error(summary(weight_nereo_fit, conf_level = 2))
  expect_identical(err$call[[1]], quote(summary))
})
