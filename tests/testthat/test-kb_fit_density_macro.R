# Replace the sampler with the stored fixture draws, so the wrapper logic (data
# checks, structure, terms, meta) is tested without MCMC.
local_density_macro_stub <- function(env = parent.frame()) {
  local_mocked_bindings(
    fit_stan = function(...) {
      list(
        draws = density_macro_fit$draws,
        diagnostics = density_macro_fit$diagnostics,
        stancode = ""
      )
    },
    .env = env
  )
}

test_that("kb_fit_density_macro returns a correctly-structured object", {
  skip_on_cran()
  d <- droplevels(subset(
    data_density_sim_macro,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  fit <- kb_fit_density_macro(
    d,
    chains = 2,
    niters = 100,
    cores = 2,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, c("kb_fit_density_macro", "kb_fit_density", "kb_fit"))
  expect_named(fit, c("draws", "diagnostics", "data", "meta"))
  expect_setequal(
    posterior::variables(fit$draws),
    c(
      "bPlants",
      "bDispersion",
      "sSite",
      "sYear",
      "sSiteYear",
      "bSite",
      "bYear",
      "bSiteYear"
    )
  )
  expect_equal(niters(fit), 100L)
})

test_that("the fit records the species, response, area offset, and no predictor", {
  local_density_macro_stub()
  fit <- kb_fit_density_macro(density_macro_fit$data, progress = "none")
  expect_identical(fit$meta$species, "macrocystis")
  expect_identical(fit$meta$response, "plants")
  expect_identical(fit$meta$offset, "area_m2")
  expect_null(fit$meta[["predictor"]])
  expect_true(fit$meta$site_year_on)
  expect_true("sSiteYear" %in% fit$meta$terms$fixed)
})

test_that("single-year data omit the site:year effect with a message", {
  local_density_macro_stub()
  d <- droplevels(subset(density_macro_fit$data, year == "2019"))
  expect_message(fit <- kb_fit_density_macro(d), "site:year effect is omitted")
  expect_false(fit$meta$site_year_on)
  expect_false("sSiteYear" %in% fit$meta$terms$fixed)
  expect_false("bSiteYear" %in% fit$meta$terms$random)
})

test_that("invalid data and priors error before sampling", {
  local_density_macro_stub()
  expect_error(kb_fit_density_macro(data.frame(site = "a", year = "2020")))
  p <- kb_priors_density_macro()
  p$sd_site <- kb_prior_normal(0, 1)
  expect_error(
    kb_fit_density_macro(density_macro_fit$data, priors = p, progress = "none"),
    "wrong family"
  )
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_density_macro(
    data_density_sim_macro[0, ],
    prior_only = TRUE,
    chains = 1,
    niters = 100,
    cores = 1,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, "kb_fit_density_macro")
})
