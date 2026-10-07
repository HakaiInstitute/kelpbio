test_that("fit_cover_biomass_model builds a fit from the species' check and defaults", {
  local_mocked_bindings(
    fit_stan = function(...) {
      list(
        draws = cover_biomass_nereo_fit$draws,
        diagnostics = cover_biomass_nereo_fit$diagnostics,
        stancode = ""
      )
    }
  )
  fit <- fit_cover_biomass_model(
    cover_surveys(cover_biomass_nereo_fit),
    cover_biomass(cover_biomass_nereo_fit),
    priors = NULL,
    species = "nereocystis",
    check_data = kb_check_data_cover_biomass_nereo,
    defaults = kb_priors_cover_biomass_nereo(),
    conf_level = NULL,
    prior_only = FALSE,
    chains = 2L,
    niters = 100L,
    nthin = 1L,
    cores = 1L,
    seed = NULL,
    progress = "none",
    progress_dir = NULL
  )
  expect_s3_class(fit, "kb_fit_cover_biomass_nereo")
  expect_identical(fit$meta$priors, kb_priors_cover_biomass_nereo())
  expect_identical(
    fit$meta$terms$fixed,
    c("cover_slope", "biomass_floor", "tide_height_slope", "error_scaling", "sd_site", "sd_year")
  )
})
