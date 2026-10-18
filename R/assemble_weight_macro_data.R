#' Assemble the Stan Data List for the Macrocystis Weight Model
#'
#' Map validated weight data and a resolved prior list to the `data` block of
#' `inst/stan/weight_macro.stan`. `site` and `year` are encoded as integer factor
#' codes; the raw `fronds` and `weight_kg` vectors are passed through (the Stan model
#' applies the `log(fronds) - log(fronds_ref)` transform). `fronds_ref` is the
#' geometric mean of the observed frond count. Zero-row data is supported (for
#' prior-only fits): `n_obs` is `0` and `n_site` / `n_year` fall back to `1`.
#'
#' @inheritParams params
#' @param priors A resolved named prior list (see `resolve_priors()`).
#'
#' @returns A named list suitable for `rstan::sampling(stanmodels$weight_macro, data = .)`.
#' @noRd
assemble_weight_macro_data <- function(
  data,
  priors,
  prior_only = FALSE
) {
  c(
    group_stan_data(data),
    list(
      n_obs = nrow(data),
      fronds = as.numeric(data$fronds),
      weight_kg = as.numeric(data$weight_kg),
      # 5 fronds, the Macrocystis median, for zero-row data.
      fronds_ref = geometric_ref(data$fronds, fallback = 5),
      prior_only = as.integer(prior_only)
    ),
    prior_data(priors)
  )
}
