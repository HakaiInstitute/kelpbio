#' Posterior Predictive Check
#'
#' Plot the density of the observed data over the densities of replicate datasets
#' simulated from the fitted model, to check that the model reproduces its data.
#'
#' @details
#' Each replicate dataset is simulated at the observed rows from one posterior
#' draw, chosen at random. A model that fits well gives replicates that bracket
#' the observed curve; a systematic gap, such as observed values piling up where
#' the replicates have few, points to a mismatch in shape or scale or to errors
#' in the data. The check reuses the data the model was fitted to, so it shows
#' gross misfit rather than fine differences.
#'
#' For a density model, the observed and replicate counts are divided by their
#' transect's area, so differences in transect length do not dominate the plot
#' and the axis is a density per m².
#'
#' With `type = "residual"`, the observed curve is [residuals()] and each
#' replicate's curve is the deviance residuals of the replicate under the draw
#' that generated it. For a well-fitting model the two match, including any
#' banding a count response gives the residuals.
#'
#' The replicates are random, so set a seed with `set.seed()` for a reproducible
#' plot.
#'
#' @param object A `kb_fit` object.
#' @param type A string, one of `"response"` (the recorded response) or
#'   `"residual"` (deviance residuals), specifying what to compare.
#' @param ... Unused.
#' @param ndraws A whole number of replicate datasets to draw, at most the
#'   number of draws in the fit.
#'
#' @return A `ggplot` object from [bayesplot::ppc_dens_overlay()].
#' @family generics
#' @seealso [posterior_predict()] for the replicates themselves.
#' @exportS3Method bayesplot::pp_check
#' @examples
#' set.seed(1)
#' pp_check(fit_weight_sim_nereo)
#' pp_check(fit_size_sim_macro, "residual", ndraws = 20)
pp_check.kb_fit <- function(
  object,
  type = c("response", "residual"),
  ...,
  ndraws = 50L
) {
  .with_call(
    {
      rlang::check_dots_empty()
      .chk_kb_fit(object)
      type <- rlang::arg_match(type)
      chk::chk_whole_number(ndraws)
      chk::chk_range(ndraws, c(1, posterior::ndraws(object$draws)))
    },
    # error_call() names the generic, not the method.
    rlang::error_call(rlang::current_env())
  )
  .chk_observed_data(object, call = rlang::error_call(rlang::current_env()))
  # The same fit holding only the sampled draws, so posterior_predict()
  # simulates just those. subset_draws() returns draws in index order.
  draws <- sort(sample.int(posterior::ndraws(object$draws), ndraws))
  sampled <- object
  sampled$draws <- posterior::subset_draws(
    posterior::merge_chains(object$draws),
    draw = draws
  )
  yrep <- posterior_predict(sampled)
  if (identical(type, "residual")) {
    y <- residuals(object)
    yrep <- .replicate_residuals(sampled, yrep)
    xlab <- "Deviance residual"
  } else {
    y <- .obs_family(object, object$data)$response(object$data)
    response <- object$meta$response
    offset <- object$meta$offset
    # Transect areas differ, so counts are compared per m^2.
    if (!is.null(offset)) {
      area <- object$data[[offset]]
      y <- y / area
      yrep <- sweep(yrep, 2L, area, "/")
      response <- paste0(response, "_m2")
    }
    xlab <- axis_label(response)
  }
  bayesplot::ppc_dens_overlay(y, yrep) + ggplot2::labs(x = xlab)
}

# Deviance residuals of each row of `yrep` (D x N, replicates at the observed
# rows) under the fit's draw that row was simulated from.
.replicate_residuals <- function(fit, yrep) {
  mu <- posterior::draws_of(.linpred_obs(fit)) # link scale, D x N
  family <- .obs_family(fit, fit$data)
  res <- .family_fun("res", family$family)
  .per_draw(mu, function(mu_d, d) {
    rlang::exec(res, yrep[d, ], !!!family$pars(mu_d, d))
  })
}
