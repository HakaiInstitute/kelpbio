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
  out <- capture.output(print(summary(weight_fit)))
  expect_true(any(grepl("summary_kb_fit", out)))
  expect_true(any(grepl("^Model:", out)))
  expect_false(any(grepl("^Family:", out)))
  expect_false(any(grepl("^Fixed:", out)))
  expect_false(any(grepl("^Random:", out)))
  expect_true(any(grepl("^Draws:", out)))
  expect_true(any(grepl("compatibility limits", out)))
  expect_true(any(grepl("effective sample sizes", out)))
})
