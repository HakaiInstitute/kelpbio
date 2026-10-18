test_that("kb_fit_weight_nereo does not expose site_year_on", {
  expect_false("site_year_on" %in% names(formals(kb_fit_weight_nereo)))
})

test_that("kb_fit_weight returns a correctly-structured object", {
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_nereo,
    as.integer(site) <= 2 & year %in% c("2019", "2020")
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
      "intercept",
      "diameter_power",
      "weight_floor",
      "sd_site",
      "sd_year",
      "sd_site_year",
      "sd_residual",
      "site_effect",
      "year_effect",
      "site_year_effect"
    )
  )
  expect_equal(niterations(fit), 100L)
})

test_that("nthin > 1 still keeps exactly niters draws per chain", {
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_nereo,
    as.integer(site) <= 2 & year %in% c("2019", "2020")
  ))
  # nthin = 2 catches a thinning off-by-one that nthin = 1 cannot.
  fit <- kb_fit_weight_nereo(
    d,
    chains = 1,
    niters = 50,
    nthin = 2,
    cores = 1,
    progress = "none",
    seed = 3
  )
  expect_equal(niterations(fit), 50L)
  expect_equal(posterior::ndraws(fit$draws), 50L)
})

test_that("prior_only fit ignores the data", {
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_nereo,
    as.integer(site) <= 2 & year %in% c("2019", "2020")
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
  d2$weight_kg <- rev(d2$weight_kg)
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
  # With the likelihood off and the same seed, the RNG stream is unchanged.
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

test_that("zero-row data error unless prior_only", {
  expect_error(
    kb_fit_weight_nereo(
      data_weight_sim_nereo[0, ],
      progress = "none"
    ),
    "prior_only = TRUE"
  )
})

test_that("progress accepts only the three modes", {
  d <- droplevels(subset(
    data_weight_sim_nereo,
    as.integer(site) == 1 & year == "2019"
  ))
  expect_error(kb_fit_weight_nereo(d, progress = "loud"), "must be one of")
})

test_that("progress_dir writes an artifact that kb_progress reads as complete", {
  # The callr subprocess loads the installed package.
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_nereo,
    as.integer(site) <= 2 & year %in% c("2019", "2020")
  ))
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
  expect_true(file.exists(file.path(dir, "manifest.rds")))
  expect_true(length(list.files(dir, pattern = "^samples.*\\.csv$")) >= 1L)
  expect_identical(kb_progress(dir), 1)
})

test_that("single-year data fit the site:year effect with an aliasing warning", {
  local_fit_stan_stub(weight_nereo_fit)
  d <- droplevels(subset(weight_nereo_fit$data, year == "2019"))
  expect_warning(
    fit <- kb_fit_weight_nereo(d, progress = "none"),
    "cannot be separated from the site effect"
  )
  expect_true(fit$meta$site_year_on)
  expect_true("sd_site_year" %in% fit$meta$terms$fixed)
  expect_true("site_year_effect" %in% fit$meta$terms$random)
})

test_that("the form defaults to packard_floor and power drops the floor", {
  local_fit_stan_stub(weight_nereo_fit)
  d <- weight_nereo_fit$data
  default <- kb_fit_weight_nereo(d, progress = "none")
  expect_identical(default$meta$form, "packard_floor")
  expect_true("weight_floor" %in% default$meta$terms$fixed)

  power <- kb_fit_weight_nereo(d, form = "power", progress = "none")
  expect_identical(power$meta$form, "power")
  expect_false("weight_floor" %in% power$meta$terms$fixed)
  expect_false("weight_floor" %in% tidy(power)$term)
  expect_false("weight_floor" %in% posterior::variables(kb_samples(power)))
})

test_that("an unknown form errors before sampling, naming the forms", {
  local_fit_stan_stub(weight_nereo_fit)
  expect_snapshot(
    kb_fit_weight_nereo(weight_nereo_fit$data, form = "cubic"),
    error = TRUE
  )
})

test_that("a power-law fit samples and records no floor", {
  skip_on_cran()
  d <- droplevels(subset(
    data_weight_sim_nereo,
    as.integer(site) <= 2 & year %in% c("2019", "2020")
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
  expect_false("weight_floor" %in% tidy(fit)$term)
  expect_true(all(is.finite(log_lik(fit))))
})

test_that("data and prior errors name kb_fit_weight_nereo()", {
  local_fit_stan_stub(weight_nereo_fit)
  err <- expect_error(kb_fit_weight_nereo(
      data.frame(site = "a", year = "2020"),
      progress = "none"
  ))
  expect_identical(err$call[[1]], quote(kb_fit_weight_nereo))
  err <- expect_error(kb_fit_weight_nereo(
    data_weight_sim_nereo,
    priors = list(nope = kb_prior_normal(0, 1)),
    progress = "none"
  ))
  expect_identical(err$call[[1]], quote(kb_fit_weight_nereo))
})
