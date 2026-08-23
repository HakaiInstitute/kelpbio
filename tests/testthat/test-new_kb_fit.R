core <- function() {
  list(
    draws = posterior::draws_rvars(
      bWeight = posterior::rvar(matrix(1:4, 4, 1)),
      sSite = posterior::rvar(matrix(1:4, 4, 1)),
      bSite = posterior::rvar(matrix(1:4, 4, 1))
    ),
    diagnostics = list(summary = NULL),
    stancode = "// stan"
  )
}

data <- function() {
  data.frame(site = c("a", "b"), year = c("2020", "2021"), weight = c(1, 2))
}

terms <- function() {
  list(fixed = c("bWeight", "sSite"), random = "bSite")
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
    meta_extra = list(predictor = "diameter", response = "weight")
  )
  expect_named(fit, c("draws", "diagnostics", "data", "meta"))
  expect_identical(fit$meta$site_levels, c("a", "b"))
  expect_identical(fit$meta$year_levels, c("2020", "2021"))
  expect_identical(fit$meta$nthin, 2L)
  expect_identical(fit$meta$predictor, "diameter")
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
  expect_error(build(species = "bogus"), "subscript out of bounds")
})
