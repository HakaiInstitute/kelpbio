# The fit shared by the proportion models (wet/dry, carbon): a Beta likelihood on
# one derived proportion per sample, with a logit-mean intercept and a precision,
# identical across species. The exported kb_fit_<model>_<species>() functions
# supply the model and species, their data check, default priors, and Stan data
# assembler (decisions/species-as-variant.md).
fit_beta_model <- function(
  data,
  priors,
  model,
  species,
  response,
  check_data,
  defaults,
  assemble,
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
  stan_data <- assemble(data, priors, prior_only = prior_only)

  core <- fit_stan(
    stanmodels[[model]],
    stan_data,
    param_vars = c("intercept", "precision"),
    chains = chains,
    niters = niters,
    nthin = nthin,
    cores = cores,
    seed = seed,
    progress = progress,
    progress_dir = progress_dir,
    stanmodel_name = model,
    ...
  )

  new_kb_fit(
    core,
    data = data,
    priors = priors,
    model = model,
    species = species,
    # A proportion within one sample, so there is no survey effort.
    offset = NULL,
    terms = list(fixed = c("intercept", "precision"), random = character(0)),
    prior_only = prior_only,
    nthin = as.integer(nthin),
    # The response is the derived proportion every summary reports.
    meta_extra = list(response = response)
  )
}
