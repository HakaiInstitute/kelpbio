#' Example Macrocystis Carbon Model Fit
#'
#' A slim pre-fit carbon model, the result of [kb_fit_carbon_macro()] on
#' [data_carbon_sim_macro] with a reduced number of draws. Provided so the
#' examples and tests for the fit accessors, S3 methods, and prediction functions
#' run quickly. It is fit to simulated data and is not intended for inference.
#' Built by `data-raw/fit_carbon_sim_macro.R`.
#'
#' @format An object of class
#'   `c("kb_fit_carbon_macro", "kb_fit_carbon", "kb_fit")`.
#' @seealso [kb_fit_carbon_macro()] and [data_carbon_sim_macro].
#' @family data
"fit_carbon_sim_macro"
