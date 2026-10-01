#' Fit a Nereocystis Weight Model
#'
#' Fit an allometric weight model for *Nereocystis luetkeana* via Stan.
#'
#' @details
#' Log wet weight (kg) is modelled with a Normal likelihood. `form` sets expected
#' weight as a function of sub-bulb diameter (mm), with `x = diameter / d0` and
#' `d0` the geometric mean diameter of the data:
#'
#' - `"packard_floor"` (the default): `bFloor + alpha * x^bPower`, the
#'   three-parameter power function of Packard (2023). The weight floor
#'   `bFloor` makes the relationship curve on log-log axes: the local allometric
#'   exponent rises with plant size and levels off toward `bPower` as the
#'   floor's share of weight shrinks.
#' - `"power"`: `alpha * x^bPower`, a power law, which is a straight line on
#'   log-log axes with the single exponent `bPower`.
#'
#' `"packard_floor"` is recommended. On a coastwide compilation of *Nereocystis*
#' harvests (Alaska to California), the power law fitted worse and
#' underestimated the weight of both the smallest and the largest plants.
#'
#' The year, site, and `site:year` effects act on `alpha`, so they scale the
#' size-dependent part of the weight while any floor is common to all groups.
#'
#' When `data` has a `density` column (stipes per m², a site-year value),
#' `log(alpha)` also includes `bDensity` times density standardised by its mean
#' and SD over the fitted plants. Site-years without a recorded density take the
#' mean. The density term is omitted when fewer than two distinct site-year
#' densities are recorded.
#'
#' The site:year effect is set from the data: it is omitted when the data span a
#' single year and included otherwise. When no site spans more than one year it is
#' kept with a warning, since the site and site:year effects cannot then be
#' interpreted separately.
#'
#' @inheritSection params Sampling
#' @inheritParams params
#' @param form A string, one of `"packard_floor"` (the default) or `"power"`,
#'   giving the mean function of weight in diameter (see Details).
#' @param ... Additional arguments passed to [rstan::sampling()], including a
#'   `control` list (merged over the `adapt_delta = 0.95` default); see the
#'   `control` argument of [rstan::stan()] for the available entries.
#'
#' @return An object of class `c("kb_fit_weight_nereo", "kb_fit_weight", "kb_fit")`.
#' @references Packard, G. C. (2023). What is complex allometry? *Biology Open*,
#'   12, bio060148. \doi{10.1242/bio.060148}
#' @family model
#' @export
#'
#' @examples
#' if (interactive()) {
#'   fit <- kb_fit_weight_nereo(data_weight_sim_nereo)
#'   tidy(fit)
#' }
#' # A pre-fit example model is included with the package:
#' tidy(fit_weight_sim_nereo)
kb_fit_weight_nereo <- function(
  data,
  priors = NULL,
  form = c("packard_floor", "power"),
  ...,
  prior_only = FALSE,
  chains = 4L,
  niters = 1000L,
  nthin = 1L,
  cores = NULL,
  seed = NULL,
  progress = c("bar", "verbose", "none"),
  progress_dir = NULL
) {
  form <- rlang::arg_match(form)
  progress <- rlang::arg_match(progress)
  .chk_sampler_args(
    prior_only = prior_only,
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir
  )

  kb_check_data_weight_nereo(data)
  # The site:year effect is determined from the data
  site_year <- site_year_structure(data)
  notify_site_year(site_year, progress = progress)
  density <- density_structure(data)
  notify_density(density, progress = progress)

  priors <- resolve_priors(priors, kb_priors_weight_nereo())
  # Shared by the Stan fit and R-side predictions (stored in meta below).
  diameter_ref <- weight_diameter_ref(data$diameter)
  stan_data <- assemble_weight_nereo_data(
    data,
    priors,
    diameter_ref,
    density = density,
    prior_only = prior_only,
    site_year_on = site_year$on,
    floor_on = form == "packard_floor"
  )

  core <- fit_stan(
    stanmodels$weight_nereo,
    stan_data,
    param_vars = c(
      "bWeight",
      "bPower",
      "bFloor",
      "bDensity",
      "sSite",
      "sYear",
      "sSiteYear",
      "sWeight",
      "bSite",
      "bYear",
      "bSiteYear"
    ),
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir,
    stanmodel_name = "weight_nereo",
    ...
  )

  new_kb_fit(
    core,
    data = data,
    priors = priors,
    model = "weight",
    species = "nereocystis",
    # Weight is measured per plant, not per unit of survey effort.
    offset = NULL,
    terms = list(
      fixed = c(
        "bWeight",
        "bPower",
        if (form == "packard_floor") "bFloor",
        if (density$on) "bDensity",
        "sSite",
        "sYear",
        if (site_year$on) "sSiteYear",
        "sWeight"
      ),
      random = c(
        "bSite",
        "bYear",
        if (site_year$on) "bSiteYear"
      )
    ),
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      form = form,
      predictor_ref = diameter_ref,
      site_year_on = site_year$on,
      density_on = density$on,
      density_mean = density$mean,
      density_sd = density$sd,
      density_levels = density$levels,
      # Predictor/response column names let the model-level prediction and plot
      # code stay species-agnostic (macro uses "fronds").
      predictor = "diameter",
      response = "weight"
    )
  )
}
