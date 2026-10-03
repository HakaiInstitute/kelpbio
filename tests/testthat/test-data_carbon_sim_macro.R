test_that("data_carbon_sim_macro has the expected columns and passes validation", {
  expect_s3_class(data_carbon_sim_macro, "data.frame")
  expect_named(data_carbon_sim_macro, c("sample_mass_mg", "carbon_mass_ug"))
  expect_silent(kb_check_data_carbon_macro(data_carbon_sim_macro))
})
