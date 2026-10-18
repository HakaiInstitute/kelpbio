# Planned intermediate predictions

Notes, 2026-10-16. Not a change proposal: a record of findings to pick up later,
when the work becomes an openspec change. Wording here is notes, not reader-facing
text.

## Why

An evaluation in the analysis project
(`hakai-kelp-biomass-25/decisions/cover-count-calibration.md`) compared three drone
calibrations:

- **A, current**: in situ biomass from the density, size and weight fits
  (`kb_predict_plot_biomass()`), summarised to an estimate and range per site-year,
  regressed on plot cover (`kb_fit_cover_biomass_*()`).
- **B, count calibration**: transect counts modelled on plot cover, with mean plant
  weight applied at the total.
- **C, plot biomass from counts**: each plot's counted stipes per m² × that
  site-year's mean weight per plant, regressed on cover on the natural scale. This
  is the published standard (SBC LTER: Cavanaugh et al. 2011, Bell et al. 2020;
  Stekoll et al. 2006 for *Nereocystis*). Not yet fitted.

B predicted held-out years better than A for both species. The move is likely to
C, or to B if C does not match it. Both need quantities kelpbio computes
internally but does not expose. Other teams need the same building blocks: SBC
LTER measures every frond in its strips and calibrates against Landsat kelp
fraction; a drone census of *Nereocystis* bulbs would supply plant counts and
sizes directly.

## Quick wins

1. **Mean weight per plant for a site-year**, from a weight fit and a size fit,
   with `new_levels`, `representative_site` and `n_plants` as in
   `kb_predict_plot_biomass()`, which computes it internally and multiplies it by
   density. Lets mean weight be combined with density from anywhere (diver counts,
   a drone count, another survey). Candidate: `kb_predict_mean_weight(weight, size)`.
2. **Biomass of a set of measured plants**, summed draw by draw. `kb_predict_weight()`
   returns each plant's expected weight with its own interval, and those intervals
   cannot be added. Add `sum_by` (as in `kb_predict_site_biomass()`) and an optional
   area column for per-m² results. Serves a strip census (SBC), quadrat sums
   (Stekoll), and a drone bulb census. Open: extend `kb_predict_weight()` or add a
   function; and whether to include plant-level scatter (a realised total) or only
   expected weights. With many plants the difference is small.
3. **Plot biomass from counts**, the response for approach C: transect counts ×
   mean weight per plant (1) or × the plot's measured plants (2), per plot and
   date, without the density model. Plots with no plants counted are zero. Could
   be an option of `kb_predict_plot_biomass()` or a composition of (1) with the
   observed density.
4. **Calibration response choice** in the cover fit. The current fit takes a
   summary (`estimate`, `lower`, `upper`) and fits log biomass, so a zero cannot
   enter. Approach C needs a natural-scale likelihood that takes zeros, with the
   floor and site and year effects on the slope kept. Passing draws rather than
   summaries would carry the shared weight-curve uncertainty into the calibration,
   which a per-plot range treats as independent.
5. **Site-total options** in `kb_predict_site_biomass()`:
   - Floor support: apply the floor over canopy area (now) or over a footprint or
     pixel area (SBC applies its intercept per kelp pixel).
   - Tide correction form. The tide slopes in use are percentages of the extent at
     zero tide (Timmer et al. 2024), so recovering that extent divides by
     (1 − slope × tide); the current correction multiplies by (1 + slope × tide),
     about 4% low at 0.7 m and 17% low at 1.5 m. Offer no correction for sites
     with weak tides.

## Design question for all of these

`kb_predictions` objects carry only summaries. Chaining an intermediate quantity
with its uncertainty needs either the downstream function to take fits (the
current pattern, `kb_predict_plot_biomass(weight, size, density)`), or predictions
to carry draws, for example as a `posterior::rvar` column. Draw-carrying
predictions would let another team combine their own density or calibration with
kelpbio's mean weight and keep propagated intervals. See
`decisions/prediction-engine.md`.

## Later, larger

- Other size predictors in the weight fit: frond length (SBC), bulb diameter (a
  drone-measurable size; R² about 0.43 against 0.80 for sub-bulb diameter on 1,194
  Hakai plants, OLS check).
- Canopy biomass as an output (SBC reports canopy biomass; it tracks imagery
  better than total biomass, r² 0.64 against 0.49). Needs the parked blade-fraction
  model.
- Totals from a user-supplied calibration with uncertainty (for example SBC's
  6.53 ± 0.31 and 0.30 ± 0.09).
- A period below the year (season or month) and survey dates, for monthly data and
  a flight-to-dive window. A large change; SBC data are monthly.
- A drone bulb-census pathway: a detection model (drone against diver counts on the
  same plot) and bulb-diameter allometry.
- Survey-design helpers (how many plots, where), by simulation.

## Dive and flight dates

Decided 2026-10-16: kelpbio will not enforce a flight-to-dive window. It will warn
when a paired dive and flight are further apart than a set period, which needs a
survey date in the density and cover data.

## kelpbioshiny

On hold until the calibration approach and kelpbio are settled (2026-10-16).
From a review of the app on 2026-10-16; file references are to kelpbioshiny at
that date.

**How the calibration is wired now.** The cover fit takes the wet output of
`kb_predict_plot_biomass()` (`R/state.R:780-783`) and matches it to drone plots by
site-year only (mock, `R/mock-kelpbio.R:618-639`). The cover sheet holds plot and
site canopy areas, plot boundary area and tide height, but no counts and no plot
identifier (`R/data.R:56-60`). The example workbook has three plots per surveyed
site-year (`R/mock-example.R`).

**What approach C would change:**

1. **Data.** A plot identifier in the density and cover sheets, so each drone
   plot's own transect counts can be found; site-year matching cannot attribute
   counts when a site-year has more than one plot. A survey date in both sheets if a
   flight-to-dive window is wanted.
2. **Dependencies.** The cover fit would need the density data (counts) and the
   size and weight fits, not the density fit or plot biomass. The fit-queue rules
   that assume it consumes plot biomass change: `cover_blocked`, `fit_all_plan`,
   `invalidate_cover`, and the `start_next` guard (`R/state.R:34-83, 163-204,
   772-796`). The density model would then serve only the Plot biomass page.
3. **Cover model Data tab.** Show counted plot biomass against cover, with zero
   plots visible, rather than the plot surveys alone (`R/mod_model.R:205-211`).
4. **Settings.** Generic: the prior cards follow `kb_priors_cover_biomass_*()`, so
   they change with it (`error_scaling` would go).
5. **Estimates.** Room for the quick wins: a mean plant weight page by site-year,
   counted plot biomass, and plant-set totals from the weight page's "Individual
   plant" grouping.
6. **Text** that describes regressing modelled plot biomass on cover: the cover
   model detail (`R/data.R:57`), the cover Data tab description
   (`R/mod_model.R:205-211`), the blocked notices (`R/mod_model.R:171-176`,
   `R/state.R:778`), the `total_biomass` help topic (`R/help.R:177-185`, snapshot
   `tests/testthat/_snaps/mod_help.md`), the sheets description
   (`R/mod_data.R:367-370`), the export script (`R/mod_export.R:112-121`), the
   article summaries (`R/help.R:12-15, 37-41`), and the Total page notices
   (`R/mod_estimates.R:314`).
7. **Mocks.** New functions for mean weight, counted plot biomass and the new cover
   fit; the tide formula in the mock prediction (`R/mock-kelpbio.R:895`) if the
   correction form changes.

**Found in passing, not checked yet:**

- The app adds `stipes_m2` to the weight data whenever a density sheet exists
  (`R/state.R:286-288`). The kelpbio weight model no longer reads that column, so
  the app can stop adding it.
- *Macrocystis* labels still say sub-bulb diameter and 50 mm (`R/data.R:509-515`);
  the app's *Macrocystis* reference is 10 fronds, the mock's 12.5.
- Stale comments: `R/app-ui.R:1`, `decisions/webapp-decision.md:66-86`,
  `R/kelpbioshiny-package.R:4-8`.
