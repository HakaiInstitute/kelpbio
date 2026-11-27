## Context

Reference ranges: for *Nereocystis*, the coastwide harvest compilation (7
programmes, 60 sites, Alaska to California, 1,832 plants): diameter 3-80 mm
(site-year medians 17-75), weight 0.02-41 kg (site-year medians 0.4-12.9). For
*Macrocystis*, Hakai Institute harvests (20 sites, 2016-2025): weight 0.35-77 kg
(site-year medians 2.0-20.5). Stipe density, Hakai Institute surveys: 0.17-15.7
stipes per m² (median 2.5). A unit mistake moves the median by a factor of 10
(centimetres), 1,000 (grams), or 10,000 (stipes per hectare).

## Decisions

### Median thresholds at fit time

Warn when the column median is outside: `diameter` 10-200 mm, `weight` above
100 kg, `density` above 100 stipes per m². Each threshold lies well beyond the
most extreme site-year median in the reference data and well inside the value a
unit mistake produces (diameter in centimetres has a median near 4; the smallest
site-year median weight in grams is about 400). The median, not the range, so a few extreme plants do not
trigger it.

Alternative: error. Rejected because a median rule can misfire on valid but
unusual data (for example, only juvenile plants), and an error would block it.

### Range check at prediction

A median rule misfires on small `new_data` (one small plant is valid), so
prediction instead compares supplied values with the fitted data: a warning when
any value is below half the fitted minimum or above twice the fitted maximum.
It applies to the predictor (`diameter`, `fronds`) on both sides. For a fit with
the density effect it applies to `density` on the upper side only: density unit
mistakes (per hectare, per 10 m²) inflate values, while a density below the fitted
range is a real sparse site.

### Expected units live in one lookup

The expected unit of each column is stored once, keyed by column name, and used by
both checks' messages. Column names are shared across models, so a new sub-model
reusing a column reuses its unit.
