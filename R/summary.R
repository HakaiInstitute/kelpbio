#' Summarise a Model Fit
#'
#' A model fit's metadata paired with a per-term posterior summary table.
#'
#' @details
#' The `print` method renders a header (the model and species, the predictor,
#' observation and group counts, sampler configuration, and the convergence
#' verdict), the coefficient table, and a diagnostics footer. For a compact
#' overview without the numeric table, call `print()` on the fit itself. For the
#' model equation and priors, call [kb_model_describe()].
#'
#' The footer reports the sampler diagnostics: the percentage of saved draws
#' that ended in a divergent transition, the percentage that saturated the
#' maximum treedepth, and the minimum E-BFMI across chains. Divergences indicate
#' the sampler failed to explore part of the posterior and so enter the
#' [kb_converged()] verdict; treedepth saturation affects efficiency rather than
#' validity, and E-BFMI below 0.2 suggests the model would benefit from
#' reparameterization.
#'
#' The coefficient table reports, per term:
#' \describe{
#'   \item{`estimate`}{the posterior point estimate (the `estimate` function;
#'     the median by default).}
#'   \item{`lower`, `upper`}{the `conf_level` equal-tailed compatibility limits.}
#'   \item{`rhat`}{the potential scale reduction factor, comparing between- and
#'     within-chain variance; values near 1 indicate convergence.}
#'   \item{`ess_bulk`}{the bulk effective sample size, governing the reliability
#'     of central posterior summaries.}
#'   \item{`ess_tail`}{the tail effective sample size, governing the reliability
#'     of the interval limits.}
#' }
#'
#' Population-level coefficients and random-effect standard deviations are always
#' shown. The group-level deviations are included only when
#' `include_random_effects = TRUE`, following the convention that `summary`
#' reports the variance hyperparameters rather than the per-level effects.
#'
#' @inheritParams params
#' @param object A `kb_fit` object.
#' @param ... Unused.
#'
#' @return A `summary_kb_fit` object: a list of fit metadata and a
#'   `coefficients` tibble with columns `term`, `estimate`, `lower`, `upper`,
#'   `rhat`, `ess_bulk`, and `ess_tail`.
#' @family generics
#' @exportS3Method base::summary
#' @examples
#' summary(fit_weight_sim_nereo)
summary.kb_fit <- function(
  object,
  ...,
  conf_level = 0.95,
  estimate = stats::median,
  sig_fig = 3,
  include_random_effects = FALSE
) {
  .with_call(
    {
      rlang::check_dots_empty()
      .chk_summary_args(conf_level, estimate, sig_fig)
      chk::chk_flag(include_random_effects)
    },
    # error_call() names the generic, not the method.
    rlang::error_call(rlang::current_env())
  )

  # Diagnostics from the stored summary, the same source as kb_converged().
  coefficients <- tidy(
    object,
    conf_level = conf_level,
    estimate = estimate,
    sig_fig = sig_fig,
    include_random_effects = include_random_effects
  )
  diag <- object$diagnostics$summary
  idx <- match(coefficients$term, diag$variable)
  coefficients$rhat <- round(diag$rhat[idx], 3)
  coefficients$ess_bulk <- round(diag$ess_bulk[idx])
  coefficients$ess_tail <- round(diag$ess_tail[idx])

  structure(
    c(
      .kb_fit_header(object),
      list(
        perc_divergent = object$diagnostics$perc_divergent,
        perc_max_treedepth = object$diagnostics$perc_max_treedepth,
        ebfmi = object$diagnostics$ebfmi,
        conf_level = conf_level,
        coefficients = coefficients
      )
    ),
    class = "summary_kb_fit"
  )
}

# The class before the "kb_fit" root, e.g. "weight".
.kb_model <- function(fit) {
  cls <- class(fit)
  sub("^kb_fit_", "", cls[[match("kb_fit", cls) - 1L]])
}

.model_label <- function(fit) {
  model <- .kb_model(fit)
  if (identical(model, "wetdry")) {
    return("Wet/dry")
  }
  if (identical(model, "cover_biomass")) {
    return("Cover biomass")
  }
  .capitalize(model)
}

.capitalize <- function(x) {
  paste0(toupper(substr(x, 1L, 1L)), substring(x, 2L))
}

# meta$species stores the lowercase genus.
.species_label <- function(species) {
  binomial <- c(
    nereocystis = "Nereocystis luetkeana",
    macrocystis = "Macrocystis pyrifera"
  )
  out <- unname(binomial[species])
  if (is.na(out)) {
    out <- .capitalize(species)
  }
  out
}

# Header fields shared by summary_kb_fit and print.kb_fit(); rendered by
# .print_kb_fit_header().
.kb_fit_header <- function(fit) {
  descr <- .fit_descriptor(fit)
  list(
    model = .model_label(fit),
    species = .species_label(fit$meta$species),
    predictor = descr$predictor,
    groups = descr$groups,
    nobs = nobs(fit),
    nchains = posterior::nchains(fit$draws),
    niters = posterior::niterations(fit$draws),
    nthin = fit$meta$nthin,
    ndraws = posterior::ndraws(fit$draws),
    prior_only = isTRUE(fit$meta$prior_only),
    converged = kb_converged(fit)
  )
}

# Predictor and group counts for the print header. Only weight models have a
# predictor line, so the default serves every other model.
.fit_descriptor <- function(x) {
  UseMethod(".fit_descriptor")
}

#' @export
.fit_descriptor.default <- function(x) {
  list(predictor = NA_character_, groups = fit_groups(x))
}

# Fits both species: nereo divides diameter by the reference, macro centres
# log-fronds on its log.
#' @export
.fit_descriptor.kb_fit_weight <- function(x) {
  list(
    predictor = paste0(
      x$meta[["predictor"]],
      ", reference ",
      signif(x$meta$predictor_ref, 3),
      " (geometric mean)"
    ),
    groups = fit_groups(x)
  )
}

# Level counts in the data, not the model: a site:year count is reported even
# when the design switched the site:year effect off.
fit_groups <- function(fit) {
  counts <- vapply(
    c("site", "year", "site:year"),
    function(nm) {
      key <- paste0(sub(":", "_", nm), "_levels")
      length(fit$meta[[key]])
    },
    integer(1)
  )
  out <- counts[counts > 0L]
  if (!length(out)) integer(0) else out
}

