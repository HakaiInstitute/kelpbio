# The fit shared by the cover biomass models: the cover-biomass calibration, identical in
# form across species and differing only in the default priors. The exported
# kb_fit_cover_biomass_<species>() functions supply the species, their data check, and
# their default priors (decisions/species-as-variant.md).
fit_cover_biomass_model <- function(
  data,
  biomass,
  priors,
  species,
  check_data,
  defaults,
  ...,
  conf_level,
  prior_only,
  chains,
  niters,
  nthin,
  cores,
  seed,
  progress,
  progress_dir
) {
  progress <- rlang::arg_match(progress, c("bar", "verbose", "none"))
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

  # The species' own check, so its errors name the function users know.
  check_data(data, biomass, x_name = "`data`")
  conf_level <- cover_conf_level(biomass, conf_level)
  joined <- join_cover_biomass(data, biomass)
  notify_cover_unmatched(joined$unmatched, progress = progress)
  data <- joined$data
  priors <- resolve_priors(priors, defaults)
  stan_data <- assemble_cover_biomass_data(
    data,
    priors,
    conf_level = conf_level,
    prior_only = prior_only
  )

  pars <- c("bCanopy", "bFloor", "bTide", "bScaling", "sSite", "sYear")
  core <- fit_stan(
    stanmodels$cover_biomass,
    stan_data,
    param_vars = c(pars, "bSite", "bYear"),
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir,
    stanmodel_name = "cover_biomass",
    ...
  )

  new_kb_fit(
    core,
    data = data,
    priors = priors,
    model = "cover_biomass",
    species = species,
    # The response is a biomass per m^2, so there is no survey effort.
    offset = NULL,
    terms = list(fixed = pars, random = c("bSite", "bYear")),
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      # One survey per site-year is typical, so a site:year effect would be
      # confounded with the residual; the model never has one.
      site_year_on = FALSE,
      response = "biomass_kg_m2",
      # Curves run over tide-corrected cover, a proportion of the plot, which
      # the data do not hold as a column (it depends on the fitted bTide).
      predictor = "cover",
      predictor_range = c(0, 1),
      # The level of the supplied limits, which sets every row's log-scale SD.
      conf_level = conf_level
    )
  )
}
