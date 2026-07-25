# Parameter Descriptions for Package

Default parameter descriptions which may be overridden in individual
functions.

## Arguments

- ...:

  These dots are for future extensions and must be empty.

- data:

  A data frame of weight observations (see
  [`kb_check_data_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_nereo.md)
  for the required columns).

- priors:

  A named list of prior objects (see
  [`kb_priors_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_weight_nereo.md)),
  or `NULL` to use the defaults. Supplied entries override the
  corresponding defaults; unspecified entries keep their defaults.

- prior_only:

  A flag specifying whether to sample from the priors only (the
  likelihood is switched off), for prior predictive checks.

- chains:

  A whole number of MCMC chains.

- niters:

  A whole number of saved post-warmup draws per chain (warmup defaults
  to match).

- nthin:

  A whole number giving the thinning interval.

- cores:

  A whole number of cores for parallel chains, or `NULL` to use
  `getOption("mc.cores")` (falling back to `chains`), capped at the
  available cores.

- seed:

  A whole number passed to
  [`rstan::sampling()`](https://mc-stan.org/rstan/reference/stanmodel-method-sampling.html)
  to make the fit reproducible, or `NULL` (the default). When `NULL`, a
  seed is drawn from R's RNG, so a preceding
  [`set.seed()`](https://rdrr.io/r/base/Random.html) also makes the fit
  reproducible; an explicit `seed` takes precedence over the RNG state.

- progress:

  A string, one of `"bar"` (the default, a console progress bar),
  `"verbose"` (rstan's per-iteration output and diagnostic warnings), or
  `"none"` (silent). Controls fit-time console output only.

- progress_dir:

  A string giving an existing directory in which to write a pollable
  progress artifact (read by
  [`kb_fit_progress()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_progress.md)),
  or `NULL` (the default) to write none.

- conf_level:

  A number between 0 and 1 giving the compatibility-interval level.

- estimate:

  A function that reduces a numeric vector of posterior draws to a
  scalar point estimate (e.g. `median` or `mean`).

- sig_fig:

  A whole number of significant figures for summary output.

- include_random_effects:

  A flag specifying whether to include the group-level random-effect
  terms in the output.

- rhat:

  A number giving the maximum acceptable Rhat.

- esr:

  A number giving the minimum acceptable effective sample rate
  (effective sample size divided by the number of draws).

- by:

  A character vector of grouping factors, each drawn as a separate
  curve, or `NULL` for a single population-level curve. Each named
  factor is expanded over its observed levels and conditioned on its
  estimated random effects.

- new_levels:

  A string, one of `"sample"` or `"average"`, controlling how random
  effects that are not conditioned on are treated (factors absent from
  the prediction, and any new level not seen in the fit). `"sample"`
  draws a new random effect from `Normal(0, sd)`, widening the interval
  to include between-group variation; `"average"` holds the random
  effects at zero, giving the typical group. Known levels are always
  conditioned on. `"sample"` draws fresh randomness on each call, so set
  a seed with [`set.seed()`](https://rdrr.io/r/base/Random.html) for a
  reproducible interval.

- representative_site:

  A character vector of site levels present in the fit, or `NULL` (the
  default). When supplied, a new or absent site takes its site main
  effects (intercept and slope) from the named reference site (the
  per-draw average when several are named), instead of the `new_levels`
  treatment; the `site:year` interaction still follows `new_levels`.

## Details

A flag is a non-missing logical scalar.

A string is a non-missing character scalar.
