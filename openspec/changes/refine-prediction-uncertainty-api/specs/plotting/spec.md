# plotting

## MODIFIED Requirements

### Requirement: Metadata-driven, overridable defaults

`x`, `style`, and `facet` SHALL default to `NULL` and be inferred from the prediction's metadata, while remaining overridable arguments. A `max_facets` argument SHALL cap the number of facet panels drawn (default a small finite number); when the grouping has more groups than `max_facets`, the first `max_facets` are shown and a `cli` warning names how many were dropped and how to override. `Inf` disables the cap.

#### Scenario: Inference from metadata
- **WHEN** the arguments are left `NULL`
- **THEN** `x` is the predictor, `facet` is the grouping variables, and `style` follows the predictor type

#### Scenario: Graceful fallback when metadata is missing
- **WHEN** the metadata has been stripped (e.g. by dplyr post-processing) and cannot be inferred
- **THEN** the function errors with a `cli` message directing the user to supply `x`/`facet`

#### Scenario: Facet panels are capped
- **WHEN** a prediction has more grouping combinations than `max_facets`
- **THEN** only the first `max_facets` groups are plotted and a `cli` warning reports how many of the total were shown
