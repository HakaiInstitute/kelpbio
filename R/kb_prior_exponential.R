#' Exponential Prior
#'
#' Construct an Exponential prior object for use in [kb_priors_weight()] and the
#' `priors` argument of the `kb_fit_*()` functions. Used for the standard
#' deviation (scale) hyperparameters.
#'
#' @param rate A positive number giving the rate.
#'
#' @return A `kb_prior_exponential` object.
#' @export
#'
#' @examples
#' kb_prior_exponential(rate = 1)
kb_prior_exponential <- function(rate = 1) {
  chk::chk_number(rate)
  chk::chk_gt(rate, value = 0)
  structure(
    list(rate = rate),
    class = c("kb_prior_exponential", "kb_prior")
  )
}
