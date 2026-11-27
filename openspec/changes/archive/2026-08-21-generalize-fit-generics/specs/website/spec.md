## MODIFIED Requirements

### Requirement: The reference index is organized into thematic sections

`_pkgdown.yml` SHALL organize the function reference into titled thematic sections so every exported function appears under a section rather than in a single flat list, and exported functions SHALL carry `@family` tags so related functions cross-reference each other in their See Also. Any new exported function must be added to a section (or matched by an existing pattern) so the reference index stays complete.

#### Scenario: The reference config declares thematic sections

- **WHEN** `_pkgdown.yml` is inspected
- **THEN** it declares a `reference:` block with titled sections (fitting, priors, data, predictions and plotting, and model summaries and diagnostics) that enumerate the S3 method topics (e.g. `tidy.kb_fit`, `predict.kb_fit_weight`, `autoplot.kb_predictions`) so every method appears under a section

#### Scenario: Every export maps to a section

- **WHEN** the pkgdown reference index is built
- **THEN** every exported function maps to exactly one section and pkgdown reports no topics missing from the index
