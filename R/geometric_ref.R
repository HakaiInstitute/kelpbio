# The geometric mean of a predictor, the reference its log is centred on. It is
# stored in the fit meta so the Stan fit and R-side predictions share it.
# `fallback` is used for zero-row (prior-only) data.
geometric_ref <- function(x, fallback) {
  if (rlang::is_empty(x)) {
    return(fallback)
  }
  exp(mean(log(x)))
}
