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
#     are not hand-edited and are excluded from styling and linting.
#   * devtools::check() runs a full R CMD build + INSTALL, which re-runs
#     configure -> rstan_config() and recompiles the models; it is the
#     authoritative Stan-aware build.

# Regenerate C++ from the current Stan source (picks up inst/stan/*.stan edits).
rstantools::rstan_config()

roxygen2md::roxygen2md()

styler::style_pkg(
  scope = "line_breaks",
  filetype = c("R", "Rmd"),
  exclude_files = "R/stanmodels.R"
)

lintr::lint_package(
  linters = lintr::linters_with_defaults(
    line_length_linter = lintr::line_length_linter(1000),
    object_name_linter = lintr::object_name_linter(regexes = ".*")
  ),
  exclusions = list("R/stanmodels.R")
)

lintr::lint_package(exclusions = list("R/stanmodels.R"))

devtools::test()
devtools::document()

# Note: Only use pkgdown to build a documentation website for public facing packages
pkgdown::build_reference()
pkgdown::build_site()

devtools::check()
