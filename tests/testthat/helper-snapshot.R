# Redact the parts of a printed fit or summary that depend on the draws or the
# data, so the snapshot survives fixture rebuilds: convergence, the predictor
# reference value, the summary table's numerics, and the sampler footer.
redact_fit_print <- function(lines) {
  lines <- sub("^(\\s*\\d+ \\S+)\\s+[-0-9.].*$", "\\1 <numerics>", lines)
  lines <- sub("^(Predictor: [a-z_]+, reference) [0-9.]+", "\\1 <value>", lines)
  lines <- sub("^(Converged:) .*$", "\\1 <value>", lines)
  sub(
    "^[0-9.]+% divergent.*min E-BFMI [0-9.]+\\.$",
    "<n>% divergent transitions; <n>% max-treedepth; min E-BFMI <n>.",
    lines
  )
}
