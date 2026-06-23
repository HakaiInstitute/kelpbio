# Dev build / QC script for kelpbio.
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
#     configured by jarl.toml); this script no longer lints, so local and CI
#     checks stay in sync.
#   * The slow, authoritative steps (R CMD check, which re-runs configure ->
#     rstan_config() and recompiles the models, plus the pkgdown site) run only
#     when KELPBIO_FULL_CHECK=true, so routine runs stay fast:
#       KELPBIO_FULL_CHECK=true Rscript scripts/build.R

full_check <- isTRUE(as.logical(Sys.getenv("KELPBIO_FULL_CHECK", "false")))

# Regenerate C++ from the current Stan source (picks up inst/stan/*.stan edits).
rstantools::rstan_config()

roxygen2md::roxygen2md()

styler::style_pkg(
  scope = "line_breaks",
  filetype = c("R", "Rmd"),
  exclude_files = "R/stanmodels.R"
)

devtools::document()
devtools::test()

if (full_check) {
  pkgdown::build_site()
  devtools::check()
}
