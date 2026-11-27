## Why

kelpbio's parameters use the Poisson Consulting `b`/`s` prefix convention
(`bWeight`, `sSiteYear`), while the prior entries a user edits use different,
readable names (`intercept`, `sd_site_year`). A user has to translate between the
two to change a prior, read `kb_model_describe()`, or act on a flagged parameter,
and the companion Shiny app has to carry the same mapping. The prefixes serve a
house tool (finding monitored parameters by prefix) that kelpbio does not use: it
lists its terms explicitly.

The Stan data fields have the same problem one level down: they abbreviate or
rename the input columns (`diameter` for `diameter_mm`, `area` for `area_m2`), so
`kb_stancode()` shows reviewers names that are not in their data. Both renames
touch every Stan file and require refitting every pre-fit object and fixture, so
they are done together.

## What Changes

- **BREAKING** Every parameter is renamed to a readable snake_case name, applied
  by fixed rules (see design.md) rather than case by case: `intercept`;
  `<predictor>_slope` and `<predictor>_power` for parameters tied to a
  predictor; `sd_<group>`, `<group>_effect`, and `z_<group>` for group-level
  terms; `shape`, `dispersion`, `precision`, and `sd_residual` for distribution
  parameters; `<quantity>_floor`; a `logit_` prefix on a standalone scalar stored
  on the logit scale. The names appear in `tidy()`, `coef()`, `summary()`,
  `print()`, `glance()`, `samples()`, `kb_model_describe()`, and `kb_stancode()`.
- **BREAKING** Every prior entry takes the name of the parameter it sets, so the
  `term` in any summary is the entry to edit. Entries renamed: weight `floor` to
  `weight_floor`, `density` to `density_slope`, `power` to `diameter_power`,
  `fronds` to `fronds_slope`; density `zero_inflation` to `logit_zero_inflation`;
  cover `canopy` to `cover_slope`, `floor` to `biomass_floor`, `tide` to
  `tide_height_slope`, `scaling` to `error_scaling`. All others keep their names.
- New `kb_prior_lognormal(meanlog, sdlog)`. The cover `cover_slope` default
  becomes a lognormal prior on the slope itself, with the same hyperparameters as
  the current Normal prior on its log.
- Stan data fields that pass an input column through take that column's name
  (`diameter_mm`, `weight_kg`, `area_m2`, `canopy_area_m2`, `plot_area_m2`,
  `tide_height_m`); derived fields keep descriptive names; sizes become `n_obs`,
  `n_site`, `n_year`; prior hyperparameters become `prior_<entry>_<argument>`,
  named after the prior constructor's arguments (`mean`, `sd`, `rate`, `meanlog`,
  `sdlog`).
- Every pre-fit object and test fixture is refitted.
- CLAUDE.md's parameter and input-column naming rules are rewritten, and a new
  `decisions/parameter-naming.md` records the rules and the mapping to the
  analysis project's parameter names.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: the prior entries of every model, and the prior constructors, which
  gain `kb_prior_lognormal()`.
- `predictions`: the expected-value requirement names the *Nereocystis* weight
  residual SD, now `sd_residual`.

## Non-goals

- Any change to a model, a default prior's values, or a prediction.
- Renaming the input columns, the structural flags (`site_year_on`, `density_on`,
  `floor_on`, `prior_only`), or the output columns of summaries and predictions.
- Prior sensitivity (`add-prior-sensitivity`), which rebases onto this change
  and drops its parameter-to-prior pairing once names match.

## Impact

- Every `inst/stan/*.stan` file, `R/stanmodels.R` and `src/` (regenerated), every
  `assemble_*_data()`, every R function reading draws by name (expected values,
  log-likelihood, residuals, posterior prediction, plot and site biomass),
  `kb_priors_*()`, `kb_model_describe()`, tests, snapshots (summaries, print,
  describe, priors), specs, roxygen, the demo scripts, and the `data-raw/`
  simulation scripts that name parameters.
- kelpbioshiny's prior inputs and labels follow the new entry names.
