test_that("summary returns a classed object with a coefficient table", {
  s <- summary(weight_fit)
  expect_s3_class(s, "summary_kb_fit")
  expect_s3_class(s$coefficients, "tbl_df")
  expect_named(
    s$coefficients,
    c("term", "estimate", "lower", "upper", "rhat", "ess_bulk", "ess_tail")
  )
})

test_that("summary excludes group-level deviations by default", {
  s <- summary(weight_fit)
  expect_false(any(grepl("^bSite\\[", s$coefficients$term)))
  # the random-effect SD hyperparameters are always shown
  expect_true(all(
    c("sSite", "sSiteDiameter", "sSiteYear", "sWeight") %in% s$coefficients$term
  ))
})

test_that("summary diagnostic columns agree with the stored diagnostics", {
  s <- summary(weight_fit)
  diag <- weight_fit$diagnostics$summary
  idx <- match(s$coefficients$term, diag$variable)
  expect_equal(s$coefficients$rhat, round(diag$rhat[idx], 3))
  expect_equal(s$coefficients$ess_bulk, round(diag$ess_bulk[idx]))
})

test_that("summary carries the slim fit metadata (no structure lines)", {
  s <- summary(weight_fit)
  expect_equal(s$model, "Weight")
  expect_equal(s$species, "Nereocystis luetkeana")
  expect_named(s$groups, c("site", "site:year"))
  expect_equal(s$ndraws, posterior::ndraws(weight_fit$draws))
  # likelihood family and fixed/random structure moved to kb_model_describe()
  expect_null(s$family)
  expect_null(s$fixed)
  expect_null(s$random)
})

test_that("macro summary carries the term list and year group", {
  s <- summary(weight_macro_fit)
  expect_equal(s$model, "Weight")
  expect_named(s$groups, c("site", "year", "site:year"))
  expect_true(all(
    c("bWeight", "bFronds", "shape", "sSite", "sYear", "sSiteYear") %in%
      s$coefficients$term
  ))
  expect_false(any(grepl("^bYear\\[", s$coefficients$term)))
})

test_that("print.summary_kb_fit shows the slim header, table, and footer", {
  # Snapshotting the print method, with the MCMC numerics redacted: the layout,
  # the term list, the header lines the slim change kept (and the ones it
  # dropped) and the footer prose are all stable, while the estimates, the
  # diagnostics and the data-derived centering value are not and must not be
  # pinned. Redacting them also keeps the snapshot still when a fixture is
  # rebuilt.
  redact <- function(lines) {
    lines <- sub("^(\\s*\\d+ \\S+)\\s+[-0-9.].*$", "\\1 <numerics>", lines)
    lines <- sub("^(Predictor:.*geometric mean,) .*$", "\\1 <value>", lines)
    sub(
      "^[0-9.]+% divergent.*min E-BFMI [0-9.]+\\.$",
      "<n>% divergent transitions; <n>% max-treedepth; min E-BFMI <n>.",
      lines
    )
  }
  expect_snapshot(print(summary(weight_fit)), transform = redact)
})

test_that("summary carries the run-level diagnostics, not the raw count", {
  s <- summary(weight_fit)
  diag <- weight_fit$diagnostics
  expect_equal(s$perc_divergent, diag$perc_divergent)
  expect_equal(s$perc_max_treedepth, diag$perc_max_treedepth)
  expect_equal(s$ebfmi, diag$ebfmi)
})

