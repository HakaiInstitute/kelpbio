test_that("data_wetdry_sim_nereo has the expected columns and passes validation", {
  expect_s3_class(data_wetdry_sim_nereo, "data.frame")
  expect_named(data_wetdry_sim_nereo, c("wet_mass_g", "dry_mass_g"))
  expect_silent(kb_check_data_wetdry_nereo(data_wetdry_sim_nereo))
})
