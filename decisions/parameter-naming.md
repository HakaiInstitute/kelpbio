# Decision: readable, rule-based parameter names shared with the prior entries

Status: accepted (2026-10)

## Context

kelpbio's parameters first followed the Poisson Consulting convention used in
the analysis project and in bboutools and embr: a `b` prefix for estimated
parameters and `s` for standard deviations (`bWeight`, `sSiteYear`). The prior
entries users edit were later given readable names (`intercept`,
`sd_site_year`), and the Stan data fields abbreviated the input columns
(`diameter` for `diameter_mm`). One model was therefore described by three
vocabularies, and a user had to translate between them to change a prior, read
`kb_model_describe()`, or act on a parameter flagged by a diagnostic. The
companion Shiny app had to carry the same mapping.

The prefixes exist so that house tools can find monitored parameters by
pattern. kelpbio does not use that: each fit lists its terms explicitly.

## Decision

Every parameter takes a readable snake_case name, chosen by fixed rules rather
than case by case, and every prior entry takes the name of the parameter it
sets. Stan data fields that pass an input column through take the column's
name. The rules are below.

The rules apply even where no name would collide (`diameter_power`, not
`power`), so a new sub-model's names follow from the rules and the names stay
predictable. Two of them avoid collisions that the plain role names would
cause: a slope carries its predictor's name (`fronds_slope`), because
`fronds`, `canopy_area_m2`, and `canopy_tide_height_m` are already Stan data fields or
input columns, and a floor carries its quantity (`weight_floor`, `biomass_floor`),
because `floor` is a Stan function.

`dispersion` keeps kelpbio's direction (variance `mu + dispersion * mu^2`, zero
for the Poisson), which matches Stan's naming of phi as the precision and the
`theta` of the extras package; MASS and glmmTMB name the inverse quantity.


## Rules

Parameter names are snake_case, applied by rule even where nothing would collide:

1. The intercept of a linear predictor is `intercept`.
2. A parameter tied to a predictor is `<predictor>_<role>`, `<predictor>` being the Stan data field it acts on without its unit suffix: `<predictor>_slope` for a coefficient (`fronds_slope`, `tide_height_slope`, `cover_slope`), `<predictor>_power` for an exponent (`diameter_power`).
3. Group-level terms are `sd_<group>`, `<group>_effect`, and `z_<group>` (non-centred deviates) for `site`, `year`, and `site_year`.
4. Distribution parameters take their standard names: `shape`, `dispersion` (negative binomial, variance `mu + dispersion * mu^2`), `precision` (Beta), `sd_residual`.
5. A floor is `<quantity>_floor` (`weight_floor`, `biomass_floor`).
6. Link-scale terms of a linear predictor take no scale prefix; a standalone scalar stored on a transformed scale takes `log_` or `logit_` (`logit_zero_inflation`).
7. No parameter shares a name with a data field, an input column, a Stan reserved word (`lower`, `upper`, `offset`, `multiplier`, `target`), or a Stan function (`floor`, `gamma`, `beta`, `log`, `exp`).
8. A parameter's prior entry in `kb_priors_*()` has the parameter's name.

Stan data names: a field passing an input column through takes the column's name (`diameter_mm`, `area_m2`, `canopy_tide_height_m`); a derived field is named for its quantity (`log_biomass`, `dry_wet_ratio`); sizes are `n_obs`, `n_site`, `n_year`; flags keep `<effect>_on`.

## Alternatives considered

- Keep the `b`/`s` names and rename the prior entries to match
  (`priors$bWeight`): one vocabulary with a smaller change, but the opaque names
  move into the user-facing prior list.
- brms-style `b_<name>`, `r_<group>`, `sd_<group>`: systematic and familiar to
  brms users, but the prefixes carry no meaning for kelpbio's audience.
- Keep both vocabularies and store a parameter-to-prior pairing on each fit:
  no rename, but the translation stays with every user and caller.
- Rename only where a name collides: fewer changes, but names stop being
  predictable from the rules.

## Consequences

- The names differ from the analysis project's reports and Stan code. The table
  below maps them for reviewers comparing the two.
- kelpbio departs from the Poisson house convention; its own rules are in
  CLAUDE.md.
- `kb_prior_lognormal()` exists so that the cover slope's prior is stated on the
  slope itself, as its entry name implies.

## Mapping from the previous (analysis-style) names

| Model | Previous | Current |
|---|---|---|
| Weight, *Nereocystis* | `bWeight` | `intercept` |
| | `bPower` | `diameter_power` |
| | `bFloor` | `weight_floor` |
| | `sWeight` | `sd_residual` |
| Weight, *Macrocystis* | `bWeight` | `intercept` |
| | `bFronds` | `fronds_slope` |
| | `bShape` | `shape` |
| Size, *Nereocystis* | `bDiameter` | `intercept` |
| | `bShape` | `shape` |
| Wet/dry | `bDryWet` | `intercept` |
| | `bPrecision` | `precision` |
| Carbon | `bCarbon` | `intercept` |
| | `bPrecision` | `precision` |
| Cover calibration | `bCanopy` | `cover_slope` |
| | `bFloor` | `biomass_floor` |
| | `bTide` | `tide_height_slope` |
| | `sBase` | `sd_residual` |
| | `sCV` | `cv_residual` |
| All with group effects | `sSite`, `sYear`, `sSiteYear` | `sd_site`, `sd_year`, `sd_site_year` |
| | `bSite`, `bYear`, `bSiteYear` | `site_effect`, `year_effect`, `site_year_effect` |
| | `z_bSite`, `z_bYear`, `z_bSiteYear` | `z_site`, `z_year`, `z_site_year` |
