# Dev build / QC script for kelpbio.
#
#   Rscript scripts/build.R                       install, document, test
#   Rscript scripts/build.R --fits                + rebuild all pre-fits and fixtures
#   Rscript scripts/build.R --fits=density,wetdry + rebuild only those models'
#   Rscript scripts/build.R --check               R CMD check in place of test()
#   Rscript scripts/build.R --site                + build the pkgdown site
#   Flags combine, e.g. --fits=wetdry --check.
#
# In Positron (or VS Code), the same runs are tasks: Command Palette >
# "Tasks: Run Task" > "kelpbio: ..." (.vscode/tasks.json).
#
# kelpbio is an rstan/rstantools package: Stan models in inst/stan/ are
# transpiled to C++ and compiled into the package binary at build/install time.
#
#   * After editing inst/stan/*.stan, regenerate src/stanExports_*.{cc,h} with
#     rstantools::rstan_config() (done first below). load_all()/document()/
#     test() compile from those generated files but do NOT re-transpile the
#     Stan source themselves, so .stan edits are otherwise missed.
#   * The generated files (R/stanmodels.R, src/stanExports_*, src/RcppExports.cpp)
#     are not hand-edited and are excluded from styling.
#   * Linting is handled by jarl in CI (.github/workflows/lint-with-jarl.yaml,
#     configured by jarl.toml); this script does not lint.
#   * --check runs R CMD check, which re-runs configure -> rstan_config(),
#     recompiles the models, and runs the test suite, so test() is skipped.
#   * --site builds the pkgdown site, which reruns every example and the
#     vignette. CI builds the site and runs R CMD check on every pull request, so
#     neither is needed locally for routine work.
#   * --fits rebuilds the pre-fit example objects (data/fit_*_sim_*) and test
#     fixtures (tests/testthat/fixtures/*.rds) from their scripts. They run Stan
#     MCMC. Rebuild after changing the fit object structure or a model, so the
#     shipped objects match the current code. --fits=<models> (comma-separated:
#     weight, size, density, wetdry) rebuilds only those models' objects.
#   * The environment variables KELPBIO_FULL_CHECK=true and
#     KELPBIO_REBUILD_FITS=true still switch on --check and --fits.

models <- c("weight", "size", "density", "wetdry")
usage <- paste(
  "Usage: Rscript scripts/build.R [--fits[=<models>]] [--check] [--site]",
  "  --fits           also rebuild the pre-fit models and test fixtures (Stan MCMC)",
  "  --fits=<models>  only for these comma-separated models:",
  paste0("                   ", paste(models, collapse = ", ")),
  "  --check          run R CMD check instead of the test suite",
  "  --site           also build the pkgdown site",
  sep = "\n"
)
args <- commandArgs(trailingOnly = TRUE)
if (any(c("--help", "-h") %in% args)) {
  cat(usage, "\n", sep = "")
  quit(status = 0)
}
fits_arg <- args[startsWith(args, "--fits")]
unknown <- setdiff(args, c("--check", "--site", fits_arg))
fit_models <- unique(unlist(strsplit(sub("^--fits=?", "", fits_arg), ",")))
unknown <- c(unknown, setdiff(fit_models, models))
if (length(unknown)) {
  cat("Unknown option: ", paste(unknown, collapse = " "), "\n\n", usage, "\n", sep = "")
  quit(status = 1)
}

env_flag <- function(name) isTRUE(as.logical(Sys.getenv(name, "false")))
full_check <- "--check" %in% args || env_flag("KELPBIO_FULL_CHECK")
build_site <- "--site" %in% args
rebuild_fits <- length(fits_arg) > 0L || env_flag("KELPBIO_REBUILD_FITS")
# A bare --fits (or the environment variable) rebuilds every model.
if (rebuild_fits && !length(fit_models)) {
  fit_models <- models
}
message(
  "Build: install, document",
  if (rebuild_fits) paste0(" + rebuild fits (", paste(fit_models, collapse = ", "), ")"),
  if (full_check) " + R CMD check" else " + test",
  if (build_site) " + pkgdown"
)

# devtools::load_all()/test() and the fit-rebuild scripts compile the Stan models
# in DEBUG mode (-O0 -g), leaving oversized unoptimized objects in src/. The
# install below reuses any objects newer than their sources, so a debug object
# left behind silently ships an unoptimized sampler that fits ~20x slower.
# Optimized Stan objects are a few MB; debug ones are tens of MB, so drop them
# (forcing a clean optimized recompile) only when detected, keeping routine
# builds fast when the objects are already optimized.
stan_objs <- list.files("src", pattern = "\\.o$", full.names = TRUE)
if (any(file.size(stan_objs) > 15e6)) {
  message("Removing debug src objects so the install compiles optimized.")
  pkgbuild::clean_dll()
}

# Regenerate C++ from the current Stan source (picks up inst/stan/*.stan edits).
rstantools::rstan_config() # regenerate stanExports + stanmodels.R
devtools::install(build = FALSE, quick = TRUE, upgrade = FALSE)

roxygen2md::roxygen2md()
devtools::document()

# Rebuild the pre-fit example objects and test fixtures (Stan MCMC, seeded) when
# the fit object structure or a model has changed. Each script runs in a fresh R
# process via callr and picks up the current source with devtools::load_all().
if (rebuild_fits) {
  for (model in fit_models) {
    for (species in c("nereo", "macro")) {
      script <- paste0("data-raw/fit_", model, "_sim_", species, ".R")
      message("Rebuilding via ", script)
      callr::rscript(script, show = TRUE)
    }
  }
  message("Rebuilding fixtures for ", paste(fit_models, collapse = ", "))
  callr::rscript(
    "tests/testthat/fixtures/make-fixtures.R",
    cmdargs = fit_models,
    show = TRUE
  )
}

# R CMD check runs the test suite itself, so test() would only repeat it.
if (full_check) {
  devtools::check()
} else {
  devtools::test()
}

if (build_site) {
  pkgdown::build_site()
}
