# helper-fixtures.R tolerates missing fixtures for load_all(); setup-*.R runs
# only for test() and check, so fail here with the cause.
fixtures <- list(
  weight_nereo_fit,
  weight_macro_fit,
  size_nereo_fit,
  wetdry_nereo_fit,
  wetdry_macro_fit,
  carbon_nereo_fit,
  carbon_macro_fit,
  cover_calibration_nereo_fit,
  cover_calibration_macro_fit
)
if (any(vapply(fixtures, is.null, logical(1)))) {
  stop(
    "Test fixtures are missing. Rebuild them with:\n",
    "  Rscript scripts/build.R --fits"
  )
}
