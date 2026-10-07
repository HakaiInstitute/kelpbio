test_that("fit_parameters estimates every prior entry and the effects", {
  priors <- kb_priors_size_nereo()
  got <- fit_parameters(priors, GROUP_EFFECTS)
  expect_identical(got$fixed, names(priors))
  expect_identical(got$random, GROUP_EFFECTS)
})

test_that("switched-off parameters are left out", {
  priors <- kb_priors_weight_nereo()
  got <- fit_parameters(
    priors,
    GROUP_EFFECTS,
    off = c(site_year_off(FALSE), "weight_floor")
  )
  expect_false(any(c("sd_site_year", "weight_floor") %in% got$fixed))
  expect_identical(got$random, c("site_effect", "year_effect"))
  expect_identical(site_year_off(TRUE), character(0))
})

test_that("a model without group effects estimates its prior entries", {
  got <- fit_parameters(kb_priors_wetdry_nereo())
  expect_identical(got$fixed, c("intercept", "precision"))
  expect_identical(got$random, character(0))
})
