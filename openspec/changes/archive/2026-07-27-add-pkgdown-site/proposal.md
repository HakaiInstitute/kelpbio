## Why

kelpbio has no documentation website. As a public Hakai Institute / Poisson Consulting package distributed via the Hakai R-universe, it needs a pkgdown site that matches the house style used across Hakai packages (template package: `~/Code/HakaiInstitute/hydrocan`) so the framework is in place before the `kb_` API lands. Standing the site up now — while the package is still small — keeps later model changes a matter of adding reference entries and articles rather than bootstrapping infrastructure.

This change delivers the website framework only: the pkgdown config + Hakai theme, the deploy workflow, the DESCRIPTION metadata pkgdown needs, and a minimal placeholder "Get started" vignette. It is intentionally thin — no real `kb_*()` examples, because the weight model (Change B `add-weight-model`) is not yet built.

## What Changes

- Add `_pkgdown.yml` with the Hakai theme: Bootstrap 5, `flatly` bootswatch, Hakai red (`#aa2025`) primary/link colour and navy (`#2c3e50`) dark navbar, with `url:` set to `https://hakaiinstitute.github.io/kelpbio/` (matching hydrocan, retargeted).
- Add `pkgdown/templates/navbar.html` and `pkgdown/assets/hakai.png` (the Hakai logo + navbar that links to hakai.org) — copied verbatim from hydrocan as shared Hakai branding.
- Add `.github/workflows/pkgdown.yaml` — the standard r-lib pkgdown workflow that builds on push/PR and deploys to the `gh-pages` branch on push to `main`.
- Add a minimal `vignettes/kelpbio.Rmd` so pkgdown gets a "Get started" tab; bare placeholder content (one short overview paragraph), no evaluated code.
- Update `DESCRIPTION`: add `URL` (GitHub + pkgdown site) and `BugReports`, add `VignetteBuilder: knitr`, and add `knitr` + `rmarkdown` to Suggests.

## Capabilities

### New Capabilities
- `website`: the pkgdown documentation-site contract — a Hakai-themed `_pkgdown.yml` + navbar/logo assets, a CI workflow that builds the site and deploys to `gh-pages`, the DESCRIPTION metadata pkgdown consumes (`URL`, `BugReports`, `VignetteBuilder`), and a "Get started" vignette landing page.

### Modified Capabilities
<!-- none — this change adds website infrastructure only; no existing capability behavior changes -->

## Impact

- **Site config**: new `_pkgdown.yml`, `pkgdown/templates/navbar.html`, `pkgdown/assets/hakai.png` (all already pre-listed in `.Rbuildignore`; `/docs/` already in `.gitignore`).
- **CI**: new `.github/workflows/pkgdown.yaml`; deploys to a `gh-pages` branch (GitHub Pages must be set to serve from `gh-pages` — a one-time repo setting).
- **DESCRIPTION**: gains `URL`, `BugReports`, `VignetteBuilder: knitr`, and Suggests `knitr`, `rmarkdown`.
- **Vignettes**: new `vignettes/` directory with a single placeholder `kelpbio.Rmd`.

## Non-goals

- **Final package logo / hex sticker.** kelpbio ships a placeholder `pkgdown/favicon/` set; the bespoke logo and hex are deferred until kelpbio has its own branding. The navbar carries the shared Hakai logo.
- **Reference-index organisation** (`reference:` groupings in `_pkgdown.yml`). pkgdown auto-generates the index; explicit grouping waits until there are exported `kb_*()` functions.
- **Real getting-started content / how-to articles.** The vignette is a placeholder; it is fleshed out as `kb_*()` functions land (Change B onward). No predictions/plotting articles here.
- **Any package source, model, or `kb_` API changes.** This change is documentation infrastructure only.
