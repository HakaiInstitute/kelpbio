## Context

The analysis project fits the presence hurdle for *Nereocystis* only, because its *Macrocystis* calibration data hold no empty survey.
A user's data for either species may or may not hold one (a lost *Macrocystis* bed, for example).
HakaiInstitute/kelpbio#66 records refits on thinned and forced data that set the rule below.

## Decisions

### The presence part is switched on by the data, not the species

The fitting layer sets a structural flag when any fitted survey has biomass of exactly zero, and the shared Stan file sizes the presence parameters by it.
A Gamma cannot take a zero, so without the flag the fit could not use such data; with no empty survey there is nothing for the presence part to fit.

Alternative: switch on by species (the analysis project's split).
Rejected: *Macrocystis* data with an empty survey would then have to be refused.

### Separation warns, it does not refit

When every empty survey sits at or below every occupied survey in percent cover (ties included), the presence slope runs into its prior and sampling may diverge.
In #66's refits the totals and `cover_slope` moved under 1% in every such case, because totals are evaluated at full cover.
A warning naming a tighter prior (`kb_prior_normal(mean = 0, sd = 5)`) is therefore enough. The check uses the raw percent cover, before tide correction.

Alternative: fall back to an intercept-only presence part. Rejected (proposal Non-goals).

### Parameter names

`presence_intercept` and `presence_cover_slope`: the presence part is a second linear predictor, so its terms take the rule names (`intercept`, `cover_slope`) prefixed with the quantity it predicts, which also keeps them distinct from the mean's `cover_slope`.
`decisions/parameter-naming.md` gains this rule.
The slope is per percentage point of cover, as in the analysis project, so its prior is the analysis project's Normal(0, 20).

### The survey's plant-weight uncertainty enters as a CV

`weight_cv = biomass_sd / biomass`, each relative to the fitted mean, so a survey's pull on the line depends only on how precisely its plants were weighed, not on which side of the line it lies.
Entering it as an SD gave surveys above the line less pull (analysis project, `decisions/cover-biomass-model.md`, 2026-10-28).
An empty survey's `weight_cv` is never used, since it enters through the presence part alone.
