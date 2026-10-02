# The wet/dry fit shared by both species: they have one model and data contract,
# so the exported kb_fit_wetdry_<species>() functions supply only their species,
# data check, and default priors (decisions/species-as-variant.md).
fit_wetdry <- function(
  data,
  priors,
  check_data,
  defaults,
  species,
  ...,
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
  check_data(data, x_name = "`data`")
  priors <- resolve_priors(priors, defaults)
  stan_data <- assemble_wetdry_data(data, priors, prior_only = prior_only)

  core <- fit_stan(
    stanmodels$wetdry,
    stan_data,
    param_vars = c("bDryWet", "bPrecision"),
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir,
    stanmodel_name = "wetdry",
    ...
  )

  new_kb_fit(
    core,
    data = data,
    priors = priors,
    model = "wetdry",
    species = species,
    # A ratio of masses from the same sample, so there is no survey effort.
    offset = NULL,
    terms = list(fixed = c("bDryWet", "bPrecision"), random = character(0)),
    prior_only = prior_only,
    nthin = as.integer(nthin),
    meta_extra = list(
      # The ratio is derived from wet_mass_g and dry_mass_g, not a data column.
      response = "dry_wet_ratio"
    )
  )
}
