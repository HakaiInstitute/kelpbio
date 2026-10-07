test_that("mean plant weight averages the weight model's expected weight", {
  site <- fitted_sites(weight_nereo_fit)
  row <- tibble::tibble(site = site, year = "2019", stipes_m2 = 3)
  nd <- posterior::ndraws(weight_nereo_fit$draws)
  sizes <- matrix(rep(c(20, 40), each = nd), nrow = nd)
  effects <- as.vector(posterior::draws_of(
    .group_effects(weight_nereo_fit, row, "average", NULL)
  ))
  got <- mean_plant_weight(weight_nereo_fit, row, sizes, effects)
  expected <- rowMeans(posterior_epred(
    weight_nereo_fit,
    data.frame(site = site, year = "2019", stipes_m2 = 3, diameter_mm = c(20, 40)),
    new_levels = "average"
  ))
  expect_equal(got, expected)
})

test_that("the supplied effects are every plant's group effects", {
  row <- tibble::tibble(site = "new", year = weight_macro_fit$meta$year_levels[1])
  nd <- posterior::ndraws(weight_macro_fit$draws)
  sizes <- matrix(rep(c(3, 8), each = nd), nrow = nd)
  base <- mean_plant_weight(weight_macro_fit, row, sizes, rep(0, nd))
  # The Macrocystis mean is log-linear, so a shift in the effects scales it.
  shifted <- mean_plant_weight(weight_macro_fit, row, sizes, rep(0.5, nd))
  expect_equal(shifted, base * exp(0.5))
})
