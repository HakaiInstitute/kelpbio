#' Example Macrocystis Wet/Dry Model Fit
#'
#' A slim pre-fit wet/dry model, the result of [kb_fit_wetdry_macro()] on
#' [data_wetdry_sim_macro] with a reduced number of draws. Provided so the
#' examples and tests for the fit accessors, S3 methods, and prediction functions
#' run quickly. It is fit to simulated data and is not intended for inference.
#' Built by `data-raw/fit_wetdry_sim_macro.R`.
#'
#' @format An object of class
#'   `c("kb_fit_wetdry_macro", "kb_fit_wetdry", "kb_fit")`.
#' @seealso [kb_fit_wetdry_macro()] and [data_wetdry_sim_macro].
#' @family data
"fit_wetdry_sim_macro"
