test_that("re_draw draws Normal(0, sd) for each new level", {
  sd_rvar <- posterior::rvar(matrix(rep(2, 100), ncol = 1))
  set.seed(1)
  out <- re_draw(3L, sd_rvar)
  expect_s3_class(out, "rvar")
  expect_length(out, 3L)
})

test_that("resolve_re1 conditions known levels and honours new_levels", {
  param <- posterior::rvar(matrix(rnorm(100 * 3), ncol = 3))
  sd_rvar <- posterior::rvar(matrix(rep(1, 100), ncol = 1))

  # all known -> the estimated effects, untouched
  known <- resolve_re1(param, c(1L, 3L), "average", sd_rvar)
  expect_equal(
    posterior::draws_of(known),
    posterior::draws_of(param)[, c(1L, 3L), drop = FALSE],
    ignore_attr = TRUE
  )

  # unknown under "average" is zeroed; under "sample" it is not
  avg <- resolve_re1(param, c(1L, NA), "average", sd_rvar)
  expect_true(all(posterior::draws_of(avg)[, 2L] == 0))
  set.seed(1)
  smp <- resolve_re1(param, c(1L, NA), "sample", sd_rvar)
  expect_false(all(posterior::draws_of(smp)[, 2L] == 0))
})

test_that("resolve_re1 borrows the per-draw mean of the representative levels", {
  param <- posterior::rvar(matrix(rnorm(100 * 3), ncol = 3))
  sd_rvar <- posterior::rvar(matrix(rep(1, 100), ncol = 1))
  out <- resolve_re1(
    param,
    NA_integer_,
    "average",
    sd_rvar,
    rep_idx = c(1L, 2L)
  )
  expect_equal(
    as.vector(posterior::draws_of(out)),
    rowMeans(posterior::draws_of(param)[, 1:2, drop = FALSE]),
    ignore_attr = TRUE
  )
})

test_that("resolve_re2 conditions only where both indices are known", {
  param <- posterior::rvar(array(rnorm(100 * 2 * 2), dim = c(100, 2, 2)))
  sd_rvar <- posterior::rvar(matrix(rep(1, 100), ncol = 1))
  out <- resolve_re2(param, c(1L, NA), c(1L, 1L), "average", sd_rvar)
  expect_equal(
    posterior::draws_of(out)[, 1L],
    posterior::draws_of(param)[, 1L, 1L],
    ignore_attr = TRUE
  )
  expect_true(all(posterior::draws_of(out)[, 2L] == 0))
})

test_that(".grid_indices matches known levels and NAs the rest", {
  s <- weight_fit$meta$site_levels[1]
  y <- weight_fit$meta$year_levels[1]
  grid <- data.frame(diameter = c(30, 30), site = c(s, "new_site"), year = y)
  ix <- .grid_indices(weight_fit, grid)
  expect_named(ix, c("site", "year", "rep"))
  expect_identical(ix$site, c(1L, NA_integer_))
  expect_identical(ix$year, c(1L, 1L))
  expect_null(ix$rep)
})

test_that(".grid_indices NAs a factor the grid omits entirely", {
  ix <- .grid_indices(weight_fit, data.frame(diameter = c(30, 40)))
  expect_identical(ix$site, rep(NA_integer_, 2L))
  expect_identical(ix$year, rep(NA_integer_, 2L))
})

test_that(".grid_indices resolves representative_site against the fit's levels", {
  sites <- weight_fit$meta$site_levels[1:2]
  ix <- .grid_indices(weight_fit, data.frame(diameter = 30), sites)
  expect_identical(ix$rep, c(1L, 2L))
})

test_that("resolve_re2 draws unknown cells under sample", {
  param <- posterior::rvar(array(rnorm(100 * 2 * 2), dim = c(100, 2, 2)))
  sd_rvar <- posterior::rvar(matrix(rep(1, 100), ncol = 1))
  set.seed(1)
  out <- resolve_re2(param, c(1L, NA), c(1L, 1L), "sample", sd_rvar)
  # the known cell is still conditioned, the unknown one is drawn not zeroed
  expect_equal(
    posterior::draws_of(out)[, 1L],
    posterior::draws_of(param)[, 1L, 1L],
    ignore_attr = TRUE
  )
  expect_false(all(posterior::draws_of(out)[, 2L] == 0))
})
