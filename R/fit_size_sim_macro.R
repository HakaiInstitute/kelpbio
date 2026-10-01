#' Example Macrocystis Size Model Fit
#'
#' A slim pre-fit size model, the result of [kb_fit_size_macro()] on
#' [data_size_sim_macro] with a reduced number of draws. Provided so the examples
#' and tests for the fit accessors, S3 methods, and prediction functions run
#' quickly. It is fit to simulated data and is not intended for inference. Built
#' by `data-raw/fit_size_sim_macro.R`.
#'
#' @format An object of class `c("kb_fit_size_macro", "kb_fit_size", "kb_fit")`.
#' @seealso [kb_fit_size_macro()] and [data_size_sim_macro].
#' @family data
"fit_size_sim_macro"
