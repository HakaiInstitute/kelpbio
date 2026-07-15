# Tests for the internal .weight_nereo_linpred() engine and its by-axis validation.

test_that(".weight_linpred returns a log-scale rvar aligned to the grid", {
  grid <- data.frame(diameter = c(20, 40, 60))
  lp <- kelpbio:::.weight_nereo_linpred(weight_fit, grid, new_levels = "average")
  expect_s3_class(lp, "rvar")
  expect_length(lp, 3L)
  expect_equal(posterior::ndraws(lp), posterior::ndraws(weight_fit$draws))
})

test_that("conditioning follows the grid columns", {
  site1 <- weight_fit$meta$site_levels[1]
  bare <- data.frame(diameter = c(30, 30))
  with_site <- data.frame(diameter = c(30, 30), site = site1)

  lp_avg <- posterior::draws_of(kelpbio:::.weight_nereo_linpred(weight_fit, bare, "average"))
  lp_site <- posterior::draws_of(kelpbio:::.weight_nereo_linpred(weight_fit, with_site, "average"))
  # Conditioning on a specific site shifts the mean off the typical (zeroed)
  # curve, so the two differ.
  expect_false(isTRUE(all.equal(as.numeric(lp_avg), as.numeric(lp_site))))
})

test_that("per-row resolution: known rows conditioned, new rows drawn", {
  site1 <- weight_fit$meta$site_levels[1]
  grid <- data.frame(diameter = c(30, 30), site = c(site1, "brand_new_site"))
  # Must not error on the unknown level.
  expect_no_error(kelpbio:::.weight_nereo_linpred(weight_fit, grid, new_levels = "sample"))

  # Under "average" the conditioned components are deterministic: the known row
  # matches a single-site call, and the new row matches the typical curve.
  lp_avg <- posterior::draws_of(kelpbio:::.weight_nereo_linpred(weight_fit, grid, "average"))
  lp_known <- posterior::draws_of(
    kelpbio:::.weight_nereo_linpred(weight_fit, data.frame(diameter = 30, site = site1), "average")
  )
  lp_typical <- posterior::draws_of(
    kelpbio:::.weight_nereo_linpred(weight_fit, data.frame(diameter = 30), "average")
  )
  expect_equal(lp_avg[, 1], lp_known[, 1])
  expect_equal(lp_avg[, 2], lp_typical[, 1])
})

test_that("sample widens vs average when a factor is omitted", {
  grid <- data.frame(diameter = c(20, 40, 60))
  sd_avg <- apply(posterior::draws_of(kelpbio:::.weight_nereo_linpred(weight_fit, grid, "average")), 2, stats::sd)
  sd_smp <- apply(posterior::draws_of(kelpbio:::.weight_nereo_linpred(weight_fit, grid, "sample")), 2, stats::sd)
  expect_true(all(sd_smp >= sd_avg))
})

test_that("a dropped site:year effect contributes nothing to the linear predictor", {
  on <- weight_fit
  on$meta$site_year_on <- TRUE
  off <- weight_fit
  off$meta$site_year_on <- FALSE
  s <- weight_fit$meta$site_levels[1]
  y <- weight_fit$meta$year_levels[1]
  grid <- data.frame(diameter = 40, site = s, year = y)

  lp_on <- kelpbio:::.weight_nereo_linpred(on, grid, "average")
  lp_off <- kelpbio:::.weight_nereo_linpred(off, grid, "average")
  diff <- posterior::draws_of(lp_on) - posterior::draws_of(lp_off)

  # removing the term shifts the mean, so the two are not identical
  expect_false(isTRUE(all.equal(as.numeric(diff), rep(0, length(diff)))))
  # and the removed contribution is exactly the conditioned bSiteYear[s, y] draws
  si <- match(s, weight_fit$meta$site_levels)
  yi <- match(y, weight_fit$meta$year_levels)
  bsy <- posterior::draws_of(weight_fit$draws$bSiteYear)[, si, yi]
  expect_equal(as.numeric(diff), as.numeric(bsy))
})

test_that("a fit without the site_year_on flag defaults to keeping site:year", {
  # legacy fits (built before meta$site_year_on was recorded) must not lose the
  # effect: a missing flag is treated as on, matching an explicit TRUE.
  legacy <- weight_fit
  legacy$meta$site_year_on <- NULL
  on <- weight_fit
  on$meta$site_year_on <- TRUE
  grid <- data.frame(
    diameter = 40,
    site = weight_fit$meta$site_levels[1],
    year = weight_fit$meta$year_levels[1]
  )
  lp_legacy <- posterior::draws_of(kelpbio:::.weight_nereo_linpred(legacy, grid, "average"))
  lp_on <- posterior::draws_of(kelpbio:::.weight_nereo_linpred(on, grid, "average"))
  expect_equal(as.numeric(lp_legacy), as.numeric(lp_on))
})

test_that("validate_by_weight enforces the valid by set", {
  # two distinct rejections: year-alone (no main effect) vs an unknown factor
  expect_error(kelpbio:::validate_by_weight("year"), "not available")
  expect_error(kelpbio:::validate_by_weight("bogus"), "Invalid")
  expect_identical(kelpbio:::validate_by_weight(NULL), character(0))
  expect_identical(kelpbio:::validate_by_weight("site"), "site")
  expect_identical(kelpbio:::validate_by_weight(c("site", "year")), c("site", "year"))
})
