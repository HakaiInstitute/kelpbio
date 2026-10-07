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

  known <- resolve_re1(param, c(1L, 3L), "average", sd_rvar)
  expect_equal(
    posterior::draws_of(known),
    posterior::draws_of(param)[, c(1L, 3L), drop = FALSE],
    ignore_attr = TRUE
  )

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
  out <- resolve_re2(param, c(1L, NA), c(1L, 1L), TRUE, "average", sd_rvar)
  expect_equal(
    posterior::draws_of(out)[, 1L],
    posterior::draws_of(param)[, 1L, 1L],
    ignore_attr = TRUE
  )
  expect_true(all(posterior::draws_of(out)[, 2L] == 0))
})

test_that("resolve_re2 treats a fitted site and year never observed together as new", {
  param <- posterior::rvar(array(rnorm(100 * 2 * 2), dim = c(100, 2, 2)))
  sd_rvar <- posterior::rvar(matrix(rep(1, 100), ncol = 1))
  out <- resolve_re2(param, c(1L, 2L), c(1L, 2L), c(TRUE, FALSE), "average", sd_rvar)
  expect_equal(
    posterior::draws_of(out)[, 1L],
    posterior::draws_of(param)[, 1L, 1L],
    ignore_attr = TRUE
  )
  expect_true(all(posterior::draws_of(out)[, 2L] == 0))
})

test_that("resolve_re2 takes each known cell from its own site and year", {
  param <- posterior::rvar(array(rnorm(100 * 3 * 2), dim = c(100, 3, 2)))
  sd_rvar <- posterior::rvar(matrix(rep(1, 100), ncol = 1))
  out <- resolve_re2(param, c(3L, 2L), c(1L, 2L), TRUE, "average", sd_rvar)
  draws <- posterior::draws_of(param)
  expect_equal(posterior::draws_of(out)[, 1L], draws[, 3L, 1L], ignore_attr = TRUE)
  expect_equal(posterior::draws_of(out)[, 2L], draws[, 2L, 2L], ignore_attr = TRUE)
})

test_that(".grid_indices matches known levels and NAs the rest", {
  s <- weight_nereo_fit$meta$site_levels[1]
  y <- weight_nereo_fit$meta$year_levels[1]
  grid <- data.frame(diameter_mm = c(30, 30), site = c(s, "new_site"), year = y)
  ix <- .grid_indices(weight_nereo_fit, grid)
  expect_named(ix, c("site", "year", "rep"))
  expect_identical(as.vector(ix$site), c(1L, NA_integer_))
  expect_identical(as.vector(ix$year), c(1L, 1L))
  expect_identical(attr(ix$site, "labels"), c(s, "new_site"))
  expect_null(ix$rep)
})

test_that(".grid_indices NAs a factor the grid omits entirely", {
  ix <- .grid_indices(weight_nereo_fit, data.frame(diameter_mm = c(30, 40)))
  expect_identical(as.vector(ix$site), rep(NA_integer_, 2L))
  expect_identical(as.vector(ix$year), rep(NA_integer_, 2L))
  expect_identical(attr(ix$site, "labels"), rep(NA_character_, 2L))
})

test_that(".grid_indices resolves representative_site against the fit's levels", {
  sites <- weight_nereo_fit$meta$site_levels[1:2]
  ix <- .grid_indices(weight_nereo_fit, data.frame(diameter_mm = 30), sites)
  expect_identical(ix$rep, c(1L, 2L))
})

test_that("resolve_re2 draws unknown cells under sample", {
  param <- posterior::rvar(array(rnorm(100 * 2 * 2), dim = c(100, 2, 2)))
  sd_rvar <- posterior::rvar(matrix(rep(1, 100), ncol = 1))
  set.seed(1)
  out <- resolve_re2(param, c(1L, NA), c(1L, 1L), TRUE, "sample", sd_rvar)
  expect_equal(
    posterior::draws_of(out)[, 1L],
    posterior::draws_of(param)[, 1L, 1L],
    ignore_attr = TRUE
  )
  expect_false(all(posterior::draws_of(out)[, 2L] == 0))
})

test_that("rows naming the same new level share one sampled effect", {
  withr::local_seed(1)
  param <- posterior::rvar(matrix(rnorm(200), nrow = 100))
  sd <- posterior::rvar(rep(1, 100))
  idx <- structure(c(1L, NA, NA, NA), labels = c("a", "new", "new", "other"))
  out <- posterior::draws_of(resolve_re1(param, idx, "sample", sd))
  expect_identical(out[, 2], out[, 3])
  expect_false(identical(out[, 2], out[, 4]))
})

test_that("rows with no grouping label draw independently", {
  withr::local_seed(1)
  param <- posterior::rvar(matrix(rnorm(200), nrow = 100))
  sd <- posterior::rvar(rep(1, 100))
  out <- posterior::draws_of(resolve_re1(param, c(NA_integer_, NA_integer_), "sample", sd))
  expect_false(identical(out[, 1], out[, 2]))
})

test_that("a new site:year cell is shared only when both labels are named", {
  withr::local_seed(1)
  param <- posterior::rvar(array(rnorm(400), dim = c(100, 2, 2)))
  sd <- posterior::rvar(rep(1, 100))
  i <- structure(rep(NA_integer_, 3), labels = c("new", "new", "new"))
  j <- structure(rep(NA_integer_, 3), labels = c("2030", "2030", NA))
  out <- posterior::draws_of(resolve_re2(param, i, j, FALSE, "sample", sd))
  expect_identical(out[, 1], out[, 2])
  expect_false(identical(out[, 1], out[, 3]))
})
