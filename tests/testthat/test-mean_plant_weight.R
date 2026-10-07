test_that("mean plant weight averages the weight model's expected weight", {
  site <- fitted_sites(weight_fit)
  row <- tibble::tibble(site = site, year = "2019", stipes_m2 = 3)
  nd <- posterior::ndraws(weight_fit$draws)
  sizes <- matrix(rep(c(20, 40), each = nd), nrow = nd)
  got <- mean_plant_weight(weight_fit, row, sizes, "average", NULL)
  expected <- rowMeans(posterior_epred(
    weight_fit,
    data.frame(site = site, year = "2019", stipes_m2 = 3, diameter_mm = c(20, 40)),
    new_levels = "average"
  ))
  expect_equal(got, expected)
})

test_that("plants of a new site share one sampled site effect", {
  row <- tibble::tibble(site = "new", year = weight_macro_fit$meta$year_levels[1])
  nd <- posterior::ndraws(weight_macro_fit$draws)
  withr::local_seed(1)
  one <- mean_plant_weight(weight_macro_fit, row, matrix(5, nd, 1), "sample", NULL)
  withr::local_seed(2)
  many <- mean_plant_weight(weight_macro_fit, row, matrix(5, nd, 50), "sample", NULL)
  # With a shared effect, 50 identical plants vary across draws as one plant
  # does; independent effects would average much of that variation away.
  expect_gt(stats::sd(log(many)) / stats::sd(log(one)), 0.8)
})
