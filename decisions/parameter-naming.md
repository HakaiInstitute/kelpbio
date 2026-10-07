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
name. The rules are in CLAUDE.md ("Parameter names", "Stan data names").

The rules apply even where no name would collide (`diameter_power`, not
`power`), so a new sub-model's names follow from the rules and the names stay
predictable. Two of them avoid collisions that the plain role names would
cause: a slope carries its predictor's name (`density_slope`), because
`density`, `fronds`, `canopy_area_m2`, and `tide_height_m` are already Stan
data fields or input columns, and a floor carries its quantity (`weight_floor`, `biomass_floor`),
because `floor` is a Stan function.

`dispersion` keeps kelpbio's direction (variance `mu + dispersion * mu^2`, zero
for the Poisson), which matches Stan's naming of phi as the precision and the
`theta` of the extras package; MASS and glmmTMB name the inverse quantity.

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
| | `bDensity` | `density_slope` |
| | `sWeight` | `sd_residual` |
| Weight, *Macrocystis* | `bWeight` | `intercept` |
| | `bFronds` | `fronds_slope` |
| | `bShape` | `shape` |
| Size, *Nereocystis* | `bDiameter` | `intercept` |
| | `bShape` | `shape` |
| Size, *Macrocystis* | `bFronds` | `intercept` |
| | `bDispersion` | `dispersion` |
| Density, *Nereocystis* | `bStipes` | `intercept` |
| | `bZeroInflation` | `logit_zero_inflation` |
| | `bDispersion` | `dispersion` |
| Density, *Macrocystis* | `bPlants` | `intercept` |
| | `bDispersion` | `dispersion` |
| Wet/dry | `bDryWet` | `intercept` |
| | `bPrecision` | `precision` |
| Carbon | `bCarbon` | `intercept` |
| | `bPrecision` | `precision` |
| Cover biomass | `bCanopy` | `cover_slope` |
| | `bFloor` | `biomass_floor` |
| | `bTide` | `tide_height_slope` |
| | `bScaling` | `error_scaling` |
| All with group effects | `sSite`, `sYear`, `sSiteYear` | `sd_site`, `sd_year`, `sd_site_year` |
| | `bSite`, `bYear`, `bSiteYear` | `site_effect`, `year_effect`, `site_year_effect` |
| | `z_bSite`, `z_bYear`, `z_bSiteYear` | `z_site`, `z_year`, `z_site_year` |
