# Elementwise minimum written as arithmetic, since pmin() does not take an rvar.
rvar_pmin <- function(a, b) {
  (a + b - abs(a - b)) / 2
}
