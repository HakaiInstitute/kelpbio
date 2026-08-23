test_that("tidy returns house columns and omits group-level terms by default", {
  t <- tidy(weight_fit)
  expect_s3_class(t, "tbl_df")
  expect_named(t, c("term", "estimate", "lower", "upper"))
  # default include_random_effects = FALSE -> per-level deviations absent
  expect_false(any(grepl("^bSite\\[", t$term)))
  expect_setequal(
    t$term,
    c(
      "bWeight",
      "bDiameter",
      "bDiameter2",
      "sSite",
      "sSiteDiameter",
      "sSiteYear",
      "sWeight"
    )
  )
})

test_that("include_random_effects = TRUE adds the group-level deviations", {
  t <- tidy(weight_fit, include_random_effects = TRUE)
  expect_true(any(grepl("^bSite\\[", t$term)))
})

test_that("tidy uses the macro term list for a macro fit", {
  t <- tidy(weight_macro_fit)
  expect_named(t, c("term", "estimate", "lower", "upper"))
  expect_setequal(
    t$term,
    c("bWeight", "bFronds", "shape", "sSite", "sYear", "sSiteYear")
  )
  # the year main effect appears among the per-level deviations
  tr <- tidy(weight_macro_fit, include_random_effects = TRUE)
  expect_true(any(grepl("^bYear\\[", tr$term)))
})

test_that("tidy forwards conf_level/estimate/sig_fig to the summariser", {
  # behaviour is proven in test-summarise.R; here just confirm each arg is passed
  wide <- tidy(weight_fit, conf_level = 0.99)
  narrow <- tidy(weight_fit, conf_level = 0.80)
  i <- match("bWeight", wide$term)
  expect_gt(wide$upper[i] - wide$lower[i], narrow$upper[i] - narrow$lower[i])
  expect_false(isTRUE(all.equal(
    tidy(weight_fit, estimate = mean)$estimate,
    tidy(weight_fit)$estimate
  )))
  t2 <- tidy(weight_fit, sig_fig = 2)
  expect_equal(t2$estimate, signif(t2$estimate, 2))
})

test_that("the internal generic's default aborts for a fit with no method", {
  # The only guard once the public method accepts any kb_fit.
  expect_error(
    .terms(structure(list(), class = c("kb_fit_other", "kb_fit")), FALSE),
    "no method for a <kb_fit_other>"
  )
})

test_that("a dropped site:year effect is not reported as an estimate", {
  # Its draws never met the likelihood, so they are the prior, not a posterior.
  fits <- list(nereo = weight_fit, macro = weight_macro_fit)
  for (species in names(fits)) {
    fit <- fits[[species]]
    off <- fit
    off$meta$site_year_on <- FALSE
    expect_false("sSiteYear" %in% tidy(off)$term, info = species)
    expect_false(
      any(startsWith(
        tidy(off, include_random_effects = TRUE)$term,
        "bSiteYear"
      )),
      info = species
    )
    # and it is still reported when the fit kept the effect
    expect_true("sSiteYear" %in% tidy(fit)$term, info = species)
  }
})
