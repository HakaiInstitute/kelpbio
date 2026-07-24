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

test_that("summary carries the fit metadata", {
  s <- summary(weight_fit)
  expect_equal(s$model, "weight")
  expect_match(s$family, "Student-t")
  expect_match(s$fixed, "log\\(diameter/d0\\)")
  expect_match(s$random, "site:year")
  expect_named(s$groups, c("site", "site:year"))
  expect_equal(s$ndraws, posterior::ndraws(weight_fit$draws))
})

test_that("macro summary carries the Gamma family, term list, and year group", {
  s <- summary(weight_macro_fit)
  expect_equal(s$model, "weight")
  expect_match(s$family, "Gamma")
  expect_match(s$fixed, "log\\(fronds/f0\\)")
  expect_match(s$random, "year")
  expect_named(s$groups, c("site", "year", "site:year"))
  expect_true(all(
    c("bWeight", "bFronds", "alpha", "sSite", "sYear", "sSiteYear") %in%
      s$coefficients$term
  ))
  expect_false(any(grepl("^bYear\\[", s$coefficients$term)))
})

test_that("print.summary_kb_fit shows the header, table, and footer", {
  out <- capture.output(print(summary(weight_fit)))
  expect_true(any(grepl("summary_kb_fit", out)))
  expect_true(any(grepl("^Family:", out)))
  expect_true(any(grepl("^Fixed:", out)))
  expect_true(any(grepl("^Random:", out)))
  expect_true(any(grepl("^Draws:", out)))
  expect_true(any(grepl("compatibility limits", out)))
  expect_true(any(grepl("effective sample sizes", out)))
})
