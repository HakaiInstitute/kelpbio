## Context

The wet/dry models are the analysis project's `stan/nereo/wetdry/wetdry-nereo.stan`
and `stan/macro/wetdry/wetdry-macro.stan`, which are identical: the dry:wet ratio of
a lab sample is Beta with `logit(mu) = bDryWet + bMonth[month]` and precision `bPhi`.
The analysis biomass step evaluates the ratio at the survey month and reports annual
estimates in July. kelpbio works at site-year resolution with no month dimension
(`CLAUDE.md`), which leaves wet/dry with no random effects.

## Decisions

### Pool over months rather than evaluate July

The ratio is estimated from all samples with no month effect. A fit on the analysis
data with the analysis priors compared three estimates of the expected ratio:

| Approach | *Nereocystis* | *Macrocystis* |
|---|---|---|
| All samples, no month effect | 0.0884 (0.0863 to 0.0907) | 0.1255 (0.1224 to 0.1288) |
| July samples only | 0.0877 (0.0842 to 0.0912) | 0.1296 (0.1238 to 0.1355) |
| Month effect, July estimate | 0.0879 (0.0850 to 0.0907) | 0.1287 (0.1238 to 0.1340) |

The July estimates differ from the pooled one by under 1% (*Nereocystis*) and about
3% (*Macrocystis*), small next to the density and weight uncertainty that dominates
biomass. Pooling also matches the other sub-models, which pool across months, so
biomass is on one basis. July is the only month sampled in 2017 and 2019, so the
month effect is partly a year effect. A season-specific ratio is obtained by fitting
to that season's samples, which reproduces the analysis July estimate within 1% with
no month machinery. Alternative: a month effect with a month argument at prediction,
rejected as the only month dimension in the package for a difference this small.

The pooled interval describes the average over the sampled months; it is narrower
than the between-month spread (the analysis month SD on the logit scale is 0.04
for *Nereocystis* and 0.09 for *Macrocystis*).

### Columns and response

The input is `wet_mass_g` and `dry_mass_g`, following the unit-suffix convention;
the response is their ratio, which the model takes in `(0, 1)`. The unit cancels
in the ratio, so grams were chosen for readability rather than the lab's
milligrams. The data check requires `0 < dry_mass_g < wet_mass_g`, and the
plausibility warning flags a median above 1000 g, which milligrams entered as grams
produce. Alternatives: a single `dry_wet_ratio` column (loses the masses and the
dry < wet check), or unsuffixed masses in any unit (breaks the convention). The
check lists only the two mass columns; other columns are ignored.

`meta$response` is `dry_wet_ratio`, the quantity every summary reports; it is
derived from the two columns rather than stored. `log_lik()` is on the ratio scale.
The analysis subtracts `log(wet_mass)` to put it on the dry-mass scale, which only
matters when comparing against a model of dry mass itself.

### Parameter names

`bDryWet`, the logit mean ratio, keeps the analysis name, named after the response
as the other intercepts are. `bPrecision` is the Beta precision, named in words like
`bShape` and `bDispersion` (the analysis calls it `bPhi`). Priors: `intercept`
Normal(0, 2) and `precision` Exponential(0.01), as in the analysis.

### One Stan file, methods at the model tier

The two species share one model, so there is one `inst/stan/wetdry.stan`, and every
method registers at `kb_fit_wetdry`; the species functions are kept so users learn
one naming rule and `meta$species` is set for the biomass composition
(`decisions/species-as-variant.md`, which is updated to allow a shared Stan file for
structurally identical species). Alternative: two identical `.stan` files, rejected
as duplicated code with no behavioural difference.

### A single population estimate

With no groups or predictor, every row has the same expected ratio.
`kb_predict_wetdry(fit)` returns one row and takes no `new_data`; `fitted()`,
`augment()`, and the `posterior_*()` generics still work row-wise, as for every
model. There is no `_by` verb, as `decisions/prediction-engine.md` anticipates for
scalar models, and no plot: a one-row prediction has no x-axis, and
`kb_plot_predictions()` already errors on it.

## Risks

- The pooled interval is narrower than month-to-month variation, so it can read as
  more certain than a single survey month warrants. The roxygen states what it
  estimates and how to obtain a season-specific ratio.
- Blade and stipe have the same mean ratio but different spread (analysis tissue
  comparison); one precision averages over the two, which leaves the mean ratio
  unaffected.
