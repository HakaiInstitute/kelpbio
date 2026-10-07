core <- function() {
  list(
    draws = posterior::draws_rvars(
      intercept = posterior::rvar(matrix(1:4, 4, 1)),
      sd_site = posterior::rvar(matrix(1:4, 4, 1)),
      site_effect = posterior::rvar(matrix(1:4, 4, 1))
    ),
    diagnostics = list(summary = NULL),
    stancode = "// stan"
  )
}

data <- function() {
  data.frame(site = c("a", "b"), year = c("2020", "2021"), weight_kg = c(1, 2))
}

terms <- function() {
  list(fixed = c("intercept", "sd_site"), random = "site_effect")
}

build <- function(...) {
  args <- list(
    core(),
    data = data(),
    priors = list(),
    model = "weight",
    species = "nereocystis",
    offset = NULL,
    terms = terms(),
    prior_only = FALSE,
    nthin = 1L
  )
  do.call(new_kb_fit, utils::modifyList(args, list(...)))
}

test_that("new_kb_fit builds the three class tiers from model and species", {
  expect_identical(
    class(build()),
    c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")
  )
  expect_identical(
    class(build(species = "macrocystis")),
    c("kb_fit_weight_macro", "kb_fit_weight", "kb_fit")
  )
})

test_that("new_kb_fit is not weight-specific", {
  # The constructor is shared by every sub-model, so the class tiers follow the
  # model argument rather than a hard-coded "weight".
  expect_identical(
    class(build(model = "density")),
    c("kb_fit_density_nereo", "kb_fit_density", "kb_fit")
  )
})

test_that("new_kb_fit records the levels and carries meta_extra through", {
  fit <- build(
    nthin = 2L,
    meta_extra = list(predictor = "diameter_mm", response = "weight_kg")
  )
  expect_named(fit, c("draws", "diagnostics", "data", "meta"))
  expect_identical(fit$meta$site_levels, c("a", "b"))
  expect_identical(fit$meta$year_levels, c("2020", "2021"))
  expect_identical(fit$meta$nthin, 2L)
  expect_identical(fit$meta$predictor, "diameter_mm")
  expect_identical(fit$meta$stancode, "// stan")
})

test_that("new_kb_fit does not store the model, which the class already carries", {
  # A second copy of the model name could disagree with the class.
  expect_null(build()$meta$model)
})

test_that("new_kb_fit stores the offset column name, NULL for a non-rate model", {
  expect_null(build()$meta$offset)
  expect_identical(build(offset = "area")$meta$offset, "area")
})

test_that("new_kb_fit requires the offset to be declared", {
  # A sub-model that never states one must fail at fit time rather than silently
  # predicting a rate as though it were a count.
  args <- list(
    core(),
    data = data(),
    priors = list(),
    model = "weight",
    species = "nereocystis",
    terms = terms(),
    prior_only = FALSE,
    nthin = 1L
  )
  expect_error(do.call(new_kb_fit, args), "offset")
})

test_that("new_kb_fit stores the reported parameter set", {
  expect_identical(build()$meta$terms, terms())
})

test_that("new_kb_fit rejects an unknown species", {
  expect_error(build(species = "bogus"))
})

effects <- function() {
  posterior::draws_rvars(
    site_effect = posterior::rvar(array(1:8, c(4, 2)), nchains = 2),
    year_effect = posterior::rvar(array(11:18, c(4, 2)), nchains = 2),
    site_year_effect = posterior::rvar(array(21:36, c(4, 2, 2)), nchains = 2)
  )
}

test_that("label_levels names site, year, and site:year effects by level", {
  draws <- label_levels(effects(), c("a", "b"), c("2020", "2021"))
  expect_identical(
    flat_variables(draws),
    c(
      "site_effect[a]", "site_effect[b]", "year_effect[2020]", "year_effect[2021]",
      "site_year_effect[a,2020]", "site_year_effect[b,2020]",
      "site_year_effect[a,2021]", "site_year_effect[b,2021]"
    )
  )
  # Indexing by name and by position give the same draws; chains are kept.
  expect_identical(
    posterior::draws_of(draws$site_effect[["b"]]),
    posterior::draws_of(draws$site_effect[[2]])
  )
  expect_identical(
    posterior::draws_of(draws$site_year_effect["b", "2021"]),
    posterior::draws_of(effects()$site_year_effect[2, 2]),
    ignore_attr = TRUE
  )
  expect_identical(posterior::nchains(draws$site_effect), 2L)
})

test_that("label_levels leaves an effect unlabelled when its shape does not match", {
  # A zero-row prior-only fit samples one placeholder level with no name.
  draws <- label_levels(effects(), character(0), character(0))
  expect_identical(draws, effects())
})

test_that("new_kb_fit labels the effects and the diagnostics summary alike", {
  core <- core()
  core$draws <- effects()
  core$diagnostics$summary <- posterior::summarise_draws(core$draws)
  fit <- new_kb_fit(
    core,
    data = data(),
    priors = list(),
    model = "weight",
    species = "nereocystis",
    offset = NULL,
    terms = terms(),
    prior_only = FALSE,
    nthin = 1L
  )
  expect_identical(fit$diagnostics$summary$variable, flat_variables(fit$draws))
  expect_true("site_year_effect[b,2021]" %in% fit$diagnostics$summary$variable)
})
