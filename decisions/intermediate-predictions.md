# Planned intermediate predictions

Notes, 2026-10-16, updated 2026-10-18. Not a change proposal: a record of findings to pick up later,
when the work becomes an openspec change. Wording here is notes, not reader-facing
text.

## Done in the cover-calibration change

Approach C of the analysis project's `decisions/cover-count-calibration.md` is
in: `kb_predict_mean_weight()` (quick win 1), `kb_predict_biomass_in_situ()`
(quick wins 2 and 3: the biomass of counted plants, tallied or censused, with
`pool_by` and `per_area`), the cover calibration on survey biomass with zeros
(quick win 4), and the dividing tide correction in the totals (quick win 5).
Derived verbs carry their draws as an `rvar` column, which settles the design
question of how intermediate quantities chain.

## Still open

- Mean weight of counted plants (a census), for example as a third scale of
  `kb_predict_biomass_in_situ()`; `kb_predict_mean_weight()` takes fits only.
- Floor support in totals: over canopy area (now), or a footprint or pixel area.
- No tide correction for sites with weak tides.
- The weight error shared through the level of the allometry is treated as
  independent among surveys; the draws column leaves room to propagate it.
- A site:year effect in the cover calibration once several plots per
  site-year are common.

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

The user pairs each dive with a flight on the survey row, so kelpbio cannot
check the gap between them. Input tables carry `year` only and surveys are keyed
by `survey_id` (change `survey-data-columns`). A seasonal analysis would need a
period below the year (see Later, larger).

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

**What the cover-calibration change means for the app** (kelpbio API after it):

1. **Data.** One survey sheet (survey_id, site, year, survey_area_m2, plants for
   *Nereocystis*, and the drone columns plot_area_m2, canopy_area_m2,
   tide_height_m on the same row), a counted-plant sheet for *Macrocystis*
   (survey_id, fronds, partial; sheet `size_census`), and a canopy sheet for totals. The
   density sheet and the separate cover sheet go.
2. **Dependencies.** The cover fit needs survey biomass from
   `kb_predict_biomass_in_situ()`, so the weight fit (and the *Nereocystis* size
   fit) must come first. The density fit and the *Macrocystis* size fit go. The
   fit-queue rules (`cover_blocked`, `fit_all_plan`, `invalidate_cover`,
   `start_next`; `R/state.R:34-83, 163-204, 772-796`) change accordingly.
3. **Cover model Data tab.** Survey biomass against cover, with empty surveys
   visible (`R/mod_model.R:205-211`).
4. **Settings.** The prior cards follow `kb_priors_cover_calibration_*()`:
   `error_scaling` goes, `sd_residual` and `cv_residual` arrive.
5. **Estimates.** Mean weight by site-year (*Nereocystis*), survey biomass
   (with `per_area`), and totals over canopy (`kb_predict_biomass_canopy()`,
   kg only).
6. **Renames.** `kb_fit_cover_biomass_*()` to `kb_fit_cover_calibration_*()`,
   `kb_predict_site_biomass()` to `kb_predict_biomass_canopy()`,
   `kb_predict_plot_biomass()` to `kb_predict_biomass_in_situ()`, `stipes` to
   `plants`; help text, mocks, and snapshots follow.

**Found in passing, not checked yet:**

- The app adds `stipes_m2` to the weight data whenever a density sheet exists
  (`R/state.R:286-288`). The kelpbio weight model no longer reads that column, so
  the app can stop adding it.
- *Macrocystis* labels still say sub-bulb diameter and 50 mm (`R/data.R:509-515`);
  the app's *Macrocystis* reference is 10 fronds, the mock's 12.5.
- Stale comments: `R/app-ui.R:1`, `decisions/webapp-decision.md:66-86`,
  `R/kelpbioshiny-package.R:4-8`.
