test_that("summary returns a classed object with a coefficient table", {
  s <- summary(weight_nereo_fit)
  expect_s3_class(s, "summary_kb_fit")
  expect_s3_class(s$coefficients, "tbl_df")
  expect_named(
    s$coefficients,
    c("term", "estimate", "lower", "upper", "rhat", "ess_bulk", "ess_tail", "converged")
  )
})

test_that("summary diagnostic columns agree with the stored diagnostics", {
  s <- summary(weight_nereo_fit)
  diag <- weight_nereo_fit$diagnostics$summary
  idx <- match(s$coefficients$term, diag$variable)
  expect_equal(s$coefficients$rhat, round(diag$rhat[idx], 3))
  expect_equal(s$coefficients$ess_bulk, round(diag$ess_bulk[idx]))
})

test_that("converged applies the kb_converged() thresholds to each term", {
  s <- summary(weight_nereo_fit)
  diag <- weight_nereo_fit$diagnostics$summary
  d <- diag[match(s$coefficients$term, diag$variable), ]
  min_ess <- 100 * posterior::nchains(weight_nereo_fit$draws)
  expect_type(s$coefficients$converged, "logical")
  expect_identical(
    s$coefficients$converged,
    d$rhat < 1.01 & d$ess_bulk >= min_ess & d$ess_tail >= min_ess
  )
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

test_that("macro summary carries the term list and year group", {
  s <- summary(weight_macro_fit)
  expect_equal(s$model, "Weight")
  expect_named(s$groups, c("site", "year", "site:year"))
  expect_true(all(
    c("intercept", "fronds_slope", "shape", "sd_site", "sd_year", "sd_site_year") %in%
      s$coefficients$term
  ))
  expect_false(any(grepl("^year_effect\\[", s$coefficients$term)))
})

test_that("print.summary_kb_fit shows the slim header, table, and footer", {
  # MCMC numerics and the data-derived reference value are redacted so the
  # snapshot survives fixture rebuilds.
  redact <- function(lines) {
    lines <- sub("^(\\s*\\d+ \\S+)\\s+[-0-9.].*$", "\\1 <numerics>", lines)
    lines <- sub("^(Predictor: [a-z_]+, reference) [0-9.]+", "\\1 <value>", lines)
    sub(
      "^[0-9.]+% divergent.*min E-BFMI [0-9.]+\\.$",
      "<n>% divergent transitions; <n>% max-treedepth; min E-BFMI <n>.",
      lines
    )
  }
  expect_snapshot(print(summary(weight_nereo_fit)), transform = redact)
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
