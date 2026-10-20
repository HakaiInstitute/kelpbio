## Context

Timmer et al. (2024) regressed detected canopy extent on tide height for eight British Columbia beds flown at 0 to about 4 m (Canadian chart datum): extent falls linearly, by 25.7 ± 6.6% per metre on average (22.5% at low current, 35.5% at high current), with R² of 0.90 to 0.97. Inverting that line gives the current correction, `canopy / (1 - s * tide)`, and the default prior on `s` (`tide_height_slope`, normal 0.276 ± 0.04 for *Nereocystis*, 0.227 ± 0.03 for *Macrocystis*) comes from the same beds. The line reaches zero visible canopy at `1 / s`, inside the tidal range, so the inverse has no finite value there and is negative above it. The analysis project's flights all lie at or below 2.0 m, so it never met this; a general package will.

The literature handles high tides by restricting imagery to tides below about 2 m (Schroeder et al. 2019; Hamilton et al. 2020; Hakai's own flights) rather than correcting across the range. No study tests the shape of the relationship above the flown tides.

## Goals / Non-Goals

**Goals:**
- Finite, non-negative calibration and totals at any finite tide height, with no jump in the correction as the tide crosses `1 / s`.
- Keep the published functional form wherever it is defined.
- Tell the user when a row lies beyond the tides the prior was estimated at.

**Non-Goals:** see the proposal.

## Decisions

### Past `1 / s`, use the cap

The corrected canopy grows without limit as `1 - s * tide` falls to zero, so its limit is whatever caps it: the plot area in the fit (cover of 1) and the classified area in canopy totals. Past `1 / s` the correction takes that cap, for positive canopy; a row with no canopy has no bed to correct and stays at zero, as `0 / (1 - s * tide)` is for any positive denominator. The value is continuous in `s` and `tide`, since the cap is reached before the denominator reaches zero, so the posterior geometry has no kink beyond the one `min()` already has.

Alternatives:
- Zero past `1 / s`: biomass would drop from the cap to nothing for the draws that imply the most biomass. At 3.5 m about 40% of the *Nereocystis* prior lies above `1 / 3.5`, so totals would be bimodal and biased low, and the fit would see a discontinuity.
- `NA` past `1 / s`: honest, but leaves holes in totals and summaries, and cannot be used inside the fit.
- A log-linear correction `exp(k * tide)`: finite everywhere, but departs from the published form within the flown range (matching it at 2 m, it understates the correction by about 20% at 3 m for low-current beds). Its apparent precision at high tides comes from the assumed shape, not data.
- A floor on the visible fraction, `1 / max(1 - s * tide, v_min)`: keeps the published form but the result above `1 / s` is set by an arbitrary `v_min`.

### Require `classified_area_m2`

Without a cap the corrected canopy of a canopy row has no finite limit, and can exceed the area that contains it. The classified area (the water the classifier covered, including water with no canopy) is the right cap: `canopy_area_m2` is canopy found within it, so the corrected canopy is bounded by the same area, as cover in the calibration is canopy over plot area. The site boundary was the previous optional cap; it can extend beyond the imaged area, where no canopy was observed. The column is renamed so its name does not invite the site-boundary reading.

### Warn only where the cap sets the result

Up to about 2.5 m (*Nereocystis*) or 3 m (*Macrocystis*) the correction's uncertainty grows smoothly and the intervals show it (at 2 m the 95% interval of the *Nereocystis* factor is 1.65 to 3.45), so a warning there would repeat what the intervals say, and would fire on ordinary data such as the analysis's 2.0 m *Macrocystis* flights. What the intervals do not show is a result set by the cap: past `1 / s` the corrected canopy is the plot or classified area whatever was measured. A row warns when that holds on more than 5% of the slope's draws, the share beyond each 95% limit, so the cap reaches into its interval; with the default prior this starts near 3 m (*Nereocystis*) and 3.5 m (*Macrocystis*). The fit uses the prior's probability of the same event, since a survey past the limit enters as fully covered and biases the calibration.

Alternative: a blanket warning above 2 m, the upper tide of the imagery the literature accepts (Schroeder et al. 2019; Hamilton et al. 2020). Rejected as noise in the package and in kelpbioshiny; the 2 m guidance, and the narrower prior than the spread across Timmer et al.'s beds (a high-current bed at 2 m can need a factor up to 4.4 against the prior's 3.45), go in the docs instead. The existing plausibility check (median outside -1 to 5 m) stays, since it catches tide heights entered in the wrong unit.

### The upper bound on the tide slope stays

`tide_height_slope` keeps its `[0, 0.5]` support as part of the prior. It no longer has to keep the correction finite; the cap does.

## Risks / Trade-offs

- [At tides near `1 / s` the total is driven by the cap and the tide prior, not the canopy] → the tide-limit warning, and the docs advise flying at low tide.
- [The prior is narrower than the spread across beds, so a high-current bed is under-corrected] → the docs advise a higher prior mean for such beds; no warning can detect it.
- [Users who cannot give a classified area] → it is a property of the imagery they already classified; the docs say how to obtain it (the extent the classifier covered, less land).
- [The analysis project keeps the uncapped form] → none of its flights exceed 2.0 m, where both forms agree; noted for its next refit.
