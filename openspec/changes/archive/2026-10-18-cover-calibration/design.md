## Context

The analysis project (`hakai-kelp-biomass-25`) adopted approach C of
`decisions/cover-count-calibration.md`: drone cover is calibrated on each dive's
biomass, the plants counted per m² times their wet weight, with the weight
uncertainty carried as known error. *Nereocystis* weight per plant integrates the
allometry over the site-year's size distribution; *Macrocystis* weighs every
counted plant from its own fronds at 1 m, so its size model went, and the
density models went for both species. The calibration is linear on the natural
scale with a censored Normal likelihood, and site totals are unchanged in
structure, with the tide correction now dividing canopy by (1 - slope × tide).

kelpbio still fits density models, composes plot biomass from three fits, and
regresses cover on log plot biomass summaries. This change follows the analysis
and redesigns the prediction surface around it. Nothing has been released, so
there are no deprecations.

## Goals / Non-Goals

**Goals:**

- Match the analysis production calibration for both species.
- One interface for in situ data whatever the species: a survey table, plus a
  plant table when every plant was measured.
- Remove the models and the internal machinery that only they used.
- Name verbs so a reader can tell a fitted model's prediction from a quantity
  derived from several fits and the user's data.

**Non-Goals:** see the proposal.

## Decisions

### Scope: peak season, site-year

Every model has site and year effects only, and estimates describe the peak
season of a year. A site-year may hold several plots, and a plot several
surveys; each survey is one row and, where it has drone cover, one calibration
observation sharing its site and year effects. Alternatives: a survey key with
seasonal results (rejected: no model resolves below the year, so a per-dive
estimate differs only in counts and area), and pooling surveys to the site-year
(rejected: a plot's cover must be paired with that plot's biomass).

### Two kinds of verb, named apart

Model verbs keep the model's name (`kb_predict_weight()`,
`kb_predict_cover_calibration()`). Derived verbs are named for what the biomass
estimate covers: `kb_predict_biomass_survey()` (the area searched) and
`kb_predict_biomass_canopy()` (the mapped canopy), plus
`kb_predict_mean_weight()`. A single `kb_predict()` generic stays rejected
(`decisions/prediction-engine.md`: the call should name the model in play).
"Survey" names the in situ survey only; the drone side is "flight" or "drone
cover" in docs and messages. `kb_predict_biomass_plot()` was considered: the
verb estimates the area searched, and treating that as the plot's biomass per m²
is the calibration's assumption, so the calibration states it instead.

### The cover model is the cover calibration

The literature calls the fitted model the cover (kelp fraction) and biomass
relationship and fitting it calibration (Bell et al. 2020; Cavanaugh et al.
2010, 2011; Stekoll et al. 2006). `cover_biomass` would sit one word-order away
from `biomass_canopy`; bare `calibration` is too general.

### Survey and plant tables

The difference that matters is the size data, not the species: plants tallied
with a measured subsample (sizes modelled; Hakai *Nereocystis*) or every counted
plant measured (a census; Hakai *Macrocystis*, or a *Nereocystis* drone bulb
census).

- `survey`: one row per survey of a plot, keyed by `site`, `plot_id`, and `date`
  (a `Date`; `year` is derived from it). `survey_area_m2` is the area searched,
  the denominator of biomass per m². `plants` (the tally) is present only when
  sizes come from a size fit. The drone pairing (`plot_area_m2`,
  `canopy_area_m2`, `tide_height_m`) sits on the row, all present or all `NA`.
- `plants`: one row per counted plant, with the survey key, its size, and a
  logical `partial` (Hakai's edge plants, counted as half).

Alternatives considered: a tally alongside census plants (states every count
twice and needs an agreement check); one plant table with `NA` placeholder rows
for empty surveys (a missing measurement would read as no plants); separate
in situ and drone tables joined by kelpbio (the user pairs each dive with a flight
anyway); a cover fraction column in place of the two areas (one area could not
serve both denominators); a weighting column `count` (read as a tally).

A survey with no plant rows is zero biomass, with a message listing those
surveys, so a forgotten set of plant rows shows rather than passing as a zero.

### `size` takes a fit or a table

`kb_predict_biomass_survey(weight, size, survey)`: the estimand is the same
either way, and only the source of sizes differs. An alternative,
`(weight, survey, plants, size = NULL)` with plants always present, would make
*Nereocystis* tallies expand to one row per plant.

### The calibration takes one data frame

`kb_fit_cover_calibration_*(data, priors, ...)` takes the unsummed
`kb_predict_biomass_survey()` output, which carries each survey's drone columns
and its biomass draws. This drops `join_cover_biomass()`, the unmatched-survey
message, and the second data argument, so the CLAUDE.md argument-order exception
for the cover fits goes. Rows without drone cover are left out with a message.

### Draws travel in the output

Each derived verb returns its response as a `posterior::rvar` column next to
`estimate`, `lower`, and `upper`. The calibration reads the mean and SD of each
survey's biomass from it, as the analysis does from its draws. Alternatives:
plain mean and SD columns (two summaries of one quantity), or the calibration
taking the fits (a longer, species-specific fit signature). Draws also leave room
to carry the shared allometry error later, which the analysis does not yet
propagate.

### `per_area`, `measure`, `sum_by`

`per_area` defaults to the verb's common case (`TRUE` for surveys, `FALSE` for
canopy), and the response column name states the scale. A `per =` argument was
rejected as less intuitive. `measure` needs the fits it names and is never
inferred from the fits supplied. `sum_by` has one definition on the two biomass
verbs: per draw, kg summed and, per area, divided by the summed area; a sampled
new site or year effect is shared by every row of that level. It is not offered
where results do not add (model verbs, mean weight).

### Mean weight from fits only

One estimand, the expected weight of a plant from a site-year's modelled size
distribution. Accepting a plant table too would switch the estimand and the
valid arguments on the type of `size`.

`kb_predict_mean_weight()` and the tallied path of `kb_predict_biomass_survey()`
share one internal that returns the mean plant weight draws for a set of
site-years, so the two cannot disagree: at a site-year, survey biomass per plant
equals mean weight draw for draw.

### "Plant" for both species

In *Macrocystis* the stipes are the fronds (McPherson and Kudela 2022), whereas
the Hakai protocol and Stekoll et al. (2006) count *Nereocystis* plants. Reader
docs define "plant" once, after Reed et al. (2009), as one individual
(sporophyte) identified by its holdfast.

### Calibration likelihood and parameters

As the analysis: `biomass ~ Normal(mu, sqrt(sd_residual^2 + (cv_residual * mu)^2 +
biomass_sd^2))`, censored below at 0, with `mu = biomass_floor + cover_slope *
exp(site + year) * cover` and `cover = min(plot, canopy / (1 - tide_height_slope
* tide)) / plot`, `tide_height_slope` bounded at 0.5. `sd_residual` follows
parameter-naming rule 4; `cv_residual` is its proportional partner. The censored
Normal gets its own family file (log density, deviance residual, replicates
censored at 0), as Weibull has. Predictions report `mu`, the quantity totals use,
rather than the mean of the censored distribution.

### What is removed with the models

- Rate-model offset: `meta$offset`, `grid_offset()`, the offset arguments of the
  prediction internals, the per-area division in `pp_check()`, the rate response
  override in the summaries.
- Count families: `gamma_pois`, `gamma_pois_zi`, `gamma_pois_zt` and
  `R/gamma_pois_zt.R`; the density and size macro `.epred()`, `.linpred()`,
  `.obs_family()`, and `.model_spec()` methods.
- Density data and grids: the density new-data checks and grid columns, plot
  labels, and doc lines.
- Plot biomass: `plot_biomass_grid()`; `.plant_sizes()` becomes a plain function
  with one size model left.
- Log-summary calibration: `cover_log_sd()`, `cover_conf_level()`, the
  `kb_conf_level` attribute (only the cover fit read it), `.chk_biomass_limits()`,
  `.chk_plot_biomass()`, `error_scaling`, the cover lognormal family.

## Risks / Trade-offs

- [Breaking renames across the whole biomass surface] → nothing is released;
  kelpbioshiny follows in its own change.
- [`survey_area_m2` and `plot_area_m2` can be confused] → defined side by side in
  the survey check and the survey verb; a row with the searched area above the
  plot area warns.
- [Off-season surveys pooled into peak-season estimates] → the scope is stated
  in the docs; kelpbio cannot see the season.
- [Weight error shared through the allometry is treated as independent among
  surveys] → as in the analysis; the draws column leaves a route to propagate it.
- [Plants above the weighed size range extrapolate the allometry] → as now;
  documented.

## Migration Plan

Pure code first, then the Stan model (install-gated), then simulated data and
every pre-fit and fixture (MCMC, confirmed before running). No rollback beyond
git.

## Open Questions

- kelpbioshiny follow-up: fit queue, mocks, sheets, and help text.
- A site:year effect in the calibration once replicated plots exist (the
  aliasing check from the always-fit-site-year change applies).
