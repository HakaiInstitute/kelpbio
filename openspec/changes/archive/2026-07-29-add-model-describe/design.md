## Context

The `print()` / `summary()` header is built by `.kb_fit_header()` (fields) and
`.print_kb_fit_header()` (rendering) in `R/summary.R` / `R/print.R`, with the
species-specific `Family` / `Fixed` / `Random` / `Centered` strings supplied by
`.fit_descriptor()` methods. Those structure strings are constant per species
(no formula interface), so they describe the model class, not the fitted
instance. There is no function that assembles the full model equation, even
though the analysis report already renders it (the `write-model-description`
notation), and the fit stores everything needed (priors, centering reference,
`site_year_on`, `nu`).

## Goals / Non-Goals

**Goals:**
- Give users the complete model specification in scientific multilevel notation,
  cross-referable to the coefficient table, and as report-ready prose.
- Make `print()` a focused per-fit glance and stop duplicating the fixed model
  structure there.
- Keep a single source of truth for the model structure (the descriptor), reused
  by `kb_model_describe()`.

**Non-Goals:**
- No change to the fit object, sampler, predictions, or numerics.
- No LaTeX/`equatiomatic`-style output in this cut (console text only); a LaTeX
  emitter can come later.
- No journal-style Greek symbols; the package parameter names are the notation.

## Decisions

### Package parameter names as the notation, not Greek

The equation uses `bWeight`, `bDiameter`, `bDiameter2`, `sSite`,
`sSiteDiameter`, `sSiteYear`, `sWeight` (nereo) and the macro equivalents. Every
symbol in the equation therefore appears verbatim in `tidy()` / `summary()` /
`coef()`, so a reader maps the equation to the estimates with no key. This also
matches the notation already in the Stan file headers. Journal-style Greek is the
report's job (`write-model-description`), not the in-package function.

### S3 generic on the fit, shared renderer

`kb_model_describe()` is a generic dispatching on the species subclass, matching
the prediction verbs and `.weight_linpred()`. Each species method supplies its
structural pieces (likelihood line, linear-predictor terms, random-effect list)
to a shared renderer that formats the notation block and, for `prose = TRUE`,
the methods paragraph. The structural pieces come from a single descriptor so the
notation and the (slimmed) header cannot drift.

### Faithful to the fitted instance

- Priors: rendered from `fit$meta$priors` (the stored priors), so custom priors
  show their actual hyperparameters.
- Centering: `d0` / `f0` from `meta$diameter_ref` / `meta$fronds_ref`.
- `site_year_on`: when `FALSE`, the `site:year` term is omitted from the linear
  predictor and the random-effect list, so the description matches the fit.
- `nu`: shown inline as the fixed constant `4`, not as a parameter.

### Units-agnostic naming

The response and predictor are named descriptively ("wet weight", "sub-bulb
diameter" / "frond count") with no units, because the data columns are unitless
and the model is scale-invariant (centered in log space). The centering value is
shown as a bare number (`d0 = 38.8`).

### `prose = TRUE` in the first cut

A single function with a `prose` flag, rather than two functions, keeps the
surface small. `prose = FALSE` (default) prints the notation block; `prose =
TRUE` prints the methods paragraph. Both draw from the same descriptor, so they
cannot disagree.

### Slimmed header, single contract

`print()` and the `summary()` header both drop the `Family` / `Fixed` / `Random`
lines (one shared renderer, so they stay identical). The grouping factors and
their level counts remain visible through the `Data:` line's group counts, so
the slim header still conveys which factors group the model and whether
`site:year` was retained. A footer line points to `kb_model_describe(fit)`.

## Risks / Trade-offs

- Losing the at-a-glance distribution/structure from `print()` → mitigated by the
  `Data:` group counts (grouping still visible), the species (which fixes the
  structure), and the discoverability footer.
- Notation rendered as plain console text cannot show true subscripts/
  superscripts → use `x`, `x^2`, `a[site]`, `bSiteYear[site, year]`; this matches
  the Stan-header style and stays copy-pasteable.
- Snapshot churn for the `print` header and new describe snapshots → expected;
  covered in tasks.

## Migration Plan

1. Add the descriptor pieces needed by both the header and the equation (single
   source), then `kb_model_describe()` generic + species methods + shared
   renderer (notation and prose).
2. Slim `.kb_fit_header()` / `.print_kb_fit_header()`; add the footer.
3. Update `print` snapshots; add `test-kb_model_describe.R`.
4. Update `README`, vignette, demo.
5. Sync `summaries` + `model-description` specs; archive.

## Open Questions

- Whether `summary()`'s header should also drop the structure lines (leaning yes,
  for a single header contract) or retain them since `summary()` is the detailed
  view. Current lean: drop, and let `kb_model_describe()` be the one home for
  structure.
