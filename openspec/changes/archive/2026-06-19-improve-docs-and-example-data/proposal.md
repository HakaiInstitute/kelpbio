## Why

The weight-model documentation diverges from the `bboutools` / `ssdtools` /
tidyverse conventions: most exported functions lack `@examples`, several
descriptions carry decision-making rationale rather than usage, and some inline
comments narrate what the code does. Runnable examples are blocked because no fit
object ships with the package and the only example dataset is the confidential
Hakai data. A small simulated dataset and a slim pre-fit object unblock runnable
examples and fast tests, and let the documentation be brought in line.

## What Changes

- **BREAKING** Rename the exported dataset `kb_data_weight` to
  `data_weight_hakai` (the real Hakai allometry data).
- Add `data_weight_sim`, a small seeded simulated dataset (columns `diameter`,
  `weight`, `site`, `year`) for fast tests and examples, promoted from the test
  fixtures to an exported data object.
- Add `fit_weight`, a slim pre-fit weight model built from
  `data_weight_sim`, so examples that need a fit run at `R CMD check`.
- Add runnable `@examples` to all exported functions and S3 methods; only the
  slow `kb_fit_weight()` call is wrapped in `if (interactive())`.
- Strip decision/rationale and in-session-context text from user-facing titles,
  descriptions, and details so the docs state how the implementation works, not
  why it was chosen.
- Split the over-long `@description` blocks on `kb_predict_weight`,
  `kb_predict_weight_by`, and `kb_plot_predictions` into a short `@description`
  plus `@details`; standardise `@param` descriptions to end with a period; add a
  few `@seealso` links.
- Moderate inline-comment trim across the heaviest files (keep "why", cut "what").

## Capabilities

### New Capabilities
<!-- none: no new observable behaviour beyond the data objects covered below -->

### Modified Capabilities
- `data`: the bundled-dataset requirement changes. The exported dataset is
  renamed `data_weight_hakai`; `data_weight_sim` and the pre-fit
  `fit_weight` become exported data objects (the simulated data is no longer
  fixture-only).

## Impact

- Exported data objects: `kb_data_weight` removed; `data_weight_hakai`,
  `data_weight_sim`, `fit_weight` added. Every reference in `R/`,
  `tests/`, `data-raw/`, README, and vignettes updates.
- `data-raw/`: rename the Hakai builder; add builders for the simulated dataset
  and the pre-fit object.
- Roxygen across all `R/` exported files; `man/*.Rd` and `NAMESPACE` regenerate.
- No runtime API or model behaviour changes; conventions follow
  `decisions/bboutools-api-review.md` and the documentation rules in
  `openspec/config.yaml`.

## Non-goals

- No change to model structure, priors, sampling, or the prediction engine.
- No new sub-models (size, density, blade, wetdry, carbon remain out of scope).
- No vignette rewrite beyond updating dataset references.
