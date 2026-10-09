surveys <- function() cover_surveys(cover_biomass_nereo_fit)
biomass <- function() cover_biomass(cover_biomass_nereo_fit)

test_that("kb_fit_cover_biomass_nereo returns a correctly-structured object", {
  skip_on_cran()
  keep <- function(d) {
    droplevels(subset(
      d,
      as.integer(site) <= 3 & year %in% c("2019", "2020")
    ))
  }
  fit <- kb_fit_cover_biomass_nereo(
    keep(data_cover_biomass_sim_nereo),
    keep(data_plot_biomass_sim_nereo),
    chains = 2,
    niters = 100,
    cores = 2,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, c("kb_fit_cover_biomass_nereo", "kb_fit_cover_biomass", "kb_fit"))
  expect_named(fit, c("draws", "diagnostics", "data", "meta"))
  expect_setequal(
    posterior::variables(fit$draws),
    c(
      "cover_slope",
      "biomass_floor",
      "tide_height_slope",
      "error_scaling",
      "sd_site",
      "sd_year",
      "site_effect",
      "year_effect"
    )
  )
  expect_equal(niterations(fit), 100L)
})

test_that("the fit records the species, response, predictor, interval level, and no site:year", {
  local_fit_stan_stub(cover_biomass_nereo_fit)
  fit <- kb_fit_cover_biomass_nereo(surveys(), biomass(), progress = "none")
  expect_identical(fit$meta$species, "nereocystis")
  expect_identical(fit$meta$response, "biomass_kg_m2")
  expect_null(fit$meta$offset)
  # curves run over tide-corrected cover, which the data do not hold
  expect_identical(fit$meta[["predictor"]], "cover")
  expect_identical(fit$meta$predictor_range, c(0, 1))
  expect_identical(fit$meta$conf_level, 0.95)
  expect_false(fit$meta$site_year_on)
  expect_identical(fit$meta$terms$random, c("site_effect", "year_effect"))
})

test_that("the fit stores the surveys paired with their biomass", {
  local_fit_stan_stub(cover_biomass_nereo_fit)
  fit <- kb_fit_cover_biomass_nereo(surveys(), biomass(), progress = "none")
  expect_equal(fit$data, cover_biomass_nereo_fit$data, ignore_attr = TRUE)
})

test_that("surveys without biomass are dropped with a message", {
  local_fit_stan_stub(cover_biomass_nereo_fit)
  b <- biomass()[-1, ]
  expect_snapshot(fit <- kb_fit_cover_biomass_nereo(surveys(), b))
  expect_equal(nobs(fit), nrow(surveys()) - 1L)
  expect_no_message(kb_fit_cover_biomass_nereo(surveys(), b, progress = "none"))
  expect_error(
    kb_fit_cover_biomass_nereo(surveys(), transform(biomass(), year = paste0("x", year))),
    "No survey"
  )
})

test_that("multi-year data fit no site:year effect and raise no site:year message", {
  local_fit_stan_stub(cover_biomass_nereo_fit)
  expect_no_message(kb_fit_cover_biomass_nereo(surveys(), biomass()))
})

test_that("conf_level comes from the biomass, the argument, or 0.95", {
  local_fit_stan_stub(cover_biomass_nereo_fit)
  fit <- kb_fit_cover_biomass_nereo(
    surveys(),
    biomass(),
    conf_level = 0.9,
    progress = "none"
  )
  expect_identical(fit$meta$conf_level, 0.9)
  recorded <- structure(biomass(), kb_conf_level = 0.8)
  fit <- kb_fit_cover_biomass_nereo(surveys(), recorded, progress = "none")
  expect_identical(fit$meta$conf_level, 0.8)
  expect_error(
    kb_fit_cover_biomass_nereo(surveys(), recorded, conf_level = 0.95, progress = "none"),
    "differs"
  )
  expect_error(
    kb_fit_cover_biomass_nereo(surveys(), biomass(), conf_level = 1, progress = "none"),
    "conf_level"
  )
})

test_that("invalid data, a missing biomass, and wrong priors error before sampling", {
  local_fit_stan_stub(cover_biomass_nereo_fit)
  expect_error(kb_fit_cover_biomass_nereo(data.frame(site = "a", year = "2020"), biomass()))
  expect_error(kb_fit_cover_biomass_nereo(surveys()), "biomass")
  p <- kb_priors_cover_biomass_nereo()
  p$biomass_floor <- kb_prior_exponential(1)
  expect_error(
    kb_fit_cover_biomass_nereo(surveys(), biomass(), priors = p, progress = "none"),
    "wrong family"
  )
})

test_that("zero-row data is accepted under prior_only", {
  skip_on_cran()
  fit <- kb_fit_cover_biomass_nereo(
    data_cover_biomass_sim_nereo[0, ],
    data_plot_biomass_sim_nereo[0, ],
    prior_only = TRUE,
    chains = 1,
    niters = 100,
    cores = 1,
    progress = "none",
    seed = 1
  )
  expect_s3_class(fit, "kb_fit_cover_biomass_nereo")
})

test_that("zero-row data error unless prior_only", {
  expect_error(
    kb_fit_cover_biomass_nereo(
      data_cover_biomass_sim_nereo[0, ],
      data_plot_biomass_sim_nereo,
      progress = "none"
    ),
    "prior_only = TRUE"
  )
})

test_that("data and prior errors name kb_fit_cover_biomass_nereo()", {
  local_fit_stan_stub(cover_biomass_nereo_fit)
  err <- expect_error(kb_fit_cover_biomass_nereo(
      data.frame(site = "a", year = "2020"),
      data_plot_biomass_sim_nereo,
      progress = "none"
  ))
  expect_identical(err$call[[1]], quote(kb_fit_cover_biomass_nereo))
  err <- expect_error(kb_fit_cover_biomass_nereo(
    data_cover_biomass_sim_nereo,
    data_plot_biomass_sim_nereo,
    priors = list(nope = kb_prior_normal(0, 1)),
    progress = "none"
  ))
  expect_identical(err$call[[1]], quote(kb_fit_cover_biomass_nereo))
})

test_that("a numeric year in the surveys pairs with the biomass and is fitted as a factor", {
  local_fit_stan_stub(cover_biomass_nereo_fit)
  d <- surveys()
  d$year <- as.numeric(as.character(d$year))
  fit <- kb_fit_cover_biomass_nereo(d, biomass(), progress = "none")
  expect_s3_class(fit$data$year, "factor")
  expect_equal(fit$data, cover_biomass_nereo_fit$data, ignore_attr = TRUE)
  expect_identical(fit$meta$year_levels, cover_biomass_nereo_fit$meta$year_levels)
})

test_that("years left without surveys by the pairing are not fitted levels", {
  local_fit_stan_stub(cover_biomass_nereo_fit)
  b <- biomass()
  b <- b[b$year != "2019", ]
  fit <- kb_fit_cover_biomass_nereo(surveys(), b, progress = "none")
  expect_identical(fit$meta$year_levels, c("2020", "2021", "2022"))
})
