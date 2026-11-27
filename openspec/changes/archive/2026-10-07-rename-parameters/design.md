## Context

Parameters follow the Poisson `b`/`s` convention; prior entries, chosen later for
users, use readable names; Stan data fields abbreviate the input columns. Three
vocabularies describe one model. kelpbio's users are mostly not statisticians, a
Shiny app sits on top of the priors, and prior sensitivity (next change) reports
parameters that users must map to the prior to edit.

## Goals / Non-Goals

**Goals:** one name per parameter across summaries, descriptions, Stan code, and
the prior list; data fields a reviewer recognises from their own data; names
chosen by rules, so a future sub-model's names are determined rather than
debated.

**Non-Goals:** see the proposal.

## Decisions

### Naming rules

Parameters (and therefore prior entries):

1. The intercept of a linear predictor is `intercept`.
2. A parameter tied to a predictor is `<predictor>_<role>`, where `<predictor>`
   is the Stan data field it acts on without its unit suffix: a coefficient
   multiplying the predictor (or its log or standardised form) is
   `<predictor>_slope`; an exponent on it is `<predictor>_power`.
3. Group-level terms are `sd_<group>` (standard deviation), `<group>_effect`
   (the effects), and `z_<group>` (the non-centred standard-normal deviates), for
   the groups `site`, `year`, and `site_year`.
4. Distribution parameters take their standard names: `shape`, `dispersion`,
   `precision`, `sd_residual`.
5. A floor is named after the quantity it bounds: `<quantity>_floor`.
6. Parameters inside a linear predictor (intercept, slopes, effects, SDs) are on
   the link scale and take no scale prefix; a standalone scalar stored on a
   transformed scale takes `log_` or `logit_`.
7. No parameter shares a name with a data field, an input column, a Stan
   reserved word (`lower`, `upper`, `offset`, `multiplier`, `target`), or a Stan
   function (`floor`, `gamma`, `beta`, `log`, `exp`). Rules 1 to 6 already ensure
   this; rule 7 is the check for a new name.
8. A parameter's prior entry has the parameter's name.

Stan data fields:

1. A field that passes an input column through takes the column's name,
   including its unit suffix.
2. A field derived from the inputs is named for the quantity
   (`log_biomass`, `carbon_fraction`, `dry_wet_ratio`, standardised `density`).
3. Sizes are `n_<thing>` (`n_obs`, `n_site`, `n_year`); index arrays are named
   after the group (`site`, `year`); structural flags keep `<effect>_on`.
4. Prior hyperparameters are `prior_<entry>_<argument>`, the argument named as
   in the prior constructor (`mean`, `sd`, `rate`, `meanlog`, `sdlog`).

All identifiers are snake_case.

### Parameter mapping

| Model | Previous | New |
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

The previous names are those of the analysis project's models in most cases;
`decisions/parameter-naming.md` keeps this table for reviewers comparing kelpbio
output with the analysis reports.

### Data field mapping

| Model | Previous | New |
|---|---|---|
| All | `nObs`, `nSite`, `nYear` | `n_obs`, `n_site`, `n_year` |
| Weight, *Nereocystis* | `diameter`, `weight` | `diameter_mm`, `weight_kg` |
| Weight, *Macrocystis* | `weight` | `weight_kg` (`fronds` unchanged) |
| Size, *Nereocystis* | `diameter` | `diameter_mm` |
| Density | `area` | `area_m2` (`stipes`, `plants` unchanged) |
| Wet/dry | `ratio` | `dry_wet_ratio` |
| Cover biomass | `canopy`, `plot`, `tide` | `canopy_area_m2`, `plot_area_m2`, `tide_height_m` |
| All | `prior_<entry>_mu` | `prior_<entry>_mean` (entries renamed as above) |
| Cover biomass | `prior_canopy_mu`, `prior_canopy_sd` | `prior_cover_slope_meanlog`, `prior_cover_slope_sdlog` |

Transformed data and model-block locals follow the same rules where they are
camelCase (`nZero` to `n_zero`); other internal names stay.

### `kb_prior_lognormal()` for the cover slope

The cover slope's prior is a Normal on its log, which the Stan program already
states as `lognormal` on the slope. With entries named after parameters, the
entry `cover_slope` must describe a prior on `cover_slope` itself, so the default
becomes `kb_prior_lognormal(meanlog = 2, sdlog = 1)` (nereo; macro keeps its own
values). The density, the fit, and every number are unchanged. The constructor
follows `kb_prior_normal()`: validated hyperparameters, a print method, and a
describe form `LogNormal(meanlog, sdlog)`.

### Alternatives considered

- Keep the `b`/`s` names and rename the prior entries to match (`priors$bWeight`):
  one vocabulary, smaller diff, but the opaque names move into the user-facing
  prior list and `intercept` stays ambiguous across models.
- brms-style `b_<name>` / `r_<group>` / `sd_<group>`: familiar to brms users and
  systematic, but the prefixes carry no meaning for kelpbio's audience; the
  readable forms are equally systematic when applied by rule.
- Keep both vocabularies and store a parameter-to-prior pairing on each fit (the
  first version of `add-prior-sensitivity`): no rename, but users and the app
  still translate between names, and the pairing has to be maintained per model.
- Rename only where a name collides with a data field (`density_slope` but
  `power`): fewer changes, but the names stop being predictable from the rules.

## Risks / Trade-offs

- [Client reviewers know the analysis names] → the mapping table in
  `decisions/parameter-naming.md`, linked from the vignette in the final docs
  pass.
- [`kb_stancode()` no longer matches the analysis Stan code line for line] →
  accepted; the models are unchanged and the mapping covers the names.
- [Departure from the Poisson house convention (bboutools, embr)] → kelpbio's
  CLAUDE.md states its own rules; the convention's purpose (finding monitored
  parameters by prefix) does not apply, since kelpbio lists terms explicitly.
- [A mechanical rename across about 80 files can miss a reference] → the test
  suite reads draws by name throughout, so a missed name fails loudly; a final
  grep for `\b[bs][A-Z]` and `z_b` in `R/`, `inst/stan/`, `tests/`, and docs.
