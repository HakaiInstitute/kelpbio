## Context

The analysis project's production *Nereocystis* weight model has
`log(alpha) = bWeight + bDensity * density + bYear + bSite + bSiteYear`, with
`density` the site-year stipe density standardised by its mean and SD over the
fitted plants (`bDensity` -0.159, -0.243 to -0.073). Its biomass integration
sets site-years without a density survey to the mean. The form comparison
(`models-weight-nereo-density.R`) found raw linear, log-linear, and no density
indistinguishable by LOO (dELPD -0.5, SE 0.8 and -0.7, SE 1.4), and production
uses raw linear.

kelpbio users do not all have density surveys, and those who do may not have one
for every harvested site-year. The covariate therefore has to be optional at
both fit and prediction time.

## Goals / Non-Goals

**Goals:**
- Match the analysis model when density is supplied.
- Reduce exactly to the current model when it is not.
- One rule for resolving a row's density, shared by fitting and every prediction
  path, so the two cannot disagree.

**Non-Goals:** as listed in the proposal (macro, latent imputation, a density
sub-model link, blade fraction, unit checks).

## Decisions

### Gate the term with a data flag

A `density_on` (0/1) value in the Stan data block multiplies the density term,
as `site_year_on` does for site:year (the structural-flag convention in
`openspec/config.yaml`). `bDensity` is always declared; when the flag is off it
samples its prior, is excluded from `meta$terms`, and the R-side mean ignores it.
One compiled model serves both structures, so there is no second `.stan` file and
no second recompile path.

Alternative: a separate model for the density variant. Rejected: the variant is
one additive term, which is what flags are for.

### Standardise raw density over fitted plants

Raw density, centred and scaled by its mean and SD over the fitted rows with a
recorded value, as in the analysis production model. Plant weighting (rows, not
site-years) matches the analysis, keeps `bWeight` as the log scale at the typical
plant's density, and lets the analysis prior `normal(0, 0.5)` carry over. Because
density enters standardised, `bDensity` and the fit do not depend on the density
unit, only on its being consistent between fitting and prediction.

Alternative: log density. Indistinguishable by LOO; raw keeps parity with the
analysis estimates.

### Unrecorded site-years take the mean at fit time

Rows whose site-year has no recorded density enter with standardised density 0.
Those rows carry no information on `bDensity` (no spread in the covariate), and
`bSiteYear` absorbs whatever their actual density contributes, so the cost is
small.

Alternatives:
- Latent imputation (a `Normal(0, 1)` parameter per unrecorded site-year).
  Density is a site-year quantity, so the latent value is not separable from
  `bSiteYear` and its posterior stays near the prior. It adds parameters and
  code for no change in the weight predictions.
- Dropping the rows. Loses weight data for the allometry, which does not need
  density.

### Resolve prediction density: supplied, then recorded, then mean

Per row: a supplied `density`; else the recorded value for a fitted site-year;
else the fitted mean. The middle step makes predictions at the observed data
(`new_data = NULL`, `augment()`, `residuals()`) use the same values the fit did,
and makes `kb_predict_weight_by(by = c("site", "year"))` curves site-year
specific without a new argument. The fallback matches the analysis biomass
integration.

Alternative: under `new_levels = "sample"`, draw density for unrecorded
site-years from the recorded ones. It would widen intervals slightly, but
`new_levels` governs random effects, and tying a covariate to it muddies that
axis for an effect the LOO comparison could not separate from zero. It can be
added later without changing the default.

### Structure: a pure helper pair, values in meta

- `density_structure(data)` (pure, like `site_year_structure()`): the per
  site-year recorded density, `on`, `mean`, `sd`, and the number of unrecorded
  site-years. Fitting records its values in `meta` (`density_on`,
  `density_mean`, `density_sd`, `density_levels` keyed `"site:year"` like
  `site_year_levels`), per the meta-versus-dispatch rule in
  `decisions/architecture.md` (values frozen at fit time).
- `standardised_density(grid, on, mean, sd, levels)`: the resolution rule,
  returning a numeric vector (0 where the rule falls through to the mean). Called
  by `assemble_weight_nereo_data()` at fit time and by
  `.linpred.kb_fit_weight_nereo()` at prediction time.

Because the observed-data path already routes `fit$data` through `.linpred()`,
no prediction verb needs its own density handling.

### Row-level NA inside a recorded site-year

A row with `NA` takes its site-year's recorded value; conflicting values within a
site-year are a data error. This follows from density being a site-year quantity
and is the same lookup prediction uses.

### Messages

Informational, suppressed by `progress = "none"`, like the site:year notice: one
when a `density` column is present but the term is omitted, one giving the count
of unrecorded site-years when the term is on. No message when there is no
`density` column, the common case for users without density data.

## Risks / Trade-offs

- [Density supplied in a different unit at prediction than at fitting] → the
  unit (stipes per m²) is documented on the data check and `new_data`; the stored
  mean and SD make a mismatch visible as implausible predictions but cannot catch
  it. Unit plausibility checks are a separate change.
- [Many unrecorded site-years dilute the covariate's information] → the fit
  message reports the count; `bDensity` is estimated only from recorded
  site-years, so its interval widens rather than biasing strongly.
- [Fits from before this change] → a missing `meta$density_on` is read as
  `FALSE`, matching those fits' structure.

## Migration Plan

Additive: existing calls without `density` behave as before. `kb_priors_weight_nereo()`
gains an entry, so a user passing a complete custom list still works (unmodified
entries default). The Stan model recompiles, and the bundled simulated data,
pre-fit model, and nereo test fixture are rebuilt.
