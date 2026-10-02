# Dev build / QC script for kelpbio.
#
#   Rscript scripts/build.R                 install, document, test
#   Rscript scripts/build.R --check         + pkgdown site and R CMD check
#   Rscript scripts/build.R --fits          + rebuild pre-fits and test fixtures
#   Rscript scripts/build.R --fits --check  both
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
#   * --check runs the slow, authoritative steps (R CMD check, which re-runs
#     configure -> rstan_config() and recompiles the models, plus pkgdown).
#   * --fits rebuilds the pre-fit example objects (data/fit_*_sim_*) and test
#     fixtures (tests/testthat/fixtures/*.rds) from their scripts. They run Stan
#     MCMC. Rebuild after changing the fit object structure or a model, so the
#     shipped objects match the current code.
#   * The environment variables KELPBIO_FULL_CHECK=true and
#     KELPBIO_REBUILD_FITS=true still switch on the same steps.

usage <- paste(
  "Usage: Rscript scripts/build.R [--check] [--fits]",
  "  --check  also build the pkgdown site and run R CMD check",
  "  --fits   also rebuild the pre-fit models and test fixtures (Stan MCMC)",
  sep = "\n"
)
args <- commandArgs(trailingOnly = TRUE)
if (any(c("--help", "-h") %in% args)) {
  cat(usage, "\n", sep = "")
  quit(status = 0)
}
unknown <- setdiff(args, c("--check", "--fits"))
if (length(unknown)) {
  cat("Unknown option: ", paste(unknown, collapse = " "), "\n\n", usage, "\n", sep = "")
  quit(status = 1)
}

env_flag <- function(name) isTRUE(as.logical(Sys.getenv(name, "false")))
full_check <- "--check" %in% args || env_flag("KELPBIO_FULL_CHECK")
rebuild_fits <- "--fits" %in% args || env_flag("KELPBIO_REBUILD_FITS")
message(
  "Build: install, document, test",
  if (rebuild_fits) " + rebuild fits",
  if (full_check) " + pkgdown + R CMD check"
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
  for (script in c(
    "data-raw/fit_weight_sim_nereo.R",
    "data-raw/fit_weight_sim_macro.R",
    "data-raw/fit_size_sim_nereo.R",
    "data-raw/fit_size_sim_macro.R",
    "data-raw/fit_density_sim_nereo.R",
    "data-raw/fit_density_sim_macro.R",
    "tests/testthat/fixtures/make-fixtures.R"
  )) {
    message("Rebuilding via ", script)
    callr::rscript(script, show = TRUE)
  }
}

devtools::test()

if (full_check) {
  pkgdown::build_site()
  devtools::check()
}
