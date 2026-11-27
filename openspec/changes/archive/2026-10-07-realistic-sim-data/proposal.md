## Why

The bundled simulated datasets are each simulated on their own, with independent
site and year effects and parameter values tuned for fast fits rather than
realism. Composing their pre-fits gives implausible numbers: *Macrocystis* plot
biomass from the bundled weight, size, and density fits is about 0.04 to 0.2 kg/m²,
against a median of 2.7 kg/m² in the Hakai Institute surveys, because the simulated
plant weight is about a ninth of the analysis estimate. The cover data's in situ
plot biomass is simulated separately again, so it bears no relation to what
`kb_predict_plot_biomass()` gives from the bundled fits. Every source covers every
site-year, so the examples never show what happens when a site-year has density
but no harvest, which is the usual case in the field.

The fitted random effects are also labelled by position (`bSite[3]`), not by the
site they belong to, and with sites named `site1` to `site10` the label looks like
part of the parameter name. Finally, a fit's draws print as empty
(`<rvar[0]>`) when reached before any kelpbio function has loaded `posterior`.

## What Changes

- For each species, the weight, size, density, and cover datasets are simulated
  from one set of true site-year values near the analysis production fits, with
  moderate random-effect SDs. The in situ plot biomass paired with the cover data
  is the true plot biomass those values imply, with estimation error. Composed
  estimates from the bundled fits are therefore realistic in magnitude and agree
  with the in situ estimates they stand in for.
- Data sources cover different site-years: density at most, size at most of
  those, weight at a subset that includes sites never harvested, and drone surveys
  at a subset.
- Simulated sites take invented, plausible names (`otter_cove`), not real survey
  sites and not `site1`.
- A fit's per-level effects are labelled by their levels, so `tidy()` reports
  `bSite[otter_cove]` and `bSiteYear[otter_cove,2020]`, and the draws index by
  name (`fit$draws$bSite[["otter_cove"]]`) as well as by position.
- The data checks warn when a site or year name contains `,`, `[`, or `]`, which
  make flattened parameter names ambiguous to tools that parse them.
- `posterior` loads with kelpbio, so a fit's draws work as soon as the package is
  attached.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `fitting`: "Bundled example objects" describes the shared truth, realistic
  magnitudes, and gaps in availability; "The fit object" states that draws are
  labelled by level and usable on load; a new requirement flags ambiguous group
  names.
- `summaries`: "Parameter summaries" names per-level effects by level.

## Non-goals

- Changes to any Stan model, prior, or likelihood.
- Changes to the wet/dry and carbon datasets and pre-fits, which have no sites or
  random effects and are already near the Hakai Institute lab samples.
- A month dimension or seasonal pattern in the simulations; kelpbio works at
  site-year resolution.
- Exported simulation functions (`kb_simulate_*()`) or a census-based validation
  of coverage; the shared truth is a step towards it.
- Renaming or sanitising user site names.
- The README and vignette final pass. Only calls and names this change breaks are
  updated.

## Impact

- `data-raw/`: one simulation script per species builds all of that species'
  site-based datasets from a shared truth; the per-object scripts they replace are
  removed. All site-based simulated datasets are regenerated.
- R: level names on the random-effect draws in the fit constructor, the
  group-name warning in the data checks, and a `posterior` import.
- Fits: the fit object structure changes for every model with random effects, so
  all weight, size, density, and cover pre-fits and test fixtures are rebuilt
  (`--fits`, MCMC).
- Tests: site names in test subsets and expectations change; snapshots that print
  counts or per-level terms change and are left for review.
- Docs: dataset roxygen (`R/data_*.R`), demo scripts, and any README or vignette
  call that names a simulated site.
