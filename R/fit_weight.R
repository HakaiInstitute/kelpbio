#' Example Weight Model Fit
#'
#' A slim pre-fit weight model, the result of [kb_fit_weight()] on
#' [data_weight_sim] with a reduced number of chains and draws. Provided so
#' the examples and tests for the fit accessors, S3 methods, and prediction
#' functions run quickly. It is fit to simulated data and is not intended for
#' inference. Built by `data-raw/fit_weight.R`.
#'
#' @format An object of class `c("kb_fit_weight", "kb_fit")`.
#' @seealso [kb_fit_weight()] and [data_weight_sim].
#' @family data
"fit_weight"
