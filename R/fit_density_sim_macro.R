#' Example Macrocystis Density Model Fit
#'
#' A slim pre-fit density model, the result of [kb_fit_density_macro()] on
#' [data_density_sim_macro] with a reduced number of draws. Provided so the
#' examples and tests for the fit accessors, S3 methods, and prediction functions
#' run quickly. It is fit to simulated data and is not intended for inference.
#' Built by `data-raw/fit_density_sim_macro.R`.
#'
#' @format An object of class
#'   `c("kb_fit_density_macro", "kb_fit_density", "kb_fit")`.
#' @seealso [kb_fit_density_macro()] and [data_density_sim_macro].
#' @family data
"fit_density_sim_macro"
