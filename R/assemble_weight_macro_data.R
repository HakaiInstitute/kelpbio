#' Assemble the Stan Data List for the Macrocystis Weight Model
#'
#' Map validated weight data and a resolved prior list to the `data` block of
#' `inst/stan/weight_macro.stan`. `site` and `year` are encoded as integer factor
#' codes; the raw `fronds` and `weight` vectors are passed through (the Stan model
#' applies the `log(fronds) - log(fronds_ref)` transform). `fronds_ref` is the
#' geometric mean of the observed frond count. Zero-row data is supported (for
#' prior-only fits): `nObs` is `0` and `nSite` / `nYear` fall back to `1`.
#'
#' @inheritParams params
#' @param priors A resolved named prior list (see `resolve_priors()`).
#'
#' @return A named list suitable for `rstan::sampling(stanmodels$weight_macro, data = .)`.
#' @noRd
assemble_weight_macro_data <- function(
  data,
  priors,
  prior_only = FALSE,
  site_year_on = TRUE
) {
  site <- factor(data$site)
  year <- factor(data$year)
  nObs <- nrow(data)

  list(
    nObs = nObs,
    nSite = max(1L, nlevels(site)),
    nYear = max(1L, nlevels(year)),
    site = as.integer(site),
    year = as.integer(year),
    fronds = as.numeric(data$fronds),
    weight = as.numeric(data$weight),
    fronds_ref = weight_fronds_ref(data$fronds),
    prior_intercept_mu = priors$intercept$mean,
    prior_intercept_sd = priors$intercept$sd,
    prior_fronds_mu = priors$fronds$mean,
    prior_fronds_sd = priors$fronds$sd,
    prior_shape_rate = priors$shape$rate,
    prior_sd_site_rate = priors$sd_site$rate,
    prior_sd_year_rate = priors$sd_year$rate,
    prior_sd_site_year_rate = priors$sd_site_year$rate,
    prior_only = as.integer(prior_only),
    site_year_on = as.integer(site_year_on)
  )
}

# Geometric-mean centering reference for log-fronds (i.e. the value whose log is
# mean(log(fronds)), so centered log-fronds has mean zero). Computed from the
# data and stored in the fit meta, so the Stan fit and the R-side predictions
# share one reference. Falls back to 5 for zero-row (prior-only) data (the
# analysis-project reference and the macro median frond count).
weight_fronds_ref <- function(fronds) {
  if (length(fronds) == 0L) {
    return(5)
  }
  exp(mean(log(fronds)))
}
