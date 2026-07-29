test_that("kb_model_describe renders the nereo notation block", {
  expect_snapshot(kb_model_describe(weight_fit))
})

test_that("kb_model_describe renders the macro notation block", {
  expect_snapshot(kb_model_describe(weight_macro_fit))
})

test_that("kb_model_describe renders a methods paragraph with prose = TRUE", {
  expect_snapshot(kb_model_describe(weight_fit, prose = TRUE))
})

test_that("the notation uses package parameter names and the stored priors", {
  out <- capture.output(kb_model_describe(weight_fit))
  # equation symbols match the coefficient-table terms
  expect_true(any(grepl("bDiameter", out)))
  expect_true(any(grepl("sSite", out)))
  # priors rendered from the fit's stored priors
  expect_true(any(grepl("Normal\\(", out)))
  expect_true(any(grepl("Exponential\\(", out)))
})

test_that("custom stored priors are reflected", {
  fit <- weight_macro_fit
  fit$meta$priors$fronds <- kb_prior_normal(mean = 1.5, sd = 0.05)
  out <- capture.output(kb_model_describe(fit))
  expect_true(any(grepl("Normal\\(1.5, 0.05\\)", out)))
})

test_that("a dropped site:year effect is omitted from the description", {
  fit <- weight_fit
  fit$meta$site_year_on <- FALSE
  out <- capture.output(kb_model_describe(fit))
  expect_false(any(grepl("SiteYear", out)))
})

test_that("prose = TRUE returns the lines invisibly", {
  expect_invisible(kb_model_describe(weight_fit, prose = TRUE))
  expect_type(
    withVisible(kb_model_describe(weight_fit))$value,
    "character"
  )
})

test_that("a non-weight fit errors", {
  fake <- structure(list(), class = c("kb_fit_other", "kb_fit"))
  expect_error(kb_model_describe(fake), "not defined")
})
