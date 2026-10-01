# fit_stan() is the sampling boundary. Standing in the fixture's own draws lets the
# rest of a fit function run without MCMC, for tests of what it derives from the
# data.
local_fit_stan_stub <- function(env = parent.frame()) {
  local_mocked_bindings(
    fit_stan = function(...) {
      list(
        draws = weight_fit$draws,
        diagnostics = weight_fit$diagnostics,
        stancode = ""
      )
    },
    .env = env
  )
}

test_that("kb_fit_weight_nereo does not expose site_year_on", {
  # the site:year structure is data-determined, not a user argument
  expect_false("site_year_on" %in% names(formals(kb_fit_weight_nereo)))
})

test_that("kb_fit_weight returns a correctly-structured object", {
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_nereo,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  fit <- kb_fit_weight_nereo(
    d,
    chains = 2,
    niters = 100,
    nthin = 1,
    cores = 2,
    progress = "none",
    seed = 1
  )

  expect_s3_class(fit, "kb_fit_weight_nereo")
  expect_named(fit, c("draws", "diagnostics", "data", "meta"))
  expect_true(posterior::is_draws_rvars(fit$draws))
  expect_setequal(
    posterior::variables(fit$draws),
    c(
      "bWeight",
      "bPower",
      "bFloor",
      "bDensity",
      "sSite",
      "sYear",
      "sSiteYear",
      "sWeight",
      "bSite",
      "bYear",
      "bSiteYear"
    )
  )
  # niters = saved post-warmup draws per chain
  expect_equal(niters(fit), 100L)
})

test_that("nthin > 1 still keeps exactly niters draws per chain", {
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_nereo,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  # fit_stan sets warmup = niters and total iters = niters + niters * nthin, so
  # the thinned post-warmup phase must land exactly niters draws regardless of
  # nthin. Exercised here with nthin = 2, which the nthin = 1 tests cannot catch.
  fit <- kb_fit_weight_nereo(
    d,
    chains = 1,
    niters = 50,
    nthin = 2,
    cores = 1,
    progress = "none",
    seed = 3
  )
  expect_equal(niters(fit), 50L)
  expect_equal(posterior::ndraws(fit$draws), 50L)
})

test_that("prior_only fit ignores the data", {
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_nereo,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  f1 <- kb_fit_weight_nereo(
    d,
    prior_only = TRUE,
    chains = 1,
    niters = 300,
    nthin = 1,
    cores = 1,
    progress = "none",
    seed = 7
  )
  d2 <- d
  d2$weight <- rev(d2$weight)
  f2 <- kb_fit_weight_nereo(
    d2,
    prior_only = TRUE,
    chains = 1,
    niters = 300,
    nthin = 1,
    cores = 1,
    progress = "none",
    seed = 7
  )
  # likelihood off + same seed => permuting the response leaves the RNG stream
  # untouched, so the full draws are identical, not merely close in one term.
  expect_equal(
    as.matrix(posterior::as_draws_matrix(f1$draws)),
    as.matrix(posterior::as_draws_matrix(f2$draws))
  )
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_weight_nereo(
    data_weight_sim_nereo[0, ],
    prior_only = TRUE,
    chains = 1,
    niters = 100,
    nthin = 1,
    cores = 1,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, "kb_fit_weight")
})

test_that("progress accepts only the three modes", {
  d <- droplevels(subset(
    data_weight_sim_nereo,
    site == "site1" & year == "2019"
  ))
  expect_error(kb_fit_weight_nereo(d, progress = "loud"), "must be one of")
})

test_that("progress_dir writes an artifact that kb_fit_progress reads as complete", {
  # Exercises the background "bar" path (callr subprocess) writing to a
  # caller-supplied progress_dir; the subprocess loads the installed package, so
  # skip on CRAN.
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_nereo,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  # "bar" shows fit messages; without density there is none to print
  d$density <- NULL
  dir <- withr::local_tempdir()
  fit <- kb_fit_weight_nereo(
    d,
    chains = 1,
    niters = 50,
    nthin = 1,
    cores = 1,
    progress = "bar",
    progress_dir = dir,
    seed = 1
  )
  expect_s3_class(fit, "kb_fit_weight")
  # a caller-supplied progress_dir is left in place and reads complete
  expect_true(file.exists(file.path(dir, "manifest.rds")))
  expect_true(length(list.files(dir, pattern = "^samples.*\\.csv$")) >= 1L)
  expect_identical(kb_fit_progress(dir), 1)
})

test_that("a single-year fit records no site:year terms", {
  # site_year_structure() turns the effect off below two years, and the recorded
  # term list must agree, since tidy()/summary() read it rather than re-deriving.
  local_fit_stan_stub()
  d <- droplevels(subset(weight_fit$data, year == "2019"))
  fit <- kb_fit_weight_nereo(d, progress = "none")
  expect_false(fit$meta$site_year_on)
  expect_false("sSiteYear" %in% fit$meta$terms$fixed)
  expect_false("bSiteYear" %in% fit$meta$terms$random)
})

test_that("the fit records the density structure in meta and terms", {
  # Expectations computed directly from the data, not by the fitting helper. In
  # the fixture every row of a recorded site-year carries its density, so the
  # plant-weighted mean and SD are over the non-missing rows.
  d <- weight_fit$data
  recorded <- !is.na(d$density)
  expect_true(weight_fit$meta$density_on)
  expect_equal(weight_fit$meta$density_mean, mean(d$density[recorded]))
  expect_equal(weight_fit$meta$density_sd, stats::sd(d$density[recorded]))

  keys <- paste(d$site, d$year, sep = ":")
  per_site_year <- tapply(d$density[recorded], keys[recorded], unique)
  levels <- weight_fit$meta$density_levels
  expect_setequal(names(levels), names(per_site_year))
  expect_equal(unname(levels[names(per_site_year)]), as.vector(per_site_year))
  expect_true("bDensity" %in% weight_fit$meta$terms$fixed)
})

test_that("data without density give a fit with the density term off", {
  local_fit_stan_stub()
  d <- weight_fit$data
  d$density <- NULL
  fit <- kb_fit_weight_nereo(d, progress = "none")
  expect_false(fit$meta$density_on)
  expect_false("bDensity" %in% fit$meta$terms$fixed)
  expect_false("bDensity" %in% tidy(fit)$term)
})

test_that("the form defaults to packard_floor and power drops the floor", {
  local_fit_stan_stub()
  d <- weight_fit$data
  default <- kb_fit_weight_nereo(d, progress = "none")
  expect_identical(default$meta$form, "packard_floor")
  expect_true("bFloor" %in% default$meta$terms$fixed)

  power <- kb_fit_weight_nereo(d, form = "power", progress = "none")
  expect_identical(power$meta$form, "power")
  expect_false("bFloor" %in% power$meta$terms$fixed)
  expect_false("bFloor" %in% tidy(power)$term)
  expect_false("bFloor" %in% posterior::variables(samples(power)))
})

test_that("an unknown form errors before sampling, naming the forms", {
  local_fit_stan_stub()
  expect_snapshot(
    kb_fit_weight_nereo(weight_fit$data, form = "cubic"),
    error = TRUE
  )
})

test_that("a power-law fit samples and records no floor", {
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_nereo,
    site %in% c("site1", "site2") & year %in% c("2019", "2020")
  ))
  fit <- kb_fit_weight_nereo(
    d,
    form = "power",
    chains = 2,
    niters = 100,
    cores = 2,
    progress = "none",
    seed = 1
  )
  expect_identical(fit$meta$form, "power")
  expect_false("bFloor" %in% tidy(fit)$term)
  expect_true(all(is.finite(log_lik(fit))))
})
