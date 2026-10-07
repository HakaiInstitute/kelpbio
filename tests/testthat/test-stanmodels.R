test_that("stanmodels$weight_nereo is a compiled Stan model", {
  skip_on_cran()
  expect_s4_class(stanmodels$weight_nereo, "stanmodel")
})

test_that("stanmodels$weight_macro is a compiled Stan model", {
  skip_on_cran()
  expect_s4_class(stanmodels$weight_macro, "stanmodel")
})

test_that("stanmodels$size_nereo and size_macro are compiled Stan models", {
  skip_on_cran()
  expect_s4_class(stanmodels$size_nereo, "stanmodel")
  expect_s4_class(stanmodels$size_macro, "stanmodel")
})

test_that("stanmodels$density_nereo and density_macro are compiled Stan models", {
  skip_on_cran()
  expect_s4_class(stanmodels$density_nereo, "stanmodel")
  expect_s4_class(stanmodels$density_macro, "stanmodel")
})

test_that("stanmodels$wetdry is a compiled Stan model", {
  skip_on_cran()
  expect_s4_class(stanmodels$wetdry, "stanmodel")
})

test_that("stanmodels$carbon is a compiled Stan model", {
  skip_on_cran()
  expect_s4_class(stanmodels$carbon, "stanmodel")
})

test_that("stanmodels$cover_biomass is a compiled Stan model", {
  skip_on_cran()
  expect_s4_class(stanmodels$cover_biomass, "stanmodel")
})
