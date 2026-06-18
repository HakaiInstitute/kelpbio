#' Normal Prior
#'
#' Construct a Normal prior object for use in [kb_priors_weight()] and the
#' `priors` argument of the `kb_fit_*()` functions.
#'
#' @param mean A number giving the mean.
#' @param sd A positive number giving the standard deviation.
#'
#' @return A `kb_prior_normal` object.
#' @export
#'
#' @examples
#' kb_prior_normal(mean = 0, sd = 2)
kb_prior_normal <- function(mean = 0, sd = 1) {
  chk::chk_number(mean)
  chk::chk_number(sd)
  chk::chk_gt(sd, value = 0)
  structure(
    list(mean = mean, sd = sd),
    class = c("kb_prior_normal", "kb_prior")
  )
}
