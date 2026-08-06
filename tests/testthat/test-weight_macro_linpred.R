# Tests for the internal .weight_linpred() engine and macro by-axis rules.

test_that(".weight_linpred returns a log-scale rvar aligned to the grid", {
  grid <- data.frame(fronds = c(2, 5, 10))
  lp <- .weight_linpred(weight_macro_fit, grid, new_levels = "average")
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
    .weight_linpred(weight_macro_fit, grid, "average")
  )
  lp_direct <- posterior::draws_of(
    .weight_linpred(weight_macro_fit, grid, "average")
  )
  expect_equal(lp_dispatch, lp_direct)
})

test_that("conditioning follows the grid columns (site and year)", {
  s <- weight_macro_fit$meta$site_levels[1]
  y <- weight_macro_fit$meta$year_levels[1]
  bare <- data.frame(fronds = c(5, 5))
  with_group <- data.frame(fronds = c(5, 5), site = s, year = y)
  lp_avg <- posterior::draws_of(
    .weight_linpred(weight_macro_fit, bare, "average")
  )
  lp_grp <- posterior::draws_of(
    .weight_linpred(weight_macro_fit, with_group, "average")
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
    .weight_linpred(weight_macro_fit, grid_year, "average")
  ) -
    posterior::draws_of(
      .weight_linpred(weight_macro_fit, grid_bare, "average")
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
      .weight_linpred(weight_macro_fit, grid, "average")
    ),
    2,
    stats::sd
  )
  sd_smp <- apply(
    posterior::draws_of(.weight_linpred(weight_macro_fit, grid, "sample")),
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
