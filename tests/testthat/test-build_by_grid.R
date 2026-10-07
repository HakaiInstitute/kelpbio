test_that("build_by_grid spans the observed predictor range by default", {
  grid <- build_by_grid(weight_nereo_fit, character(0))
  expect_named(grid, "diameter_mm")
  expect_equal(nrow(grid), 30L)
  expect_equal(range(grid$diameter_mm), range(weight_nereo_fit$data$diameter_mm))
})

test_that("build_by_grid names the predictor column from the fit", {
  grid <- build_by_grid(weight_macro_fit, character(0), values = c(2, 5))
  expect_named(grid, "fronds")
  expect_equal(grid$fronds, c(2, 5))
})

test_that("build_by_grid orders rows by the fit's level order", {
  grid <- build_by_grid(weight_nereo_fit, "site", values = c(20, 40))
  expect_identical(levels(grid$site), weight_nereo_fit$meta$site_levels)
  expect_false(is.unsorted(as.integer(grid$site)))
  expect_equal(nrow(grid), length(weight_nereo_fit$meta$site_levels) * 2L)
})

test_that("build_by_grid crosses only the observed site-year combinations", {
  grid <- build_by_grid(weight_nereo_fit, c("site", "year"), values = 30)
  observed <- unique(paste(weight_nereo_fit$data$site, weight_nereo_fit$data$year))
  expect_setequal(unique(paste(grid$site, grid$year)), observed)
})

test_that("a model with no predictor gets a grid of grouping levels alone", {
  fit <- weight_nereo_fit
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
  fit <- weight_nereo_fit
  fit$meta[c("predictor", "predictor_ref")] <- NULL
  grid <- build_by_grid(fit, character(0))
  expect_equal(nrow(grid), 1L)
  expect_length(names(grid), 0L)
})

test_that("an absent predictor reads as absent, not as predictor_ref", {
  # `$` partial matching would return predictor_ref.
  fit <- weight_nereo_fit
  fit$meta[["predictor"]] <- NULL
  expect_no_error(build_by_grid(fit, "site"))
})
