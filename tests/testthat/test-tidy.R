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

test_that("sig_fig rounds the estimate", {
  t <- tidy(weight_fit, sig_fig = 2)
  expect_equal(t$estimate, signif(t$estimate, 2))
})

test_that("estimate selects the point-estimate function (mean vs median)", {
  tm <- tidy(weight_fit, estimate = mean)
  tmed <- tidy(weight_fit)
  # the mean differs from the default median (right-skewed SD terms at least)
  expect_false(isTRUE(all.equal(tm$estimate, tmed$estimate)))
  # and matches the posterior mean computed independently of tidy()
  bw_mean <- signif(mean(posterior::draws_of(weight_fit$draws$bWeight)), 3)
  expect_equal(tm$estimate[tm$term == "bWeight"], bw_mean)
})

test_that("conf_level widens the interval", {
  wide <- tidy(weight_fit, conf_level = 0.99)
  narrow <- tidy(weight_fit, conf_level = 0.80)
  w <- wide$upper[wide$term == "bWeight"] - wide$lower[wide$term == "bWeight"]
  n <- narrow$upper[narrow$term == "bWeight"] - narrow$lower[narrow$term == "bWeight"]
  expect_gt(w, n)
})
