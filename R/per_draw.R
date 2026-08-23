# Evaluate a per-draw likelihood or residual function over the D x N link-scale
# mean, returning D x N. The orientation is part of the contract, not an
# implementation detail: loo() accepts a transposed matrix and silently reports
# elpd over draws, so it is preallocated here once rather than in each method.
# `f` receives the response, one draw's mean vector, and that draw's index, for
# indexing the draw-varying parameters the caller closed over.
.per_draw <- function(mu, y, f) {
  out <- matrix(NA_real_, nrow = nrow(mu), ncol = length(y))
  for (d in seq_len(nrow(mu))) {
    out[d, ] <- f(y, mu[d, ], d)
  }
  out
}
