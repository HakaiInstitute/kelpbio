#' Beta Prior
#'
#' Construct a Beta prior object for use in [kb_priors_weight_nereo()] and the
#' `priors` argument of the `kb_fit_*()` functions. Used for hyperparameters
#' bounded on the unit interval, such as the allometric floor.
#'
#' @param shape1 A positive number giving the first shape parameter.
#' @param shape2 A positive number giving the second shape parameter.
#'
#' @return A `kb_prior_beta` object.
#' @family priors
#' @export
#'
#' @examples
#' kb_prior_beta(shape1 = 1, shape2 = 5)
kb_prior_beta <- function(shape1 = 1, shape2 = 5) {
  chk::chk_number(shape1)
  chk::chk_gt(shape1, value = 0)
  chk::chk_number(shape2)
  chk::chk_gt(shape2, value = 0)
  structure(
    list(shape1 = shape1, shape2 = shape2),
    class = c("kb_prior_beta", "kb_prior")
  )
}
