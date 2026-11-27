## Context

The site:year rule was set by `2026-07-27-auto-site-year-structure`: omit the
effect for single-year data, keep it with a warning when it is aliased with the
site or year effect. Its supporting simulation covered crossed, sparse crossed,
and diagonal designs only. A new simulation, a side analysis kept outside
the package, fitted the *Nereocystis* weight model
with and without the effect across seven designs (crossed 6 x 4, sparse half of
6 x 4, single year 10 x 1, single site 1 x 8, diagonal 6 x 6, each site in one
year 8 x 4, one site per year 3 x 6), true site:year SDs of 0, 0.15, and 0.4,
and 200 replicates per cell (8,400 fits at the package defaults).

Findings that set this change:

- Where the effect is identified, omitting it fails whenever it is real. At a
  true SD of 0.4, 95% CI coverage of observed site-years was 0.40 (crossed) and
  0.62 (sparse) without it against 0.95 with it, and coverage of unobserved
  cells in the sparse design was 0.35 against 0.95.
- Where it is aliased, the choice changed CRPS for new and unobserved levels
  and site and year means by -17% to 15%, and observed site-years by under 2%.
  Omitting it gave intervals below nominal for unobserved cells (0.81 to 0.86
  at a true SD of 0.4) and site means; fitting it kept every target's coverage
  at 0.94 or above.
- For single-year data, the case the current rule omits, fitting the effect
  changed CRPS for a fitted site in a new year by 11%, 7%, and -3%, and for
  site means by 12%, 8%, and -11%, at true SDs of 0, 0.15, and 0.4, with the
  same coverage in both arms. Omitting it is better only when site:year
  variation is close to absent, which is not a credible assumption for kelp
  surveys.

## Goals / Non-Goals

**Goals:** one site:year structure for every data set of the weight, size, and
density models; the aliasing warning covers single-year data.

**Non-Goals:** user on/off arguments for group effects, default prior changes,
and the handling of one-level effects (see proposal).

## Decisions

**Always fit, rather than keep the single-year exception or add an argument.**
The exception buys at most about 12% CRPS, and only when the true SD is near
zero, at the cost of overconfident intervals otherwise. An on/off argument
would mostly be used to get narrower intervals, which in aliased designs are
overconfident; a strong `sd_site_year` prior gives the same control without
forcing the effect to zero, and the data can still move it.

**Remove the Stan data flag rather than set it to 1.** A flag that is always on
is dead code in six models, and the structural-flag convention is for effects
the data or a model choice can switch off. Removing it edits the Stan source
stored in every fit of those models, so the weight, size, and density pre-fits
and fixtures are rebuilt. The R-side record of whether a fit has a site:year
effect stays, since the cover biomass models share the prediction and
description code and have none.

**Reduce `site_year_structure()` to the aliasing check.** With nothing left to
switch, it returns only the aliased main effects; the notifier keeps the
warning and loses the omission message.

## Risks / Trade-offs

- [Single-year fits gain a site:year SD that only its prior informs] The split
  between site and site:year variation, and so the width of intervals for a
  site in a new year and for site means, follows the `sd_site_year` prior. The
  warning says the term is not separately interpretable; the pending
  documentation pass explains when to tighten the prior.
- [Single-year fits have a year effect with one level] Its divergent
  transitions (about 2% of transitions in the simulation, with or without
  site:year) are unchanged by this change and are handled separately.

## Open Questions

- Should the default `sd_site_year` prior (and the other group-level SD priors)
  be calibrated to the variation estimated from the coastwide and Hakai data
  rather than `exponential(1)`? Out of scope here; it would change every fit's
  defaults and deserves its own change.
