# Direct tests for the shared interval/rounding engine behind tidy()/summary()/
# coef(). Pure logic over a draws_rvars object; uses the cached fixture's draws.

test_that("summarise_draws_terms returns house columns bracketing the estimate", {
  out <- summarise_draws_terms(weight_fit$draws, c("bWeight", "bPower"))
  expect_s3_class(out, "tbl_df")
  expect_named(out, c("term", "estimate", "lower", "upper"))
  expect_setequal(out$term, c("bWeight", "bPower"))
  expect_true(all(out$lower <= out$estimate & out$estimate <= out$upper))
})

test_that("summarise_draws_terms widens the interval with conf_level", {
  wide <- summarise_draws_terms(weight_fit$draws, "bWeight", conf_level = 0.99)
  narrow <- summarise_draws_terms(
    weight_fit$draws,
    "bWeight",
    conf_level = 0.80
  )
  expect_gt(wide$upper - wide$lower, narrow$upper - narrow$lower)
})

test_that("summarise_draws_terms applies the estimate function and sig_fig", {
  mean_est <- summarise_draws_terms(
    weight_fit$draws,
    "bWeight",
    estimate = mean
  )$estimate
  expect_equal(
    mean_est,
    signif(mean(posterior::draws_of(weight_fit$draws$bWeight)), 3)
  )
  two <- summarise_draws_terms(
    weight_fit$draws,
    "bWeight",
    sig_fig = 2
  )$estimate
  expect_equal(two, signif(two, 2))
})
