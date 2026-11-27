## Why

The fit `print()` header carries the model's `Family` / `Fixed` / `Random`
structure, but that structure is fixed by species (there is no formula
interface), so it is reference material about the model class rather than
per-fit state. It also cannot render the full model faithfully in the space of a
header. Users have no way to obtain the complete model specification (likelihood,
linear predictor, random-effect distributions, priors) in scientific notation,
which is exactly what a methods section or a model review needs.

## What Changes

- Add `kb_model_describe(fit, prose = FALSE)`: renders the complete model in
  multilevel scientific notation, using the package's own parameter names
  (`bWeight`, `bDiameter`, `sSite`, ...) so the equation cross-references the
  `tidy()` / `summary()` / `coef()` coefficient table. It shows the likelihood,
  the linear predictor for the (log) mean, the random-effect distributions, and
  the priors.
  - The priors shown are the fit's stored priors (so custom priors render
    correctly), the centering reference is the fit's stored `d0` / `f0`, and
    `nu = 4` is shown as a fixed constant (not a parameter).
  - `site_year_on` is respected: when the `site:year` term was dropped, it is
    omitted from the linear predictor and from the random-effect list.
  - The response and predictor are named descriptively (e.g. "wet weight",
    "sub-bulb diameter") without units, since the data columns are unitless and
    the model is scale-invariant.
  - `prose = TRUE` renders the same content as a report-ready methods paragraph.
- **BREAKING** (pre-release): slim the `print()` header. Drop the
  `Family` / `Fixed` / `Random` lines (now covered by `kb_model_describe()`).
  Keep model + species, `Centered`, `Data` (whose group counts still convey the
  grouping factors and their level counts), `Draws`, and `Converged`, plus the
  prior-only note. Add a footer pointing to `kb_model_describe(fit)`.

## Capabilities

### New Capabilities
- `model-description`: `kb_model_describe()` renders the full model in scientific
  notation (or as methods prose), from the fit's stored structure and priors.

### Modified Capabilities
- `summaries`: the shared fit header no longer includes the family / fixed /
  random structure lines; `print()` is a per-fit glance (identity, centering,
  data, sampling, convergence) with a pointer to `kb_model_describe()`.

## Impact

- New `R/kb_model_describe.R` (generic dispatching on the fit subclass, with
  `kb_fit_weight_nereo` / `kb_fit_weight_macro` methods and a shared renderer);
  new man page; `NAMESPACE` updated.
- `R/summary.R` (`.kb_fit_header()` / `.fit_descriptor()`) and `R/print.R`
  (`.print_kb_fit_header()`): drop the structure fields from the header. Decide
  whether `summary()` keeps them (it drops them too, for a single header
  contract).
- Reader docs: `README`, `vignettes/kelpbio.Rmd` gain a `kb_model_describe()`
  example; `scripts/demo-api-test.R` exercises it.
- Tests: update the `print` snapshots for the slimmed header; add
  `tests/testthat/test-kb_model_describe.R` (snapshot the notation and prose for
  both species, and the `site_year_on`-dropped case).
- No change to the fit object, the sampler, predictions, or numerics.
