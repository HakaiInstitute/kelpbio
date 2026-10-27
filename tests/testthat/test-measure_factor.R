test_that("measure_factor converts wet to dry, carbon, and nitrogen per draw", {
  ratio <- population_draws(wetdry_nereo_fit)
  expect_identical(measure_factor("wet", NULL, NULL, NULL), 1)
  expect_equal(measure_factor("dry", wetdry_nereo_fit, NULL, NULL), ratio)
  expect_equal(
    measure_factor("carbon", wetdry_nereo_fit, carbon_nereo_fit, NULL, element_scale = 1000),
    ratio * population_draws(carbon_nereo_fit) * 1000
  )
  expect_equal(
    measure_factor("nitrogen", wetdry_nereo_fit, NULL, nitrogen_nereo_fit, element_scale = 1000),
    ratio * population_draws(nitrogen_nereo_fit) * 1000
  )
})
