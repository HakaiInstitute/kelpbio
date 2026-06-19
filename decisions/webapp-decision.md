# Web Application Decision: kelpbiomass GUI

## Requirements

The web application must enable marine ecologists with no R or coding experience to:

1. **Upload data**: CSV files containing diameter measurements, density transect counts, and optionally tissue composition data.
2. **Select configuration**: Choose which model components to use, whether to use pre-fit models or fit custom models, and set output units.
3. **Fit models**: Run Bayesian MCMC for custom model fitting, with progress feedback and the ability to cancel.
4. **Use pre-fit models**: Generate instant predictions using bundled coast-wide model coefficients (no MCMC).
5. **View results**: Biomass estimates with uncertainty intervals, site-level comparisons, diagnostic plots (trace plots, Rhat, ESS, posterior predictive checks).
6. **Download outputs**: CSV/XLSX tables, publication-quality figures (PDF/PNG), and a formatted PDF report.
7. **Reproduce in R**: View and copy the R code that would reproduce the app's analysis using the kelpbiomass package directly.

### Scientific credibility requirements

Users of this tool are researchers who will publish results. The app must:
- Show convergence diagnostics so users can assess model adequacy
- Display posterior predictive checks so users can evaluate model fit
- Report estimates with compatibility intervals (not just point estimates)
- Provide the exact R code for reproducibility
- Make clear when population-level (vs. site-specific) predictions are being used

---

## Constraints

| Constraint | Implication |
|-----------|-------------|
| **Solo consultant maintenance** | Single-codebase solutions strongly preferred. No dedicated frontend developer. |
| **Long-running MCMC** | Custom model fitting takes 2-20 minutes depending on dataset size and model complexity. Must not block the UI. |
| **Data sensitivity** | Some ecological survey data is proprietary or sensitive (endangered species locations). On-premises deployment must be possible. |
| **Target users** | Marine ecologists, resource managers, conservation biologists. No coding experience assumed. Familiar with spreadsheets and basic statistics. |
| **Developer tooling** | Claude Code available for development. Open to non-R solutions if outputs can be validated through testing and viewing. |
| **Engine decision** | The R package uses cmdstanr + `instantiate` (see `engine-decision.md`). The app must work with this backend. |

---

## Option Evaluations

### 1. Shiny (R) + bslib

**Description**: Build the web app as an R Shiny application using the `bslib` package for modern Bootstrap 5 UI components. Package as a companion R package (`kelpbiomassapp`) that depends on the core `kelpbiomass` package.

**Project-specific pros**:

- **Proven Poisson Consulting pattern**: The `bbousuite` ecosystem demonstrates exactly this architecture: `bboutools` (core package) + `bboushiny` (Shiny companion app) + `bboudata` (example data). `bboushiny` handles CSV upload, Bayesian model fitting with progress indicators, results display with uncertainty, downloadable outputs, and reproducible R code generation. The kelp app would follow this identical pattern. Additionally, `shinyssdtools` (authored by this developer) provides a second reference implementation for a Shiny app wrapping a Bayesian modeling package.

- **Native R integration**: Shiny server code calls `kb_predict_weight()`, `kb_fit_density()`, and `kb_plot_biomass()` directly as R function calls. No serialization, no API translation, no data format conversion. The app is a thin UI layer over the package API.

- **`ExtendedTask` for async MCMC**: Shiny 1.8.1+ provides `ExtendedTask`, which runs long computations in a background R process without blocking the user session. The user sees a progress indicator and can interact with other parts of the app while MCMC runs. This directly addresses the long-running computation constraint. **Note: cmdstanr is a significantly better Shiny backend than brms/rstan** -- cmdstanr runs MCMC as an external process (does not block R), while brms/rstan runs MCMC inside the R process (blocks the session, requires `future` workaround). See `engine-decision.md` for the full analysis. This Shiny integration advantage is a key factor favoring cmdstanr for the package engine.

- **Modern UI via `bslib`**: Bootstrap 5 components (`page_sidebar()`, `card()`, `value_box()`, `accordion()`, `navset_pill()`) provide a polished, responsive dashboard without custom CSS. `shinyssdtools` already uses bslib, so this is familiar territory.

- **Deployment flexibility**:
  - **Posit Connect**: Institutional deployment with authentication, scheduled reports, and scaling. Proven for Poisson Consulting apps.
  - **shinyapps.io**: Free tier available for low-traffic apps. One-click deployment.
  - **Docker**: Self-hosted option for on-premises requirements (data sensitivity). `rocker/shiny` base image is well-maintained.
  - **Hugging Face Spaces**: Free hosting with Docker support. Emerging option for scientific apps.

- **Single codebase**: The app is an R package. All code, tests, and documentation are in one language. The developer already maintains multiple Shiny apps in this pattern.

**Visualization capabilities -- can Shiny match a JS frontend?**

A common concern is whether Shiny apps look "professional" compared to custom JS frontends with D3.js or similar libraries. In practice, modern Shiny can produce highly polished, interactive scientific visualizations:

- **plotly**: Full interactive plots (hover tooltips, zoom, pan, selection, linked brushing) via `plotly::ggplotly()` -- converts any ggplot2 figure to an interactive plot with one function call. Also supports custom plotly.js traces for more control. This covers most scientific visualization needs (scatter plots with confidence bands, site comparison forest plots, time series with uncertainty ribbons).
- **D3.js in Shiny**: Shiny supports custom D3 visualizations via `r2d3` or custom HTML widgets. If a specific visualization needs D3-level control (e.g., animated transitions, force-directed network diagrams), it can be embedded directly in a Shiny app. The `htmlwidgets` framework bridges R and JavaScript visualization libraries seamlessly.
- **Leaflet**: Interactive maps for spatial site data via `leaflet`. Relevant for displaying kelp survey sites across the coast.
- **bslib theming**: Bootstrap 5 with custom themes, brand colors, professional typography. `bslib::bs_theme()` produces apps that look indistinguishable from custom-built dashboards.
- **CSS/HTML**: Shiny apps render in a browser. Any CSS or HTML that works in a web app works in Shiny. Custom CSS can achieve any visual standard.

**What JS frameworks genuinely do better**:
- Complex animated transitions (D3 transition library)
- Highly custom, non-standard chart types
- Offline-first progressive web apps
- Mobile-native feel (gesture handling, native scroll physics)

**What Shiny does equally well**:
- Standard scientific plots with interactivity (plotly)
- Dashboards with cards, value boxes, sidebars (bslib)
- Data tables with sorting, filtering, pagination (DT)
- Maps (leaflet)
- Professional styling (Bootstrap 5 themes)
- File upload/download

For a scientific modeling application where the visualizations are primarily uncertainty plots, diagnostic plots, and site comparison figures, **Shiny + plotly + bslib can achieve the same visual quality as a JS frontend**. The places where a JS frontend would genuinely look more professional (animated transitions, custom interactive diagrams) are not central to this application's needs.

**Project-specific cons**:

- **MCMC session management**: Even with `ExtendedTask`, each user session requires an R process. If a user starts MCMC fitting and closes the browser, the background process continues but the results are lost when the session expires. This is manageable for the expected low concurrency but could be problematic if the app sees heavy use.

- **Scaling limits**: Shiny is not designed for high concurrency. Each user session consumes an R process (30-100 MB RAM). For 10+ concurrent users running MCMC, the server needs substantial memory. Mitigation: pre-fit predictions (the primary use case) are lightweight and fast.

- **Pre-fit predictions are over-served**: For users who only want pre-fit predictions (upload diameters, get biomass estimates), a full Shiny server is architectural overkill. The computation is pure matrix algebra that could run client-side.

- **No offline/mobile use**: Requires a running server. Users cannot use the app on a laptop in the field without internet access (unless running locally).

**Installation experience (for self-hosting)**:
```r
pak::pak("poissonconsulting/kelpbiomassapp")
kelpbiomassapp::run_kelp_app()
```

**Maintenance trajectory**: Shiny is actively maintained by Posit (formerly RStudio) with a large team and commercial backing. bslib is the recommended UI framework going forward. Low risk of abandonment.

**Verdict**: **Recommended**. Matches the proven Poisson Consulting pattern, single codebase, native package integration, async MCMC support, and multiple deployment options.

---

### 2. Plumber API + JavaScript frontend (React / Vue / Svelte)

**Description**: Expose the kelpbiomass package functions as REST API endpoints via Plumber, and build a separate JavaScript single-page application (SPA) for the UI.

**Project-specific pros**:

- **Separation of concerns**: The API handles computation; the frontend handles presentation. Each can be developed, tested, and deployed independently.
- **Better scaling**: Stateless API endpoints scale horizontally. Multiple frontend instances can share a pool of API workers.
- **Modern UI capabilities**: JavaScript frameworks offer richer interactivity (drag-and-drop, real-time charts, complex form validation) than Shiny's reactive model.
- **Long-running jobs natural fit**: API endpoints can accept a job, return a job ID, and let the frontend poll for completion. This is the standard pattern for async computation in web APIs and avoids Shiny's session-based model.
- **Mobile-friendly**: Modern JS frameworks produce responsive UIs that work well on tablets and phones.

**Project-specific cons**:

- **Two codebases, two languages**: The developer must maintain R (API + package) and JavaScript (frontend). This effectively doubles the maintenance burden for a solo consultant.
- **Build tooling complexity**: JavaScript frameworks require npm/yarn, webpack/vite, TypeScript configuration, and a build pipeline. This is a significant learning curve for an R-focused developer.
- **API design overhead**: Every package function that the frontend needs must be exposed as an API endpoint with input validation, error handling, and JSON serialization. Data frames, ggplot objects, and MCMC diagnostics all need custom serialization.
- **Two deployment targets**: The API server (R + Docker) and the frontend (static hosting or Node.js) must be deployed and configured separately. CORS, authentication, and routing add operational complexity.
- **State management**: The frontend must manage application state (uploaded data, model fits, results) in JavaScript. This duplicates logic that Shiny handles automatically via reactivity.
- **Claude Code for frontend**: While Claude Code can write JavaScript/TypeScript, the developer cannot validate the frontend's correctness as easily as an R Shiny app (where the output is directly viewable in an R session).

**Deployment**: Docker Compose with two containers (API + frontend). More complex than a single Shiny container.

**Maintenance trajectory**: JavaScript frameworks have high churn. React, Vue, and Svelte are all stable, but the ecosystem moves fast. A frontend built today may need significant updates in 2-3 years.

**Verdict**: **Not recommended for initial development**. The maintenance burden is too high for a solo consultant. However, the package should be designed with API-friendly function signatures (pure functions, tibble returns) so that a Plumber layer can be added later if needed (see Open Question section below).

---

### 3. Plumber API + Streamlit / Gradio (Python)

**Description**: Expose the kelpbiomass functions as a Plumber API and build the frontend using Python's Streamlit or Gradio frameworks.

**Project-specific pros**:

- **Rapid prototyping**: Streamlit and Gradio can produce functional data science UIs with minimal code. Good for quick demos and proof-of-concept.
- **Built-in data upload and display**: Both frameworks have native CSV upload, data table display, and chart rendering.

**Project-specific cons**:

- **Three languages**: R (package), R (API), Python (frontend). The worst of all worlds for maintenance.
- **Streamlit limitations**: No module system for complex multi-page apps. Limited layout customization. Reruns the entire script on each interaction (poor for stateful workflows like multi-step model fitting).
- **Gradio limitations**: Designed for ML model demos, not multi-step analytical workflows. Limited form complexity.
- **Deployment complexity**: Requires both an R runtime (for the API) and a Python runtime (for the frontend). More moving parts than any other option.
- **No precedent**: No Poisson Consulting apps use this pattern. No community examples of Streamlit + Plumber for Bayesian ecological modeling.

**Verdict**: **Not recommended**. Combines the worst aspects of multi-language maintenance with the limitations of rapid-prototyping frameworks.

---

### 4. Full Python stack (FastAPI + NumPyro + React)

**Description**: Rewrite the Bayesian models in NumPyro (Python), serve via FastAPI, and build a React frontend.

**Project-specific pros**:

- **Modern web stack**: FastAPI + React is a well-established pattern with extensive tooling, hosting options, and community support.
- **GPU acceleration**: NumPyro/JAX enables GPU-accelerated MCMC, potentially reducing fitting time from minutes to seconds.
- **Unified language (Python)**: Frontend, API, and model code all in Python (plus JSX for React).
- **Cloud deployment**: Standard cloud hosting (AWS, GCP, Azure) has first-class Python support.

**Project-specific cons**:

- **Complete rewrite**: All 5 Stan models, the prediction pipeline, data validation, plotting, and reporting must be reimplemented in Python. This is the largest engineering effort of any option.
- **Loses the R package**: The primary deliverable (an R package for ecologists) cannot use the Python code. Either maintain two implementations (R + Python) or abandon the R package.
- **Validation cost**: Every result must be cross-validated against the existing Stan results. Subtle numerical differences between Stan's and NumPyro's NUTS implementations must be characterized.
- **Target audience mismatch**: The kelpbiomass package's users are R-literate marine ecologists. A Python-only web app leaves them unable to reproduce results locally without learning Python.
- **No existing infrastructure**: Poisson Consulting has no Python web apps in production. No deployment patterns, no monitoring, no maintenance playbook.

**Verdict**: **Not recommended**. The rewrite cost is prohibitive, it abandons the R package ecosystem, and it does not serve the target audience.

---

### 5. webR (browser-side R)

**Description**: Run R directly in the browser using WebAssembly (webR). Users visit a static website and run predictions client-side with no server.

**Project-specific pros**:

- **No server needed**: For pre-fit predictions, the computation is pure matrix algebra that can run entirely in the browser. No hosting costs, no session management, no scaling concerns.
- **Static hosting**: Can be deployed on GitHub Pages, Netlify, or any static file host. Free and trivially maintainable.
- **Privacy**: User data never leaves their machine. No server means no data transmission.
- **Instant availability**: No server cold starts. The R runtime loads in 5-10 seconds, then computations are fast.

**Project-specific cons**:

- **MCMC is not feasible**: Stan/cmdstanr cannot run in WebAssembly. Custom model fitting is impossible in webR. This rules out the secondary use case entirely.
- **Package support**: webR supports many CRAN packages but has gaps, especially for packages with compiled code or system dependencies. The kelpbiomass package's dependencies (mcmcr, chk) would need to be verified.
- **Experimental**: webR is actively developed by the Posit team but is still maturing. Production use for complex applications is uncommon.
- **UI framework**: Building a rich UI around webR requires HTML/CSS/JavaScript. There is no Shiny-like reactive framework for webR (shinylive exists but is experimental and limited).
- **Initial load time**: The webR runtime is ~30 MB. First page load takes 5-15 seconds to download and initialize.

**Verdict**: **Not recommended as primary app**. However, webR is worth exploring as a **supplementary tool** for the pre-fit prediction use case after the main Shiny app is built. A lightweight "quick estimate" tool that runs entirely in the browser could complement the full-featured Shiny app.

---

### 6. Shiny for Python

**Description**: Use Posit's Shiny for Python to build the UI, calling the R package via reticulate or reimplementing models in Python.

**Project-specific pros**:

- **Familiar paradigm**: Shiny for Python uses the same reactive programming model as R Shiny. Developers who know R Shiny can adapt.
- **Python ecosystem**: Access to Python's rich web and data science libraries.

**Project-specific cons**:

- **Less mature**: Shiny for Python was released in 2022 and has a much smaller community, fewer examples, and less documentation than R Shiny.
- **reticulate bridge**: Calling the R package from Python Shiny via reticulate adds complexity, latency, and failure modes. Users would need both R and Python environments.
- **Missing features**: Shiny for Python lacks some R Shiny features (modules are simpler, fewer input widgets, limited extension ecosystem).
- **No Poisson Consulting precedent**: No existing Shiny for Python apps to reference.

**Verdict**: **Not recommended**. Adds the complexity of Python without the benefits of a pure-Python ecosystem (since the models are in R/Stan).

---

## Comparison Summary

| Criterion | Shiny + bslib | Plumber + JS | Streamlit | Full Python | webR | Shiny Python |
|-----------|:---:|:---:|:---:|:---:|:---:|:---:|
| Maintenance burden | Low | High | High | Very high | Medium | Medium |
| R package integration | Native | API bridge | API bridge | None | Partial | reticulate |
| Long-running MCMC | ExtendedTask | Natural async | Awkward | Natural async | Impossible | ExtendedTask |
| Pre-fit predictions | Fast | Fast | Fast | Fast | Fast (client) | Fast |
| UI polish | Good (bslib) | Excellent | Basic | Excellent | Basic | Good |
| Interactive viz | Good (plotly, leaflet, r2d3) | Excellent (D3, custom) | Basic (Altair) | Excellent (D3, custom) | Limited | Good (plotly) |
| Deployment options | Many | Complex | Complex | Standard | Static | Fewer |
| Offline use | Local only | No | No | No | Yes (pre-fit) | Local only |
| Proven PC pattern | Yes | No | No | No | No | No |
| **Overall fit** | **Best** | Acceptable | Poor | Poor | Supplementary | Poor |

---

## Recommendation: Shiny with bslib, Companion Package Pattern

### Architecture

Follow the `bbousuite` pattern:

```
kelpbiomass/         # Core R package (engine-decision.md)
kelpbiomassapp/      # Shiny companion package
kelpbiomassdata/     # Example/demo datasets (optional, if licensing allows)
```

The Shiny app is packaged as an R package with a single entry point:
```r
kelpbiomassapp::run_kelp_app()
```

### Module structure

| Module | Purpose | Key interactions |
|--------|---------|-----------------|
| `mod-data.R` | CSV upload, validation via `kb_check_data_*()`, data preview table, template downloads | Feeds validated data to all other modules |
| `mod-allometric.R` | Toggle pre-fit vs custom fit. Custom fit: configure priors, run MCMC via `ExtendedTask`, show convergence diagnostics | Produces a `kb_fit_allometric` or default draws object |
| `mod-density.R` | Upload density transect data, fit density model (always user-supplied, no pre-fit default) | Produces a `kb_fit_density` object |
| `mod-biomass.R` | Combine model components via `kb_predict_biomass_*()`, display estimates with CIs in `value_box()` components, site comparison plots | Main results view |
| `mod-diagnostics.R` | Trace plots, Rhat/ESS table, posterior predictive check overlays, residual plots | Accessible from any fitted model |
| `mod-results.R` | Download CSV/XLSX, generate and download PDF report, download figures as PDF/PNG | Export functionality |
| `mod-rcode.R` | Display reproducible R code that replicates the app's analysis using the kelpbiomass package | Scientific reproducibility |

### UI layout

```
+------------------------------------------------------+
|  kelpbiomass: Kelp Carbon Biomass Estimator          |
+------+-----------------------------------------------+
|      |                                                |
| Side | Main content area                              |
| bar  |                                                |
|      | [Tab: Data] [Tab: Models] [Tab: Results]       |
|Step 1|                                                |
|Upload| Card: Data Preview                             |
|Data  | +--------------------------------------------+ |
|      | | DT table with uploaded data                | |
|Step 2| +--------------------------------------------+ |
|Config|                                                |
|Models| Card: Biomass Estimates                        |
|      | +----------+ +----------+ +-----------+       |
|Step 3| | Wet      | | Dry      | | Carbon    |       |
|Run   | | 2.3      | | 0.34     | | 0.12      |       |
|      | | kg/m²    | | kg/m²    | | kg C/m²   |       |
|Step 4| +----------+ +----------+ +-----------+       |
|Down- |                                                |
|load  | Card: Site Estimates                           |
|      | +--------------------------------------------+ |
|      | | ggplot: site x biomass with CIs            | |
|      | +--------------------------------------------+ |
+------+-----------------------------------------------+
```

### MCMC handling

**Pre-fit predictions** (primary pathway):
1. User uploads CSV with diameter/density columns
2. App calls `kb_predict_biomass_carbon(new_data, ...)` using default draws
3. Results appear in < 2 seconds
4. No MCMC engine needed on the server

**Custom model fitting** (secondary pathway):
1. User uploads harvest data (diameter + weight)
2. User configures model (priors, iterations)
3. App calls `kb_fit_allometric(data, ...)` via `ExtendedTask`
4. Progress bar shows MCMC sampling progress
5. User can navigate to other tabs while fitting runs
6. On completion: convergence diagnostics displayed, fit object stored in reactive values
7. Subsequent predictions use the custom fit instead of defaults

### Technology stack

- **Shiny** >= 1.8.1 (for `ExtendedTask`)
- **bslib** >= 0.6.0 (Bootstrap 5 components)
- **DT** (interactive data tables)
- **plotly** (interactive plots, optional)
- **ggplot2** (static publication-quality plots via `kb_plot_*()`)
- **rmarkdown** (PDF report generation)
- **shinytest2** (automated testing)

---

## Open Question: Plumber API Endpoints

### The question

Should the kelpbiomass package be designed with future Plumber API exposure in mind? Should API endpoints be built now?

### Analysis

**Build API endpoints now**:
- Pros: Enables non-Shiny frontends, programmatic access for institutional users, and integration with data pipelines.
- Cons: Significant additional development and testing effort. No current demand from users. API versioning and backwards compatibility add long-term maintenance burden. Premature optimization.

**Design API-friendly, build later**:
- Pros: No extra work now. The package API already follows API-friendly conventions (pure functions, tibble returns, S3 method dispatch). Plumber endpoints can be added as thin wrappers later.
- Cons: None. This is not a commitment, just a design principle.

### Recommendation: Design API-friendly, do not build endpoints now

The kelpbiomass package's `kb_*()` functions are already API-friendly by design:
- **Pure functions**: `kb_predict_weight(new_data, fit)` takes data in, returns a tibble out. No side effects.
- **Serializable returns**: Tibbles with numeric columns serialize to JSON trivially.
- **S3 dispatch**: `kb_fit` objects could be serialized via `saveRDS`/`readRDS` for stateful API patterns.
- **Validation functions**: `kb_check_data_*()` return informative errors that can be forwarded to API clients.

A future Plumber layer would be approximately 100-200 lines of code:
```r
#* Predict weight from diameter measurements
#* @param new_data CSV data as JSON
#* @post /predict/weight
function(new_data) {
  data <- jsonlite::fromJSON(new_data)
  kb_check_data_allometric(data)
  kb_predict_weight(data)
}
```

**When to revisit**: Add Plumber endpoints when (a) an institutional user requests programmatic access, (b) a non-Shiny frontend becomes necessary, or (c) the app needs to serve as a backend for a mobile application.

---

## webR as Supplementary Tool

After the main Shiny app is built and deployed, a lightweight webR-based tool could complement it for the pre-fit prediction use case:

**Use case**: A researcher visits a static website, uploads a CSV of diameter measurements, and gets biomass estimates with uncertainty -- all running in their browser with no server.

**Architecture**:
- Static HTML/CSS/JS site hosted on GitHub Pages
- webR loads the `kelpbiomass` package (prediction-only, no cmdstanr)
- User uploads CSV, JavaScript passes data to webR
- R code runs `kb_predict_biomass_carbon(new_data)` in the browser
- Results rendered as HTML table and downloadable CSV

**Advantages over Shiny for this specific case**:
- Zero hosting cost
- No server maintenance
- User data never leaves their machine
- Works offline after initial load
- Shareable as a URL with no deployment infrastructure

**Limitations**:
- No custom model fitting (no Stan in browser)
- No convergence diagnostics (pre-fit models only)
- No PDF report generation
- Initial load time (webR runtime download)
- Package compatibility must be verified

**Recommendation**: Worth exploring as a Phase 5 addition. Do not invest in this until the main Shiny app is functional and deployed.

---

## Deployment Strategy

The client is Hakai Institute (a marine research institute on the BC coast). Development/demo deployment uses shinyapps.io; production deployment is TBD but likely institutional infrastructure.

### Two-mode deployment

The two-tier package architecture (pre-fit predictions vs. custom MCMC fitting) enables a natural two-mode deployment strategy:

**Mode 1: shinyapps.io (development, demos, pre-fit only)**
- Deploys the Shiny app with pre-fit prediction functionality only
- Custom model fitting is disabled (greyed out UI with message: "Custom model fitting requires the full deployment -- contact Hakai for access")
- No cmdstanr or CmdStan needed on the server
- Works because `kb_predict_*()` with default draws is pure R matrix algebra
- Free tier is sufficient for development and demos
- Useful for: stakeholder demos, workshops, testing the UI, sharing with collaborators

**Mode 2: Docker (production, full features)**
- Full Shiny app with both pre-fit predictions and custom MCMC fitting
- CmdStan pre-installed in the Docker image
- Pre-compiled Stan models via `instantiate` -- zero compilation at runtime
- Deployable to Hakai's infrastructure, a cloud VM, or Hugging Face Spaces
- Supports concurrent users, data privacy controls, authentication (via nginx reverse proxy)

This approach means the engine choice (cmdstanr) does not block shinyapps.io for development. The same app codebase serves both modes -- a runtime check (`cmdstanr::cmdstan_path()`) determines which features are available.

### Deployment options

| Option | Cost | Custom fitting | Auth | Data Privacy | Best for |
|--------|------|---------------|------|-------------|----------|
| **shinyapps.io** | Free-$$ | No (pre-fit only) | Basic (app-level password) | Cloud (Posit servers) | Dev, demos, workshops |
| **Docker (self-hosted)** | $ (server cost) | Yes | DIY (nginx, OAuth) | Full control | Production for Hakai |
| **Docker on cloud VM** | $-$$ (AWS/GCP/Azure) | Yes | Cloud IAM | Cloud (user-selected region) | Production if Hakai prefers cloud |
| **Posit Connect** | $$$$ | Yes | Built-in (LDAP, SAML) | On-premises possible | If Hakai has Connect license |
| **Hugging Face Spaces** | Free | Yes (Docker-based) | None | Cloud (HF servers) | Free public-facing deployment |

### Recommendation

1. **Start with shinyapps.io** for development and stakeholder demos (pre-fit predictions only).
2. **Build the Docker image** in parallel for production deployment with full features.
3. **Deploy to Hakai's infrastructure** (or a cloud VM) for production. The Docker image includes CmdStan and pre-compiled Stan models. Hakai's IT team can run it with `docker-compose up`.
4. Evaluate Hugging Face Spaces as a free public-facing option if the app should be broadly accessible.

---

## Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| **MCMC blocks UI** | Low (with ExtendedTask) | High | Use `ExtendedTask` for all fitting. Pre-fit predictions are inherently fast. Test with realistic datasets during development. |
| **Shiny session timeout during long MCMC** | Medium | Medium | Configure session timeout > max expected MCMC duration. Display estimated completion time. Allow users to download results to email (future). |
| **Concurrent users exhaust server memory** | Low | Medium | Pre-fit predictions use minimal memory. For fitting: limit concurrent MCMC jobs, queue additional requests. Monitor with Posit Connect or Docker health checks. |
| **Shiny / bslib breaking changes** | Low | Medium | Pin package versions. Use standard bslib components (not experimental features). Test with `shinytest2` to catch regressions. |
| **Users upload malformed data** | High | Low | `kb_check_data_*()` validates all uploads before processing. Display clear error messages. Provide downloadable CSV templates. |
| **PDF report generation fails** | Medium | Low | Require LaTeX/tinytex on the server. Test report generation in CI. Provide CSV download as fallback. |
| **App becomes unmaintainable** | Low | High | Single R codebase. Follow the bbousuite module pattern. Automated tests with `shinytest2`. Document module boundaries and data flow. |

---

## Phased Implementation

1. **Phase 1**: Core package with pre-fit predictions (no app, no fitting -- see `engine-decision.md`)
2. **Phase 2**: Package custom fitting via cmdstanr + `instantiate`
3. **Phase 3**: Shiny app with pre-fit prediction workflow (upload data, get estimates, download results)
4. **Phase 4**: Shiny app custom fitting workflow (`ExtendedTask`, diagnostics, R code generation)
5. **Phase 5**: Polish, deployment, documentation, and (optionally) webR supplementary tool
