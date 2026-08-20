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
#' [converged()] verdict; treedepth saturation affects efficiency rather than
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
#' reports the variance hyperparameters rather than the per-level effects (the
#' latter are the `tidy()` default).
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
  rlang::check_dots_empty()
  .chk_summary_args(conf_level, estimate, sig_fig)
  chk::chk_flag(include_random_effects)

  # Term table from the subclass tidy() (subclass-aware term selection), then
  # the per-term diagnostics from the stored summary (same source as
  # converged()/glance(), so the numbers agree).
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

# Model name ("weight") from the class vector: the class before the "kb_fit" root.
.kb_model <- function(fit) {
  cls <- class(fit)
  sub("^kb_fit_", "", cls[[match("kb_fit", cls) - 1L]])
}

# Upper-case the first letter, for display labels.
.capitalize <- function(x) {
  paste0(toupper(substr(x, 1L, 1L)), substring(x, 2L))
}

# Proper scientific name for display; meta$species stores the lowercase genus.
# Falls back to the capitalized genus for any species without a mapping.
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

# Fit-level metadata header, shared by the summary_kb_fit object and
# print.kb_fit() so both render the same block (a single source for the fields;
# .print_kb_fit_header() in print.R is the single source for the rendering).
.kb_fit_header <- function(fit) {
  descr <- .fit_descriptor(fit)
  list(
    model = .capitalize(.kb_model(fit)),
    species = .species_label(fit$meta$species),
    predictor = descr$predictor,
    groups = descr$groups,
    nobs = nobs(fit),
    nchains = nchains(fit),
    niters = niters(fit),
    nthin = fit$meta$nthin,
    ndraws = posterior::ndraws(fit$draws),
    prior_only = isTRUE(fit$meta$prior_only),
    converged = converged(fit)
  )
}

# Per-fit header descriptor (predictor centering and group counts); dispatches on
# the fit subclass, with the default returning NA/empty for models without one.
# The model's likelihood/effect structure is not here (it is fixed by species and
# rendered by kb_model_describe()).
.fit_descriptor <- function(x) {
  UseMethod(".fit_descriptor")
}

.fit_descriptor.default <- function(x) {
  list(predictor = NA_character_, groups = integer(0))
}

.fit_descriptor.kb_fit_weight_macro <- function(x) {
  list(
    predictor = paste0(
      "fronds, centered at its geometric mean, ",
      signif(x$meta$fronds_ref, 3)
    ),
    groups = weight_groups(x, year = TRUE)
  )
}

.fit_descriptor.kb_fit_weight_nereo <- function(x) {
  list(
    predictor = paste0(
      "diameter, centered at its geometric mean, ",
      signif(x$meta$diameter_ref, 3)
    ),
    groups = weight_groups(x)
  )
}

# Number of levels of each grouping factor in the weight model. `year` adds the
# standalone year group count (the Macrocystis model has a year main effect).
weight_groups <- function(x, year = FALSE) {
  d <- as.data.frame(x$data)
  n_site <- length(x$meta$site_levels)
  n_year <- length(x$meta$year_levels)
  n_site_year <- if (nrow(d) && all(c("site", "year") %in% names(d))) {
    nrow(unique(d[c("site", "year")]))
  } else {
    0L
  }
  if (year) {
    c(site = n_site, year = n_year, "site:year" = n_site_year)
  } else {
    c(site = n_site, "site:year" = n_site_year)
  }
}
