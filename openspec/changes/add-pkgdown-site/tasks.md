## 1. pkgdown config and Hakai theme

- [x] 1.1 Add `_pkgdown.yml`: copy hydrocan's, retarget `url:` to `https://hakaiinstitute.github.io/kelpbio/`; keep `template` (bootstrap 5, `flatly`, primary/link `#aa2025`, navbar-bg `#2c3e50`, navbar-dark)
- [x] 1.2 Copy `pkgdown/templates/navbar.html` verbatim from hydrocan (Hakai logo link to hakai.org)
- [x] 1.3 Copy `pkgdown/assets/hakai.png` from hydrocan (shared Hakai branding)
- [x] 1.4 Do NOT add `pkgdown/favicon/` — deferred until kelpbio has its own logo (see proposal Non-goals)
- [x] 1.5 Confirm `.Rbuildignore` already excludes `_pkgdown.yml`, `pkgdown`, `docs` (it does) and `.gitignore` ignores `/docs/` (it does)

## 2. DESCRIPTION metadata

- [x] 2.1 Add `URL: https://github.com/HakaiInstitute/kelpbio, https://hakaiinstitute.github.io/kelpbio/`
- [x] 2.2 Add `BugReports: https://github.com/HakaiInstitute/kelpbio/issues`
- [x] 2.3 Add `VignetteBuilder: knitr` and add `knitr`, `rmarkdown` to Suggests
- [x] 2.4 Confirm `DESCRIPTION` is well-formed (verified by static inspection — all fields valid, file parses; no roxygen changed in this change, so a `document()`/`load_all()` pass is unnecessary and would force a multi-minute Stan recompile)

## 3. Get started vignette (placeholder)

- [x] 3.1 Create `vignettes/kelpbio.Rmd` — `rmarkdown::html_vignette` with `\VignetteIndexEntry`, `\VignetteEngine{knitr::rmarkdown}`, `\VignetteEncoding{UTF-8}` (named after the package so it becomes the "Get started" tab)
- [x] 3.2 Content: one short overview paragraph of what kelpbio does; no evaluated `kb_*()` code (the API does not exist yet)
- [x] 3.3 Confirm the vignette knits cleanly (`rmarkdown::render()` succeeds, no title-mismatch warning)

## 4. Deploy workflow

- [x] 4.1 Add `.github/workflows/pkgdown.yaml` (copy hydrocan's): build on push to `main`/`master`, `pull_request`, `release`, `workflow_dispatch`; deploy to `gh-pages` only when not a PR
- [ ] 4.2 Build the site locally once to confirm theme + "Get started" tab — DEFERRED: local `pkgdown::build_site()` `load_all()`s the package, forcing a 10-20 min Stan recompile. The CI workflow (4.1) builds the site on every push/PR, so the build is verified there instead. Run locally only if needed.
- [ ] 4.3 After push: set GitHub Pages to serve from the `gh-pages` branch (one-time repo setting) and confirm the workflow is green and the site is live (verifiable only after pushing the branch to GitHub)
