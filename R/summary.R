#' Summarise a Model Fit
#'
#' Return a classed `summary_kb_fit` object: the stable fit metadata plus the
#' per-term posterior summary table (from [tidy()][tidy.kb_fit_weight]). Its
#' `print` method shows the numeric table; for the snapshot-safe overview call
#' `print()` on the fit itself.
#'
#' @param object A `kb_fit` object.
#' @param ... Passed to [tidy()][tidy.kb_fit_weight].
#'
#' @return A `summary_kb_fit` object.
#' @family generics
#' @exportS3Method base::summary
summary.kb_fit <- function(object, ...) {
  structure(
    list(
      model = sub("^kb_fit_", "", class(object)[1]),
      species = object$meta$species,
      nobs = nobs(object),
      converged = converged(object),
      coefficients = tidy(object, ...)
    ),
    class = "summary_kb_fit"
  )
}
