## Context

The carbon models are the analysis project's `stan/nereo/carbon/carbon-nereo.stan`
and `stan/macro/carbon/carbon-macro.stan`, which are identical: the carbon fraction
of a dry lab sample is Beta with `logit(mu) = bCarbon + bMonth[month]` and precision
`bPhi`. The structure matches the wet/dry model, so kelpbio adapts it the same way
(`openspec/changes/archive/2026-10-02-add-wetdry-models/design.md`).

## Decisions

### Pool over months, as for wet/dry

The month effect is dropped and samples are pooled. Carbon varies more by month
than the dry:wet ratio: the raw July mean is 0.247 (*Nereocystis*) and 0.297
(*Macrocystis*), against pooled means of 0.263 and 0.317, so the pooled estimate is
about 6% above July for both species, with the higher fractions in spring (May
0.301 and 0.346). The same rule applies as for wet/dry: a season-specific fraction
is estimated by fitting to that season's samples, which the roxygen states. A month
effect remains the alternative if a pooled carbon fraction proves too coarse for
reporting; it would be the package's only month dimension.

### Columns: the lab's two masses

The isotope lab reports the mass of each dried sample (mg) and the carbon measured
in it (µg); the analysis divides them. kelpbio takes `sample_mass_mg` and
`carbon_mass_ug` as reported and computes the fraction
`carbon_mass_ug / 1000 / sample_mass_mg`, so users do no unit conversion, the
step where a factor-of-1000 slip is most likely. This matches wet/dry, which also
takes masses rather than a ratio. Each suffix states its unit, so the two columns'
different units are explicit. Alternatives: a `carbon_fraction` column (users
convert µg to mg themselves), or both masses in mg (the same conversion, moved).

A carbon fraction of 1 or more errors (a sample mass in grams produces one). The
analysis excludes fractions outside 0.10 to 0.50, the stoichiometric range for kelp
tissue (Pessarrodona et al. 2023); kelpbio instead warns with the number of such
samples and keeps them, following the package rule of flagging rather than silently
excluding. Carbon given in mg rather than µg puts every fraction far below 0.10, so
the warning also catches that unit mistake.

### Parameters, priors, and shared Beta helpers

`bCarbon` (logit mean, named after the response) and `bPrecision`, as for wet/dry.
The priors match the analysis: Normal(-0.8, 0.3) on `bCarbon` (a prior mean
fraction of about 0.31, informative but well inside the data) and Exponential(0.001)
on `bPrecision`. Carbon and wet/dry share the Beta log-likelihood, deviance, and
predictive draws through helpers that take the observed fractions, so the Beta code
is written once. One `inst/stan/carbon.stan` serves both species, and every method
registers at `kb_fit_carbon`.

## Risks

- The pooled fraction is about 6% above the July fraction, which passes directly to
  carbon biomass if July is the reporting month. Mitigation: the roxygen says how to
  estimate a season-specific fraction, and the month comparison above is recorded.
