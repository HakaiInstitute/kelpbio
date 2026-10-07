# Dev build / QC for kelpbio: rstan_config(), install, document, then test.
#
#   Rscript scripts/build.R                       routine build
#   Rscript scripts/build.R --fits                + rebuild all pre-fits and fixtures (MCMC)
#   Rscript scripts/build.R --fits=density,wetdry + rebuild only those models'
#   Rscript scripts/build.R --check               R CMD check in place of test()
#   Rscript scripts/build.R --site                + build the pkgdown site
#
# Flags combine (--fits=wetdry --check). Also available as Positron / VS Code
# tasks "kelpbio: ..." (.vscode/tasks.json).

models <- c("weight", "size", "density", "wetdry", "carbon", "cover_biomass")
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

full_check <- "--check" %in% args
build_site <- "--site" %in% args
rebuild_fits <- length(fits_arg) > 0L
if (rebuild_fits && !length(fit_models)) {
  fit_models <- models
}
message(
  "Build: install, document",
  if (rebuild_fits) paste0(" + rebuild fits (", paste(fit_models, collapse = ", "), ")"),
  if (full_check) " + R CMD check" else " + test",
  if (build_site) " + pkgdown"
)

# load_all()/test() and the fit scripts leave debug (-O0) Stan objects in src/
# (tens of MB, vs a few MB optimized). install() reuses objects newer than
# their sources, so a stale debug object ships a sampler ~20x slower.
stan_objs <- list.files("src", pattern = "\\.o$", full.names = TRUE)
if (any(file.size(stan_objs) > 15e6)) {
  message("Removing debug src objects so the install compiles optimized.")
  pkgbuild::clean_dll()
}

# load_all()/test() do not re-transpile inst/stan/*.stan.
rstantools::rstan_config()
# Before document(), whose load_all() would leave debug objects to reuse.
devtools::install(build = FALSE, quick = TRUE, upgrade = FALSE)
devtools::document()

# Each script runs in a fresh R process and load_all()s the current source.
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

if (full_check) {
  devtools::check()
} else {
  devtools::test()
}

if (build_site) {
  pkgdown::build_site()
}
