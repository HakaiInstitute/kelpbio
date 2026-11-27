## Context

See the team discussion and `scripts/sim-site-year-prior.R` for the simulation. This
doc records only why the site:year structure is data-determined rather than
user-chosen, and where the thresholds come from.

## Decisions

- **Keep by default, drop only when undefined.** The simulation's decisive metric is
  held-out prediction to new site-years (marginal over the interaction). Dropping the
  site:year effect is catastrophic when the true SD is non-zero (aliased design, true
  SD 0.5: elpd_newyear ~ -173 dropped vs ~ -97/-120 kept) and only marginally better
  when the true SD is exactly zero (~5 elpd). The loss is asymmetric, and for kelp
  allometry we expect genuine year-to-year variation within a site, so the effect is
  kept whenever the year dimension exists.
- **Single-year drop.** With fewer than two distinct years the site:year interaction
  is structurally confounded with the site effect (one cell per site); it contributes
  only a sampling funnel and no predictive information, so it is omitted.
- **Aliased warning, not drop.** When years exist but no site spans more than one
  year, the site vs site:year split is not identifiable from the design; the
  regularizing prior carries the split. The effect is retained (dropping is the
  catastrophic option) and the user is warned that the estimate reflects the prior.
  No prior or model-selection choice recovers an aliased design; the remedy is more
  data (e.g. appending the coastwide Hakai records), documented separately.
- **Prediction consistency.** The Stan `site_year_on` flag only gates the term in the
  mean; the `bSiteYear`/`sSiteYear` parameters are still declared and sampled (from
  their priors) when off. The R prediction helper must therefore also skip the
  site:year contribution when the effect was omitted, or predictions reintroduce
  prior-only noise the fit excluded.
- **Structural flag stays in Stan.** The determination is data-derived in R and passed
  as the existing `site_year_on` data value; the compiled model is unchanged (no
  recompile).

## Rule

- `on = (number of distinct years) > 1`
- `aliased = on && no site is sampled in more than one year`
