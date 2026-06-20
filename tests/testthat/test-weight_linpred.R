# Tests for the internal .weight_linpred() engine and its by-axis validation.

test_that(".weight_linpred returns a log-scale rvar aligned to the grid", {
  grid <- data.frame(diameter_mm = c(20, 40, 60))
  lp <- kelpbio:::.weight_linpred(weight_fit, grid, new_levels = "average")
  expect_s3_class(lp, "rvar")
  expect_length(lp, 3L)
  expect_equal(posterior::ndraws(lp), posterior::ndraws(weight_fit$draws))
})

test_that("conditioning follows the grid columns", {
  site1 <- weight_fit$meta$site_levels[1]
  bare <- data.frame(diameter_mm = c(30, 30))
  with_site <- data.frame(diameter_mm = c(30, 30), site = site1)

  lp_avg <- posterior::draws_of(kelpbio:::.weight_linpred(weight_fit, bare, "average"))
  lp_site <- posterior::draws_of(kelpbio:::.weight_linpred(weight_fit, with_site, "average"))
  # Conditioning on a specific site shifts the mean off the typical (zeroed)
  # curve, so the two differ.
  expect_false(isTRUE(all.equal(as.numeric(lp_avg), as.numeric(lp_site))))
})

test_that("per-row resolution: known rows conditioned, new rows drawn", {
  site1 <- weight_fit$meta$site_levels[1]
  grid <- data.frame(diameter_mm = c(30, 30), site = c(site1, "brand_new_site"))
  # Must not error on the unknown level.
  expect_no_error(kelpbio:::.weight_linpred(weight_fit, grid, new_levels = "sample"))

  # Under "average" the conditioned components are deterministic: the known row
  # matches a single-site call, and the new row matches the typical curve.
  lp_avg <- posterior::draws_of(kelpbio:::.weight_linpred(weight_fit, grid, "average"))
  lp_known <- posterior::draws_of(
    kelpbio:::.weight_linpred(weight_fit, data.frame(diameter_mm = 30, site = site1), "average")
  )
  lp_typical <- posterior::draws_of(
    kelpbio:::.weight_linpred(weight_fit, data.frame(diameter_mm = 30), "average")
  )
  expect_equal(lp_avg[, 1], lp_known[, 1])
  expect_equal(lp_avg[, 2], lp_typical[, 1])
})

test_that("sample widens vs average when a factor is omitted", {
  grid <- data.frame(diameter_mm = c(20, 40, 60))
  sd_avg <- apply(posterior::draws_of(kelpbio:::.weight_linpred(weight_fit, grid, "average")), 2, stats::sd)
  sd_smp <- apply(posterior::draws_of(kelpbio:::.weight_linpred(weight_fit, grid, "sample")), 2, stats::sd)
  expect_true(all(sd_smp >= sd_avg))
})

test_that("validate_by_weight enforces the valid by set", {
  expect_error(kelpbio:::validate_by_weight("year"))
  expect_error(kelpbio:::validate_by_weight("bogus"))
  expect_identical(kelpbio:::validate_by_weight(NULL), character(0))
  expect_identical(kelpbio:::validate_by_weight("site"), "site")
  expect_identical(kelpbio:::validate_by_weight(c("site", "year")), c("site", "year"))
})
