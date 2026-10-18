test_that("derived_response names the measure and the scale", {
  expect_identical(derived_response("wet", TRUE), "biomass_kg_m2")
  expect_identical(derived_response("carbon", TRUE), "carbon_biomass_g_m2")
  expect_identical(derived_response("dry", FALSE), "dry_biomass_kg")
  expect_identical(derived_response("carbon", FALSE), "carbon_biomass_kg")
})
