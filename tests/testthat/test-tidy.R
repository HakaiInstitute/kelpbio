test_that("tidy returns house columns and omits group-level terms by default", {
  t <- tidy(weight_nereo_fit)
  expect_s3_class(t, "tbl_df")
  expect_named(t, c("term", "estimate", "lower", "upper"))
  expect_false(any(grepl("^site_effect\\[", t$term)))
  expect_setequal(
    t$term,
    c(
      "intercept",
      "diameter_power",
      "weight_floor",
      "sd_site",
      "sd_year",
      "sd_site_year",
      "sd_residual"
    )
  )
})

test_that("include_random_effects = TRUE adds the group-level deviations", {
  t <- tidy(weight_nereo_fit, include_random_effects = TRUE)
  expect_true(any(grepl("^site_effect\\[", t$term)))
})

test_that("group-level terms are named by their levels", {
  fit <- weight_nereo_fit
  fit$draws <- label_levels(fit$draws, fit$meta$site_levels, fit$meta$year_levels)
  t <- tidy(fit, include_random_effects = TRUE)
  expect_identical(
    t$term[startsWith(t$term, "site_effect[")],
    paste0("site_effect[", fit$meta$site_levels, "]")
  )
})

test_that("tidy uses the macro term list for a macro fit", {
  t <- tidy(weight_macro_fit)
  expect_named(t, c("term", "estimate", "lower", "upper"))
  expect_setequal(
    t$term,
    c("intercept", "fronds_slope", "shape", "sd_site", "sd_year", "sd_site_year")
  )
  tr <- tidy(weight_macro_fit, include_random_effects = TRUE)
  expect_true(any(grepl("^year_effect\\[", tr$term)))
})

test_that("tidy forwards conf_level/estimate/sig_fig to the summariser", {
  expect_identical(
    tidy(weight_nereo_fit, conf_level = 0.8, estimate = mean, sig_fig = 2),
    summarise_draws_terms(
      weight_nereo_fit$draws,
      variables = weight_nereo_fit$meta$terms$fixed,
      conf_level = 0.8,
      estimate = mean,
      sig_fig = 2
    )
  )
})

test_that("tidy reports exactly the recorded terms, at both levels", {
  off <- omit_terms(weight_nereo_fit, "weight_floor")
  expect_false("weight_floor" %in% tidy(off)$term)
  expect_false(
    "weight_floor" %in% tidy(off, include_random_effects = TRUE)$term
  )
  expect_true("weight_floor" %in% tidy(weight_nereo_fit)$term)
})

test_that("every declared term has draws behind it", {
  # meta$terms is written by hand and could drift; a name with no draws would
  # silently drop a row.
  for (fit in list(weight_nereo_fit, weight_macro_fit)) {
    declared <- c(fit$meta$terms$fixed, fit$meta$terms$random)
    expect_length(setdiff(declared, names(fit$draws)), 0L)
    expect_gt(length(declared), 0L)
  }
})

test_that("argument errors name tidy()", {
  err <- expect_error(tidy(weight_nereo_fit, conf_level = 2))
  expect_identical(err$call[[1]], quote(tidy))
})
