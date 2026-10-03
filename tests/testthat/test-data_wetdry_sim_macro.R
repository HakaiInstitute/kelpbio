test_that("data_wetdry_sim_macro has the expected columns and passes validation", {
  expect_s3_class(data_wetdry_sim_macro, "data.frame")
  expect_named(data_wetdry_sim_macro, c("wet_mass_g", "dry_mass_g"))
  expect_silent(kb_check_data_wetdry_macro(data_wetdry_sim_macro))
})
