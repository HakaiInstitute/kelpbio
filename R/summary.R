#' Summarise a Model Fit
#'
#' Return a classed `summary_kb_fit` object collecting fit-level metadata and a
#' per-term posterior summary table, in the style of `brms` and `rstanarm`.
#'
#' @details
#' The `print` method renders a header (likelihood family, model formula,
#' observation and group counts, sampler configuration, and the convergence
#' verdict), the coefficient table, and a diagnostics footer. For the
#' snapshot-safe overview without the numeric table, call `print()` on the fit
#' itself.
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
#' summary(fit_weight)
summary.kb_fit <- function(object,
                           conf_level = 0.95,
                           estimate = stats::median,
                           sig_fig = 3,
                           include_random_effects = FALSE,
                           ...) {
  rlang::check_dots_empty()
  chk::chk_number(conf_level)
  chk::chk_range(conf_level)
  chk::chk_function(estimate)
  chk::chk_whole_number(sig_fig)
  chk::chk_gt(sig_fig, value = 0)
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
        ndivergent = object$diagnostics$ndivergent,
        conf_level = conf_level,
        coefficients = coefficients
      )
    ),
    class = "summary_kb_fit"
  )
}

# Fit-level metadata header, shared by the summary_kb_fit object and
# print.kb_fit() so both render the same block (a single source for the fields;
# .print_kb_fit_header() in print.R is the single source for the rendering).
.kb_fit_header <- function(fit) {
  descr <- fit_descriptor(fit)
  list(
    model = sub("^kb_fit_", "", class(fit)[1]),
    species = fit$meta$species,
    family = descr$family,
    formula = descr$formula,
    centered = descr$centered,
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

# Model-specific descriptor (likelihood family, formula, group structure) for the
# summary header. Switches on the fit subclass; unknown models fall back to NA so
# the print method omits those lines.
fit_descriptor <- function(x) {
  model <- sub("^kb_fit_", "", class(x)[1])
  switch(model,
    weight = {
      dc <- "log(diameter/d0)"
      list(
        family = "Student-t (df = 4); response modelled as log(weight)",
        formula = paste0(
          "log(weight) ~ 1 + ", dc, " + ", dc, "^2 + ",
          "(1 + ", dc, " | site) + (1 | site:year)"
        ),
        centered = paste0(
          "log-diameter at d0 = ", signif(x$meta$diameter_ref, 3),
          " (geometric mean of diameter)"
        ),
        groups = weight_groups(x)
      )
    },
    list(
      family = NA_character_, formula = NA_character_,
      centered = NA_character_, groups = integer(0)
    )
  )
}

# Number of levels of each grouping factor in the weight model.
weight_groups <- function(x) {
  d <- as.data.frame(x$data)
  n_site <- length(x$meta$site_levels)
  n_site_year <- if (nrow(d) && all(c("site", "year") %in% names(d))) {
    nrow(unique(d[c("site", "year")]))
  } else {
    0L
  }
  c(site = n_site, "site:year" = n_site_year)
}
