# Applies f(mu_d, d) to each draw of the D x N mean, returning D x N. Keep the
# orientation: loo() silently accepts a transposed matrix.
.per_draw <- function(mu, f) {
  out <- matrix(NA_real_, nrow = nrow(mu), ncol = ncol(mu))
  for (d in seq_len(nrow(mu))) {
    out[d, ] <- f(mu[d, ], d)
  }
  out
}
