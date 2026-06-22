test_that("tidy returns house columns and omits group-level terms by default", {
  t <- tidy(weight_fit)
  expect_s3_class(t, "tbl_df")
  expect_named(t, c("term", "estimate", "lower", "upper"))
  expect_true(all(t$lower <= t$estimate & t$estimate <= t$upper))
  # default include_random_effects = FALSE -> per-level deviations absent
  expect_false(any(grepl("^bSite\\[", t$term)))
  expect_setequal(
    t$term,
    c("bWeight", "bDiameter", "bDiameter2", "sSite", "sSiteDiameter", "sSiteYear", "sWeight")
  )
})

test_that("include_random_effects = TRUE adds the group-level deviations", {
  t <- tidy(weight_fit, include_random_effects = TRUE)
  expect_true(any(grepl("^bSite\\[", t$term)))
})

test_that("estimate and sig_fig are honoured", {
  t <- tidy(weight_fit, estimate = mean, sig_fig = 2, include_random_effects = FALSE)
  expect_named(t, c("term", "estimate", "lower", "upper"))
  # rounded to 2 significant figures
  expect_equal(t$estimate, signif(t$estimate, 2))
})
