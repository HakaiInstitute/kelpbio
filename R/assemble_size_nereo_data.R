#' Assemble the Stan Data List for the Nereocystis Size Model
#'
#' Map validated size data and a resolved prior list to the `data` block of
#' `inst/stan/size_nereo.stan`. `site` and `year` are encoded as integer factor
#' codes and `diameter_mm` is passed through. Zero-row data is supported (for
#' prior-only fits): `n_obs` is `0` and `n_site` / `n_year` fall back to `1`.
#'
#' @inheritParams params
#' @param priors A list of the resolved named priors (see `resolve_priors()`).
#'
#' @return A named list suitable for `rstan::sampling(stanmodels$size_nereo, data = .)`.
#' @noRd
assemble_size_nereo_data <- function(
  data,
  priors,
  prior_only = FALSE,
  site_year_on = TRUE
) {
  site <- factor(data$site)
  year <- factor(data$year)

  c(
    list(
      n_obs = nrow(data),
      n_site = max(1L, nlevels(site)),
      n_year = max(1L, nlevels(year)),
      site = as.integer(site),
      year = as.integer(year),
      diameter_mm = as.numeric(data$diameter_mm),
      prior_only = as.integer(prior_only),
      site_year_on = as.integer(site_year_on)
    ),
    prior_data(priors)
  )
}
