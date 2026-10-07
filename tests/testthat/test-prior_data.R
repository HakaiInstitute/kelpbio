test_that("prior_data names one field per hyperparameter after entry and argument", {
  out <- prior_data(list(
    intercept = kb_prior_normal(0.1, 1.1),
    sd_site = kb_prior_exponential(2.1),
    cover_slope = kb_prior_lognormal(0.3, 1.3)
  ))
  expect_identical(
    out,
    list(
      prior_intercept_mean = 0.1,
      prior_intercept_sd = 1.1,
      prior_sd_site_rate = 2.1,
      prior_cover_slope_meanlog = 0.3,
      prior_cover_slope_sdlog = 1.3
    )
  )
})

test_that("prior_data returns no fields for no priors", {
  expect_identical(prior_data(list()), list())
})
