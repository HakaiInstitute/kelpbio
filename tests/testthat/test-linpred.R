# Tests for the internal .linpred() engine and its by-axis validation.

test_that(".linpred returns a log-scale rvar aligned to the grid", {
  grid <- data.frame(diameter = c(20, 40, 60))
  lp <- .linpred(weight_fit, grid, new_levels = "average")
  expect_s3_class(lp, "rvar")
  expect_length(lp, 3L)
  expect_equal(posterior::ndraws(lp), posterior::ndraws(weight_fit$draws))
})

test_that("conditioning follows the grid columns", {
  site1 <- weight_fit$meta$site_levels[1]
  bare <- data.frame(diameter = c(30, 30))
  with_site <- data.frame(diameter = c(30, 30), site = site1)

  lp_avg <- posterior::draws_of(.linpred(
    weight_fit,
    bare,
    "average"
  ))
  lp_site <- posterior::draws_of(.linpred(
    weight_fit,
    with_site,
    "average"
  ))
  # Conditioning on a specific site shifts the mean off the typical (zeroed)
  # curve, so the two differ.
  expect_false(isTRUE(all.equal(as.numeric(lp_avg), as.numeric(lp_site))))
})

test_that("per-row resolution: known rows conditioned, new rows drawn", {
  site1 <- weight_fit$meta$site_levels[1]
  grid <- data.frame(diameter = c(30, 30), site = c(site1, "brand_new_site"))
  # Must not error on the unknown level.
  expect_no_error(.linpred(
    weight_fit,
    grid,
    new_levels = "sample"
  ))

  # Under "average" the conditioned components are deterministic: the known row
  # matches a single-site call, and the new row matches the typical curve.
  lp_avg <- posterior::draws_of(.linpred(
    weight_fit,
    grid,
    "average"
  ))
  lp_known <- posterior::draws_of(
    .linpred(
      weight_fit,
      data.frame(diameter = 30, site = site1),
      "average"
    )
  )
  lp_typical <- posterior::draws_of(
    .linpred(weight_fit, data.frame(diameter = 30), "average")
  )
  expect_equal(lp_avg[, 1], lp_known[, 1])
  expect_equal(lp_avg[, 2], lp_typical[, 1])
})

test_that("sample widens vs average when a factor is omitted", {
  withr::local_seed(1) # the "sample" path draws random effects; pin them
  grid <- data.frame(diameter = c(20, 40, 60))
  sd_avg <- apply(
    posterior::draws_of(.linpred(weight_fit, grid, "average")),
    2,
    stats::sd
  )
  sd_smp <- apply(
    posterior::draws_of(.linpred(weight_fit, grid, "sample")),
    2,
    stats::sd
  )
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

  lp_on <- .linpred(on, grid, "average")
  lp_off <- .linpred(off, grid, "average")
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
  lp_legacy <- posterior::draws_of(.linpred(
    legacy,
    grid,
    "average"
  ))
  lp_on <- posterior::draws_of(.linpred(on, grid, "average"))
  expect_equal(as.numeric(lp_legacy), as.numeric(lp_on))
})

test_that("validate_by_weight enforces the valid by set", {
  # two distinct rejections: year-alone (no main effect) vs an unknown factor
  expect_error(validate_by_weight("year"), "not available")
  expect_error(validate_by_weight("bogus"), "Invalid")
  expect_identical(validate_by_weight(NULL), character(0))
  expect_identical(validate_by_weight("site"), "site")
  expect_identical(validate_by_weight(c("site", "year")), c("site", "year"))
})

# Tests for the internal .linpred() engine and macro by-axis rules.

test_that(".linpred returns a log-scale rvar aligned to the grid", {
  grid <- data.frame(fronds = c(2, 5, 10))
  lp <- .linpred(weight_macro_fit, grid, new_levels = "average")
  expect_s3_class(lp, "rvar")
  expect_length(lp, 3L)
  expect_equal(
    posterior::ndraws(lp),
    posterior::ndraws(weight_macro_fit$draws)
  )
})

test_that("the dispatcher routes a macro fit to the macro builder", {
  grid <- data.frame(fronds = c(2, 5, 10))
  lp_dispatch <- posterior::draws_of(
    .linpred(weight_macro_fit, grid, "average")
  )
  lp_direct <- posterior::draws_of(
    .linpred(weight_macro_fit, grid, "average")
  )
  expect_equal(lp_dispatch, lp_direct)
})

test_that("conditioning follows the grid columns (site and year)", {
  s <- weight_macro_fit$meta$site_levels[1]
  y <- weight_macro_fit$meta$year_levels[1]
  bare <- data.frame(fronds = c(5, 5))
  with_group <- data.frame(fronds = c(5, 5), site = s, year = y)
  lp_avg <- posterior::draws_of(
    .linpred(weight_macro_fit, bare, "average")
  )
  lp_grp <- posterior::draws_of(
    .linpred(weight_macro_fit, with_group, "average")
  )
  expect_false(isTRUE(all.equal(as.numeric(lp_avg), as.numeric(lp_grp))))
})

test_that("a known year contributes its estimated bYear main effect", {
  # macro has a standalone year main effect: conditioning on a known year shifts
  # the mean by exactly that year's bYear draws (site and site:year absent).
  y <- weight_macro_fit$meta$year_levels[1]
  grid_year <- data.frame(fronds = 5, year = y)
  grid_bare <- data.frame(fronds = 5)
  diff <- posterior::draws_of(
    .linpred(weight_macro_fit, grid_year, "average")
  ) -
    posterior::draws_of(
      .linpred(weight_macro_fit, grid_bare, "average")
    )
  yi <- match(y, weight_macro_fit$meta$year_levels)
  byear <- posterior::draws_of(weight_macro_fit$draws$bYear)[, yi]
  expect_equal(as.numeric(diff), as.numeric(byear))
})

test_that("sample widens vs average when a factor is omitted", {
  withr::local_seed(1)
  grid <- data.frame(fronds = c(2, 5, 10))
  sd_avg <- apply(
    posterior::draws_of(
      .linpred(weight_macro_fit, grid, "average")
    ),
    2,
    stats::sd
  )
  sd_smp <- apply(
    posterior::draws_of(.linpred(weight_macro_fit, grid, "sample")),
    2,
    stats::sd
  )
  expect_true(all(sd_smp >= sd_avg))
})

test_that("validate_by_weight allows year alone for macro but not nereo", {
  expect_error(validate_by_weight("year", "nereocystis"), "not available")
  expect_identical(validate_by_weight("year", "macrocystis"), "year")
  expect_identical(
    validate_by_weight(c("site", "year"), "macrocystis"),
    c("site", "year")
  )
  expect_error(validate_by_weight("bogus", "macrocystis"), "Invalid")
})

test_that(".linpred_obs asserts every observed row is a fitted level", {
  # An unmatched level is silently zeroed, so this must abort rather than compute.
  broken <- weight_fit
  broken$data$site <- NULL
  expect_error(.linpred_obs(broken), "no .*site.* column")

  unknown <- weight_fit
  unknown$data$site <- "not_a_fitted_site"
  expect_error(.linpred_obs(unknown), "not fitted levels")
})

test_that(".linpred_obs passes for a well-formed fit", {
  expect_s3_class(.linpred_obs(weight_fit), "rvar")
  expect_s3_class(.linpred_obs(weight_macro_fit), "rvar")
})

test_that("the .linpred default aborts for a fit with no method", {
  expect_error(
    .linpred(structure(list(), class = c("kb_fit_other", "kb_fit")), NULL, "average"),
    "no method for a <kb_fit_other>"
  )
})
