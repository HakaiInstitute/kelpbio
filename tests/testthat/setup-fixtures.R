# helper-fixtures.R degrades to NULL when a fixture file is absent, so that
# load_all() still works while make-fixtures.R is rebuilding them. That is the
# right behaviour there and the wrong behaviour here: without it the 33 files
# that use these fits report a scatter of cryptic errors instead of naming the
# cause. setup-*.R runs for test() and R CMD check but not a bare load_all(),
# which is exactly where the distinction belongs.
fixtures <- list(
  weight_fit,
  weight_macro_fit,
  size_nereo_fit,
  size_macro_fit,
  density_nereo_fit,
  density_macro_fit
)
if (any(vapply(fixtures, is.null, logical(1)))) {
  stop(
    "Test fixtures are missing. Rebuild them with:\n",
    "  KELPBIO_REBUILD_FITS=true Rscript scripts/build.R"
  )
}
