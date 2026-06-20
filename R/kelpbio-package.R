#' @keywords internal
#' @import methods
#' @import Rcpp
#' @importFrom rstan sampling
#' @importFrom rstantools rstan_config
#' @importFrom RcppParallel RcppParallelLibs
#' @importFrom stats nobs
#' @importFrom rlang .data
#' @useDynLib kelpbio, .registration = TRUE
"_PACKAGE"

# `diameter_mm` is referenced via non-standard evaluation inside
# newdata::xnew_seq() when auto-generating the prediction grid.
utils::globalVariables("diameter_mm")

## usethis namespace: start
## usethis namespace: end
NULL
