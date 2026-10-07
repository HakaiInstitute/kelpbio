#' Assemble the Stan Data List for the Macrocystis Size Model
#'
#' Map validated size data and a resolved prior list to the `data` block of
#' `inst/stan/size_macro.stan`. `site` and `year` are encoded as integer factor
#' codes and `fronds` is passed as an integer count. Zero-row data is supported
#' (for prior-only fits): `n_obs` is `0` and `n_site` / `n_year` fall back to `1`.
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#'
#' @return A named list suitable for `rstan::sampling(stanmodels$size_macro, data = .)`.
#' @noRd
assemble_size_macro_data <- function(
  data,
  priors,
  prior_only = FALSE,
  site_year_on = TRUE
) {
  c(
    group_stan_data(data),
    list(
      n_obs = nrow(data),
      fronds = as.integer(data$fronds),
      prior_only = as.integer(prior_only),
      site_year_on = as.integer(site_year_on)
    ),
    prior_data(priors)
  )
}
