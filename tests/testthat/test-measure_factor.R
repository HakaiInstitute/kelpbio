test_that("measure_factor converts wet to dry and carbon per draw", {
  ratio <- population_draws(wetdry_nereo_fit)
  fraction <- population_draws(carbon_nereo_fit)
  expect_identical(measure_factor("wet", NULL, NULL), 1)
  expect_equal(measure_factor("dry", wetdry_nereo_fit, NULL), ratio)
  expect_equal(
    measure_factor("carbon", wetdry_nereo_fit, carbon_nereo_fit, carbon_scale = 1000),
    ratio * fraction * 1000
  )
})
