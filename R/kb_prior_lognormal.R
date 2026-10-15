#' Lognormal Prior
#'
#' Construct a lognormal prior object to replace an entry of a `kb_priors_*()`
#' list passed to the `priors` argument of the `kb_fit_*()` functions. Used for
#' positive parameters whose plausible values span orders of magnitude.
#'
#' @details
#' The hyperparameters are on the log scale: a lognormal prior with `meanlog` and
#' `sdlog` is a Normal prior with that mean and standard deviation on the log of
#' the parameter, so its median is `exp(meanlog)`.
#'
#' @param meanlog A number giving the mean of the log of the parameter.
#' @param sdlog A positive number giving the standard deviation of the log of the
#'   parameter.
#'
#' @return A `kb_prior_lognormal` object.
#' @family priors
#' @export
#'
#' @examples
#' kb_prior_lognormal(meanlog = 2, sdlog = 1)
kb_prior_lognormal <- function(meanlog = 0, sdlog = 1) {
  chk::chk_number(meanlog)
  chk::chk_number(sdlog)
  chk::chk_gt(sdlog, value = 0)
  .chk_finite(meanlog, "`meanlog`")
  .chk_finite(sdlog, "`sdlog`")
  structure(
    list(meanlog = meanlog, sdlog = sdlog),
    class = c("kb_prior_lognormal", "kb_prior")
  )
}
