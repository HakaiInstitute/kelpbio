test_that("data_carbon_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_carbon_sim_nereo, "data.frame")
  expect_named(data_carbon_sim_nereo, c("sample_mass_mg", "carbon_mass_ug"))
  expect_silent(kb_check_data_carbon_nereo(data_carbon_sim_nereo))
})
