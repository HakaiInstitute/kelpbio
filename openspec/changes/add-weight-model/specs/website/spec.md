## MODIFIED Requirements

### Requirement: The site builds without error

Running pkgdown over the installed package SHALL produce a complete static site, including a home page from `README.md`, a function reference, and a "Get started" article.

#### Scenario: pkgdown builds the site

- **WHEN** `pkgdown::build_site()` (or `build_site_github_pages()`) is run against the installed package
- **THEN** it completes without error and writes a site whose navbar includes a "Get started" entry sourced from `vignettes/kelpbio.Rmd`

#### Scenario: The Get started vignette demonstrates the kb_ API

- **WHEN** `vignettes/kelpbio.Rmd` is inspected
- **THEN** it is a valid `rmarkdown::html_vignette` with a `\VignetteIndexEntry`, a package overview, and a worked `kb_*()` example that runs live against the bundled `fit_weight_sim_nereo` pre-fit model, with only the `kb_fit_weight_nereo()` fitting call left unevaluated (`eval = FALSE`), so it builds without a live Stan fit

### Requirement: The reference index is organized into thematic sections

`_pkgdown.yml` SHALL organize the function reference into titled thematic sections so every exported function appears under a section rather than in a single flat list, and exported functions SHALL carry `@family` tags so related functions cross-reference each other in their See Also. Any new exported function must be added to a section so the reference index stays complete.

#### Scenario: The reference config declares thematic sections

- **WHEN** `_pkgdown.yml` is inspected
- **THEN** it declares a `reference:` block with titled sections (fitting, priors, data, predictions and plotting, and model summaries and diagnostics) that list their topics explicitly, including the S3 method topics under model summaries and diagnostics

#### Scenario: Every export maps to a section

- **WHEN** the pkgdown reference index is built
- **THEN** every exported function maps to exactly one section and pkgdown reports no topics missing from the index
