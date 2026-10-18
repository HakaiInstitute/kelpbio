## Why

The weight, size, and density models omit the site:year effect when the data
cover a single year (`fitting` spec, "The data determine which effects are
fitted"). A simulation across seven sampling designs found no case where
omitting the effect improves estimates enough to justify the rule: where the
effect is identified, omitting it gives intervals far below nominal coverage,
and where it is aliased with the site or year effect, as in single-year data,
omitting it changes prediction scores by no more than about 15% in either
direction while giving overconfident intervals for new years and site means
(see design.md). Fitting the effect always also gives one model structure for
every data set.

## What Changes

- The weight, size, and density models always fit the site:year effect,
  including for single-year data. The informational message that it was
  omitted is removed.
- Single-year data now raise the existing aliasing warning: the site:year
  effect cannot be separated from the site effect (and, with one site, from the
  year effect either).
- `tidy()`, `coef()`, `summary()`, `kb_model_describe()`, `kb_samples()`, and
  `kb_sensitivity()` report the site:year terms for single-year fits, and
  predictions for a single-year fit include site:year variation under
  `new_levels = "sample"`.
- The cover biomass models are unchanged: they have site and year effects and
  no site:year effect.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: "The data determine which effects are fitted" no longer omits the
  site:year effect for single-year data.
- `summaries`: the omitted-effect requirements and scenarios no longer cite
  site:year, which no fit now omits.

## Non-goals

- No user argument to turn the site:year, site, or year effect on or off. A
  strong prior on `sd_site_year` through `kb_priors_*()` already expresses an
  expectation of little site:year variation.
- No change to the default priors on the group-level SDs.
- No change to how effects with a single level (one site or one year) are
  fitted; their divergent transitions are a separate issue.
- No README or vignette update; documenting sparse and aliased data and when to
  adjust priors is deferred to the pending documentation pass.

## Impact

- `R/site_year_structure.R` and the six `kb_fit_*()` functions for weight,
  size, and density; their roxygen and tests.
- The six Stan models with a site:year effect lose the data flag that switched
  it off, so the pre-fit models and test fixtures for weight, size, and density
  are rebuilt.
