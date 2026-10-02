# Replace the sampler with the stored fixture draws, so the wrapper logic (data
# checks, structure, terms, meta) is tested without MCMC.
local_size_nereo_stub <- function(env = parent.frame()) {
  local_mocked_bindings(
    fit_stan = function(...) {
      list(
        draws = size_nereo_fit$draws,
        diagnostics = size_nereo_fit$diagnostics,
        stancode = ""
      )
    },
    .env = env
  )
}

test_that("kb_fit_size_nereo returns a correctly-structured object", {
  skip_on_cran()
  d <- droplevels(subset(
    data_size_sim_nereo,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  fit <- kb_fit_size_nereo(
    d,
    chains = 2,
    niters = 100,
    cores = 2,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, c("kb_fit_size_nereo", "kb_fit_size", "kb_fit"))
  expect_named(fit, c("draws", "diagnostics", "data", "meta"))
  expect_setequal(
    posterior::variables(fit$draws),
    c("bDiameter", "bShape", "sSite", "sYear", "sSiteYear", "bSite", "bYear", "bSiteYear")
  )
  expect_equal(niters(fit), 100L)
})

test_that("the fit records the species, response, and no predictor", {
  local_size_nereo_stub()
  fit <- kb_fit_size_nereo(size_nereo_fit$data, progress = "none")
  expect_identical(fit$meta$species, "nereocystis")
  expect_identical(fit$meta$response, "diameter_mm")
  expect_null(fit$meta[["predictor"]])
  expect_null(fit$meta$offset)
  expect_true(fit$meta$site_year_on)
  expect_true("sSiteYear" %in% fit$meta$terms$fixed)
})

test_that("single-year data omit the site:year effect with a message", {
  local_size_nereo_stub()
  d <- droplevels(subset(size_nereo_fit$data, year == "2019"))
  expect_message(fit <- kb_fit_size_nereo(d), "site:year effect is omitted")
  expect_false(fit$meta$site_year_on)
  expect_false("sSiteYear" %in% fit$meta$terms$fixed)
  expect_false("bSiteYear" %in% fit$meta$terms$random)
})

test_that("invalid data and priors error before sampling", {
  local_size_nereo_stub()
  expect_error(kb_fit_size_nereo(data.frame(site = "a", year = "2020")))
  p <- kb_priors_size_nereo()
  p$sd_site <- kb_prior_normal(0, 1)
  expect_error(
    kb_fit_size_nereo(size_nereo_fit$data, priors = p, progress = "none"),
    "wrong family"
  )
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_size_nereo(
    data_size_sim_nereo[0, ],
    prior_only = TRUE,
    chains = 1,
    niters = 100,
    cores = 1,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, "kb_fit_size_nereo")
})
