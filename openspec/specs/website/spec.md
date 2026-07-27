# website

## Purpose

The pkgdown documentation site for kelpbio: a Hakai-themed `_pkgdown.yml` and navbar/logo assets, a "Get started" vignette landing page, the CI workflow that builds the site and deploys it to `gh-pages`, and the `DESCRIPTION` metadata pkgdown and the vignette engine consume.

## Requirements

### Requirement: The package ships a Hakai-themed pkgdown configuration

The package SHALL include a `_pkgdown.yml` that builds a Bootstrap 5 site using the shared Hakai Institute theme (matching the `hydrocan` template), with the site `url` set to the package's GitHub Pages address.

#### Scenario: pkgdown config declares the Hakai theme and site URL

- **WHEN** `_pkgdown.yml` is inspected
- **THEN** it sets `url: https://hakaiinstitute.github.io/kelpbio/` and a `template` using `bootstrap: 5`, the `flatly` bootswatch, the Hakai primary/link colour `#aa2025`, and a dark navbar background `#2c3e50`

#### Scenario: The navbar carries the shared Hakai branding

- **WHEN** the `pkgdown/` directory is inspected
- **THEN** it contains `templates/navbar.html`, `assets/hakai.png`, and a placeholder `favicon/` set, and the navbar template renders the Hakai logo as a link to `https://www.hakai.org`

### Requirement: The site builds without error

Running pkgdown over the installed package SHALL produce a complete static site, including a home page from `README.md`, a function reference, and a "Get started" article.

#### Scenario: pkgdown builds the site

- **WHEN** `pkgdown::build_site()` (or `build_site_github_pages()`) is run against the installed package
- **THEN** it completes without error and writes a site whose navbar includes a "Get started" entry sourced from `vignettes/kelpbio.Rmd`

#### Scenario: The Get started vignette demonstrates the kb_ API

- **WHEN** `vignettes/kelpbio.Rmd` is inspected
- **THEN** it is a valid `rmarkdown::html_vignette` with a `\VignetteIndexEntry`, a package overview, and illustrative `kb_*()` usage in non-evaluated chunks (`eval = FALSE`), so it renders without a compiled package or a live Stan fit

### Requirement: The reference index is organized into thematic sections

`_pkgdown.yml` SHALL organize the function reference into titled thematic sections so every exported function appears under a section rather than in a single flat list, and exported functions SHALL carry `@family` tags so related functions cross-reference each other in their See Also. Any new exported function must be added to a section (or matched by an existing pattern) so the reference index stays complete.

#### Scenario: The reference config declares thematic sections

- **WHEN** `_pkgdown.yml` is inspected
- **THEN** it declares a `reference:` block with titled sections (fitting, priors, data, predictions and plotting, and model summaries and diagnostics) that enumerate the S3 method topics (e.g. `tidy.kb_fit_weight`, `coef.kb_fit`, `autoplot.kb_predictions`) so every method appears under a section

#### Scenario: Every export maps to a section

- **WHEN** the pkgdown reference index is built
- **THEN** every exported function maps to exactly one section and pkgdown reports no topics missing from the index

### Requirement: CI builds and deploys the site

The package SHALL include a GitHub Actions workflow that builds the pkgdown site on push and pull request and deploys it to the `gh-pages` branch on push to the default branch.

#### Scenario: The pkgdown workflow is present and deploy-gated

- **WHEN** `.github/workflows/pkgdown.yaml` is inspected
- **THEN** it builds the site on `push` to `main`/`master`, `pull_request`, `release`, and `workflow_dispatch`, and the deploy step to `gh-pages` runs only when the event is not a pull request

### Requirement: DESCRIPTION declares the metadata pkgdown consumes

`DESCRIPTION` SHALL declare the package URLs, bug-report address, and vignette build configuration that pkgdown and the vignette engine require.

#### Scenario: DESCRIPTION carries site and vignette metadata

- **WHEN** `DESCRIPTION` is inspected
- **THEN** `URL` lists both the GitHub repository and `https://hakaiinstitute.github.io/kelpbio/`, `BugReports` points to the repository issues page, `VignetteBuilder` is `knitr`, and `knitr` and `rmarkdown` are in Suggests
