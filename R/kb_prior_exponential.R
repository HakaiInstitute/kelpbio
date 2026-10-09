#' Exponential Prior
#'
#' Construct an Exponential prior object to replace an entry of a `kb_priors_*()` list
#' passed to the `priors` argument of the `kb_fit_*()` functions. Used for the standard
#' deviation (scale) hyperparameters.
#'
#' @param rate A positive number giving the rate.
#'
#' @return A `kb_prior_exponential` object.
#' @family priors
#' @export
#'
#' @examples
#' kb_prior_exponential(rate = 1)
kb_prior_exponential <- function(rate = 1) {
  chk::chk_number(rate)
  chk::chk_gt(rate, value = 0)
  .chk_finite(rate, "`rate`")
  structure(
    list(rate = rate),
    class = c("kb_prior_exponential", "kb_prior")
  )
}
