#' Gamma Prior
#'
#' Construct a Gamma prior object for use in [kb_priors_weight_nereo()] and the
#' `priors` argument of the `kb_fit_*()` functions. Used for the Student-t degrees
#' of freedom, which is positive and unbounded above.
#'
#' @param shape A positive number giving the shape.
#' @param rate A positive number giving the rate.
#'
#' @return A `kb_prior_gamma` object.
#' @family priors
#' @export
#'
#' @examples
#' kb_prior_gamma(shape = 2, rate = 0.1)
kb_prior_gamma <- function(shape = 2, rate = 0.1) {
  chk::chk_number(shape)
  chk::chk_gt(shape, value = 0)
  chk::chk_number(rate)
  chk::chk_gt(rate, value = 0)
  structure(
    list(shape = shape, rate = rate),
    class = c("kb_prior_gamma", "kb_prior")
  )
}
