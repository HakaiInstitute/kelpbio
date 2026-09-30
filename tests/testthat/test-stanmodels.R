# The Stan models compile at install and are exposed through stanmodels. That the
# models sample and declare the stored parameters is covered by the fit tests,
# whose draws are subset to the declared parameters.

test_that("stanmodels$weight_nereo is a compiled Stan model", {
  skip_on_cran()
  expect_s4_class(stanmodels$weight_nereo, "stanmodel")
})

test_that("stanmodels$weight_macro is a compiled Stan model", {
  skip_on_cran()
  expect_s4_class(stanmodels$weight_macro, "stanmodel")
})
