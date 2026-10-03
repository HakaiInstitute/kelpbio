# Warn, rather than exclude, when samples have a dry:wet mass ratio outside
# 0.02 to 0.5. The bounds lie in natural gaps of the Hakai Institute lab data
# (no ratios between 0.021 and 0.038, or between 0.21 and 0.46), so a ratio
# outside them is consistent with a transcription or weighing error.
warn_dry_wet_ratio <- function(data, x_name) {
  ratio <- data$dry_mass_g / data$wet_mass_g
  n <- sum(ratio < 0.02 | ratio > 0.5)
  if (n > 0L) {
    # cli::qty(n) restates the count for the verb, since x_name sits between them.
    cli::cli_warn(c(
      "{n} sample{?s} in {x_name} {cli::qty(n)}{?has a/have} dry:wet mass ratio{?s} outside 0.02 to 0.5, the plausible range for kelp tissue.",
      i = "Check the wet and dry masses for transcription or weighing errors."
    ))
  }
  invisible(data)
}
