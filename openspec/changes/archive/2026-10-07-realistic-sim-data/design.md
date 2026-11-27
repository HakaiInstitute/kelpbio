## Context

Each site-based simulated dataset is built by its own `data-raw/data_*_sim_*.R`
script, which draws its own site and year effects from `paste0("site", 1:10)` and
2019 to 2022, with one missing cell. The parameter values were chosen so the small
pre-fits converge quickly and the site curves separate in examples, not to match
the analysis estimates. The cover script simulates the in situ plot biomass
(`data_plot_biomass_sim_*`) from the cover model, independently of the weight,
size, and density simulations.

Analysis production estimates (`output/tables/{macro,nereo}/{weight,size,density,cover}/coef.csv`
in the analysis project) against the current simulations:

| | Production | Simulation now |
|---|---|---|
| *Macrocystis* weight at 5 fronds | exp(1.67) = 5.3 kg | 0.6 kg |
| *Macrocystis* mean fronds | exp(1.73) = 5.6 | 6 |
| *Macrocystis* plants per m² | exp(-1.16) = 0.31 | 0.3 |
| *Nereocystis* weight above floor at 30 mm | exp(-0.09) = 0.91 kg, floor 0.115 | 1 kg, floor 0.12 |
| *Nereocystis* log weight residual SD | 0.46 | 0.25 |
| *Nereocystis* mean diameter | exp(3.12) = 23 mm, Weibull shape 2.7 | 35 mm, shape 3.5 |
| *Nereocystis* stipes per m² (holding stipes) | exp(-1.73) = 0.18, zero inflation 5% | 0.8, 20% |

Production plot biomass (wet, kg/m²): *Macrocystis* median 2.7 (quartiles 1.4 to
4.9), *Nereocystis* median 1.05 (quartiles 0.16 to 3.7).

## Decisions

### One script per species from a shared truth

`data-raw/data_sim_nereo.R` and `data-raw/data_sim_macro.R` each build all of a
species' site-based datasets (weight, size, density, cover surveys, and in situ
plot biomass) from one truth:

1. Sites, years, and which data source covers each site-year.
2. True site, year, and site-year effects for each sub-model, drawn once.
3. The true expected density, size distribution, and weight allometry at each
   site-year, and from them the true plot biomass: expected density times the
   mean expected plant weight over the size distribution, as
   `kb_predict_plot_biomass()` composes the fits. The mean is an exact sum over
   frond counts for *Macrocystis* and an average over 1,000 evenly spaced
   Weibull quantiles for *Nereocystis*, whose weight uses the lognormal mean and,
   as its density covariate, the site-year's stipe density observed in the
   simulated density data (total count over total area, as plot biomass reads
   it). Harvested plants' sizes are drawn from the site-year's size
   distribution.
4. Observations drawn from each sub-model's likelihood at the covered site-years.
5. Drone surveys whose tide-corrected cover is the cover model solved for that
   site-year's true plot biomass, given cover-model site and year effects drawn
   once; the in situ estimate is the true plot biomass with lognormal estimation
   error and its compatibility limits, as now.

One script per species, rather than a shared helper sourced by per-object
scripts, keeps the truth in one place that a reader can follow top to bottom, and
makes the build order explicit. The wet/dry and carbon scripts are unchanged: they
have no sites, and their parameters already match the lab samples.

Alternatives: keep per-object scripts and source a truth helper (the truth and its
use are split across files, and each script must reproduce the random-number
sequence); scale-only realism, each dataset still independent (rejected by the
user: the cover-side biomass would not be the composed truth).

### Production means, moderate SDs

Intercepts, slopes, shapes, dispersions, zero inflation, the weight floor, and the
residual SDs take the production values above, with three exceptions calibrated
so the composed plot biomass spans the production range: the density intercepts
are raised (*Macrocystis* 0.45 rather than 0.31 plants per m², *Nereocystis* 1.5
rather than 0.18 stipes per m², since the moderated SDs remove the spread that
lifts the production means), and the cover canopy coefficient is 8 kg/m² for
both species (inside the *Macrocystis* production interval of 3.3 to 8.2), with
cover-model SDs of 0.2, so few surveys need their cover clipped. The resulting
true plot biomass at density-surveyed site-years has quartiles of 1.7 to 5.1
(median 2.3) kg/m² for *Macrocystis* and 0.56 to 2.2 (median 1.4) for
*Nereocystis*; 2 and 1 of 25 surveys have clipped cover. Random-effect SDs are held between
about 0.2 and 0.6: production *Macrocystis* weight `sSite` is 0.07, which would
make site curves indistinguishable in examples, and *Nereocystis* density SDs of
1.1 to 1.5 would spread site-year densities over orders of magnitude and make the
small pre-fits fail their convergence checks. After building, the script reports
the composed plot biomass quantiles, which are checked against the production
ranges above before the fits are rebuilt.

### Data availability differs by source

Ten sites and four years (2019 to 2022) per species. Availability, for each
species:

- Density: every site-year but one or two. The density-surveyed site-years are the
  rows of plot biomass.
- Size: most density-surveyed site-years, missing about four.
- Weight: harvests at about half the density-surveyed site-years, at no more than
  seven sites, so two or three sites are never harvested. Every harvested
  site-year is density-surveyed, so the *Nereocystis* weight data carry the
  site-year's stipe density.
- Drone surveys: about two-thirds of the density-surveyed site-years, one survey
  each; the in situ plot biomass is given only for those site-years, so every
  bundled survey has its calibration pair.

The pattern is fixed in the script (not random), so the gaps are deliberate and
documented, and the bundled fits exercise sampled new levels (sites never
harvested) and both observed flags in plot biomass.

### Invented site names

Each species has its own ten names, snake_case, single tokens, plausible for a
coastal survey (`otter_cove`, `gull_rock`), checked against the Hakai Institute
site list so none matches or contains a real survey site. Real names would invite
reading a simulated number as that site's result. Separate lists per species
reflect that the two kelps are surveyed at different beds.

### Random-effect draws carry their levels

The fit constructor rebuilds each per-level rvar (`bSite`, `bYear`, `bSiteYear`)
with `posterior::rvar(draws_of(x), dimnames = ..., nchains = ...)`, using the
stored `meta$site_levels` and `meta$year_levels`, which are in the same order as
the Stan indices. `as_draws_df()`, `summarise_draws()`, and so `tidy()`, then name
elements `bSite[otter_cove]` and `bSiteYear[otter_cove,2020]`; positional indexing
is unchanged, so no internal code changes. The diagnostics summary is computed
after naming, so its rows match. This is done in `new_kb_fit()` rather than
`fit_stan()`, which is model-agnostic and does not know the levels.

### Ambiguous group names warn

A `warn_group_names()` helper, like `warn_implausible_units()`, runs in every data
check with site and year columns. Flattened names join two levels with a comma inside brackets, so a level
containing `,`, `[`, or `]` cannot be parsed back by tools such as tidybayes. The
data checks warn, naming the column and the offending levels, and continue:
indexing by name in R is unaffected, and refusing such data would force users to
rename sites for the sake of third-party tools. Spaces are allowed.

### Load `posterior` with kelpbio

`#' @importFrom posterior rvar` in the package documentation file makes
`posterior` load whenever kelpbio does. Without it a fit's draws, read before any
kelpbio function has run (a bundled pre-fit, or a fit read back with `readRDS()`),
have no rvar methods registered: they print as `<rvar[0]>`, report length 0, and
cannot be indexed. `posterior` is already in `Imports`.

## Risks / Trade-offs

- [One script per species is long] → It is sectioned in the order above, with the
  truth and the availability table at the top.
- [The composed truth is not exactly what the fits estimate: the truth averages
  over the untruncated size distribution, while plot biomass truncates at the
  largest measured size] → The in situ estimate carries estimation error much
  larger than that difference; the bundled cover fits are for examples, not
  inference.
- [Canopy cover generated to fit the cover model around the true biomass can fall
  outside (0, 1)] → Cover is kept between 0.02 (*Macrocystis*; 0 for
  *Nereocystis*, whose surveys can have no canopy) and 0.95, and the scripts
  report how many surveys were clipped; a few are tolerated in example data.
- [Every pre-fit and fixture with random effects is rebuilt] → One `--fits` run
  covers the new data, the level names, and the object structure together.
