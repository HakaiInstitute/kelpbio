test_that("fit_wetdry uses the species and default priors it is given", {
  local_mocked_bindings(
    fit_stan = function(...) {
      list(
        draws = wetdry_macro_fit$draws,
        diagnostics = wetdry_macro_fit$diagnostics,
        stancode = ""
      )
    }
  )
  defaults <- kb_priors_wetdry_macro()
  defaults$intercept <- kb_prior_normal(-2, 1)
  fit <- fit_wetdry(
    wetdry_macro_fit$data,
    priors = NULL,
    check_data = kb_check_data_wetdry_macro,
    defaults = defaults,
    species = "macrocystis",
    prior_only = FALSE,
    chains = 1L,
    niters = 10L,
    nthin = 1L,
    cores = 1L,
    seed = 1L,
    progress = "none",
    progress_dir = NULL
  )
  expect_s3_class(fit, "kb_fit_wetdry_macro")
  expect_equal(fit$meta$priors$intercept, kb_prior_normal(-2, 1))
})
