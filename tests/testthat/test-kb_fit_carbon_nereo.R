# Replace the sampler with the stored fixture draws, so the wrapper logic (data
# checks, structure, terms, meta) is tested without MCMC.
local_carbon_nereo_stub <- function(env = parent.frame()) {
  local_mocked_bindings(
    fit_stan = function(...) {
      list(
        draws = carbon_nereo_fit$draws,
        diagnostics = carbon_nereo_fit$diagnostics,
        stancode = ""
      )
    },
    .env = env
  )
}

test_that("kb_fit_carbon_nereo returns a correctly-structured object", {
  skip_on_cran()
  fit <- kb_fit_carbon_nereo(
    data_carbon_sim_nereo[1:40, ],
    chains = 2,
    niters = 100,
    cores = 2,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, c("kb_fit_carbon_nereo", "kb_fit_carbon", "kb_fit"))
  expect_named(fit, c("draws", "diagnostics", "data", "meta"))
  expect_setequal(posterior::variables(fit$draws), c("intercept", "precision"))
  expect_equal(niters(fit), 100L)
})

test_that("the fit records the species, a derived response, and no effects", {
  local_carbon_nereo_stub()
  fit <- kb_fit_carbon_nereo(carbon_nereo_fit$data, progress = "none")
  expect_identical(fit$meta$species, "nereocystis")
  expect_identical(fit$meta$response, "carbon_fraction")
  expect_null(fit$meta$offset)
  expect_null(fit$meta[["predictor"]])
  expect_identical(fit$meta$terms$fixed, c("intercept", "precision"))
  expect_length(fit$meta$terms$random, 0L)
})

test_that("invalid data and priors error before sampling", {
  local_carbon_nereo_stub()
  expect_error(kb_fit_carbon_nereo(data.frame(x = 1)))
  p <- kb_priors_carbon_nereo()
  p$precision <- kb_prior_normal(0, 1)
  expect_error(
    kb_fit_carbon_nereo(carbon_nereo_fit$data, priors = p, progress = "none"),
    "wrong family"
  )
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_carbon_nereo(
    data_carbon_sim_nereo[0, ],
    prior_only = TRUE,
    chains = 1,
    niters = 100,
    cores = 1,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, "kb_fit_carbon_nereo")
})
