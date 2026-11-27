# Arguments documented once in R/params.R are declared in each function's
# signature; these tests keep their defaults in step across functions.
user_facing_functions <- function() {
  ns <- asNamespace("kelpbio")
  exported <- mget(getNamespaceExports(ns), envir = ns, ifnotfound = list(NULL))
  methods <- as.list(ns[[".__S3MethodsTable__."]])
  Filter(is.function, c(exported, methods))
}

defaults_of <- function(fns, arg) {
  has_arg <- Filter(function(f) arg %in% names(formals(f)), fns)
  lapply(has_arg, function(f) formals(f)[[arg]])
}

test_that("shared arguments have the same default in every function", {
  fns <- user_facing_functions()
  shared <- list(
    conf_level = 0.95,
    estimate = quote(stats::median),
    sig_fig = 3,
    representative_site = NULL,
    prior_only = FALSE,
    chains = 4L,
    niters = 1000L,
    nthin = 1L,
    cores = NULL,
    seed = NULL,
    rhat = 1.01,
    ess = 100
  )
  for (arg in names(shared)) {
    defaults <- defaults_of(fns, arg)
    expect_gt(length(defaults), 0L)
    for (fn in names(defaults)) {
      expect_identical(defaults[[fn]], shared[[arg]], label = paste0(fn, "(", arg, ")"))
    }
  }
})

test_that("new_levels defaults to sample for the derived verbs and average otherwise", {
  defaults <- defaults_of(user_facing_functions(), "new_levels")
  derived <- c("kb_predict_mean_weight", "kb_predict_biomass_in_situ", "kb_predict_biomass_canopy")
  expect_true(all(derived %in% names(defaults)))
  for (fn in names(defaults)) {
    expected <- if (fn %in% derived) quote(c("sample", "average")) else quote(c("average", "sample"))
    expect_identical(defaults[[fn]], expected, label = paste0(fn, "(new_levels)"))
  }
})
