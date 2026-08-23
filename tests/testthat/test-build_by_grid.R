test_that("build_by_grid spans the observed predictor range by default", {
  grid <- build_by_grid(weight_fit, character(0))
  expect_named(grid, "diameter")
  expect_equal(nrow(grid), 30L)
  expect_equal(range(grid$diameter), range(weight_fit$data$diameter))
})

test_that("build_by_grid names the predictor column from the fit", {
  grid <- build_by_grid(weight_macro_fit, character(0), values = c(2, 5))
  expect_named(grid, "fronds")
  expect_equal(grid$fronds, c(2, 5))
})

test_that("build_by_grid orders rows by the fit's level order", {
  # not the (arbitrary) row order of fit$data, so curves are drawn consistently
  grid <- build_by_grid(weight_fit, "site", values = c(20, 40))
  expect_identical(levels(grid$site), weight_fit$meta$site_levels)
  expect_false(is.unsorted(as.integer(grid$site)))
  expect_equal(nrow(grid), length(weight_fit$meta$site_levels) * 2L)
})

test_that("build_by_grid crosses only the observed site-year combinations", {
  grid <- build_by_grid(weight_fit, c("site", "year"), values = 30)
  observed <- unique(paste(weight_fit$data$site, weight_fit$data$year))
  expect_setequal(unique(paste(grid$site, grid$year)), observed)
})

test_that("build_by_grid rejects a non-numeric predictor sequence", {
  expect_error(build_by_grid(weight_fit, character(0), values = "a"), "numeric")
})

test_that("a model with no predictor gets a grid of grouping levels alone", {
  # density and mean size have no continuous predictor, so the grid is the
  # grouping factors; the column and row order still follow the fit's levels.
  fit <- weight_fit
  # a model with no predictor has no centering reference either
  fit$meta[c("predictor", "predictor_ref")] <- NULL
  grid <- build_by_grid(fit, "site")
  expect_named(grid, "site")
  expect_identical(levels(grid$site), fit$meta$site_levels)
  expect_equal(nrow(grid), length(fit$meta$site_levels))

  grid2 <- build_by_grid(fit, c("site", "year"))
  expect_named(grid2, c("site", "year"))
  expect_false(is.unsorted(as.integer(grid2$site)))
})

test_that("a model with neither predictor nor grouping gets one population row", {
  # the intercept-only shape (wet/dry, carbon): a single row carrying no columns
  fit <- weight_fit
  fit$meta[c("predictor", "predictor_ref")] <- NULL
  grid <- build_by_grid(fit, character(0))
  expect_equal(nrow(grid), 1L)
  expect_length(names(grid), 0L)
})

test_that("an absent predictor reads as absent, not as predictor_ref", {
  # `$` on a list falls back to partial matching, so fit$meta$predictor returns
  # the numeric predictor_ref when no predictor is recorded. build_by_grid() would
  # then index fit$data by a double. Read exactly.
  meta <- list(predictor_ref = 43.08, site_levels = "a")
  expect_type(meta$predictor, "double")
  expect_null(meta[["predictor"]])

  fit <- weight_fit
  fit$meta[["predictor"]] <- NULL
  expect_no_error(build_by_grid(fit, "site"))
})
