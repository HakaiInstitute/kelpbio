#' Example Weight Model Fit
#'
#' A slim pre-fit weight model, the result of [kb_fit_weight_nereo()] on
#' [data_weight_sim_nereo] with a reduced number of draws. Provided so
#' the examples and tests for the fit accessors, S3 methods, and prediction
#' functions run quickly. It is fit to simulated data and is not intended for
#' inference. Built by `data-raw/fit_weight_sim_nereo.R`.
#'
#' @format An object of class `c("kb_fit_weight", "kb_fit")`.
#' @seealso [kb_fit_weight_nereo()] and [data_weight_sim_nereo].
#' @family data
"fit_weight_sim_nereo"
