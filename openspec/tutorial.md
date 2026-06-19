# OpenSpec for kelpbio: AI-Driven R Package Development

**Audience:** Developer using Claude Code to build the `kelpbio` package.\
**Purpose:** Understand OpenSpec concepts and workflow before setting up specs.\
**Scope:** How OpenSpec integrates with Claude Code, how to apply it to R package development, and concrete examples drawn from `kelpbio`.

------------------------------------------------------------------------

## What OpenSpec Is

OpenSpec is a spec-driven development workflow for AI coding assistants. It solves a specific problem: when you ask an AI to build something, you and the AI often don't agree on exactly *what* to build before any code is written. OpenSpec structures that agreement.

The core idea is two directories:

```         
openspec/
├── specs/       ← source of truth: what the package currently does
└── changes/     ← proposed modifications: one folder per in-progress feature
```

**`specs/`** contains long-lived behavioral specifications, organized by domain. These accumulate over time and describe the current package.

**`changes/`** contains in-progress work. Each change has its own folder with planning artifacts. When a change is complete, its specs merge into `specs/` and the change folder moves to `changes/archive/`.

Nothing about OpenSpec is specific to web apps or TypeScript — it is a file-based, AI-agnostic contract system that works for any codebase.

------------------------------------------------------------------------

## How It Integrates With Claude Code

Running `openspec init --tools claude` installs two things into the `kelpbio` repo:

```         
.claude/
├── skills/
│   ├── openspec-propose/SKILL.md
│   ├── openspec-apply-change/SKILL.md
│   ├── openspec-sync-specs/SKILL.md
│   ├── openspec-archive-change/SKILL.md
│   └── openspec-explore/SKILL.md
└── commands/
    └── opsx/
        ├── propose.md
        ├── apply.md
        ├── sync.md
        └── archive.md
```

**Skills** (in `.claude/skills/`) are always available as context — Claude reads them automatically when they are relevant.\
**Commands** (in `.claude/commands/opsx/`) are invoked explicitly with `/opsx:propose`, `/opsx:apply`, etc.

Both are markdown files that instruct Claude how to behave. They reference the OpenSpec CLI (`openspec` binary) for state queries. Claude runs CLI commands like `openspec status --change <name> --json` to discover what artifacts exist and what is ready to create next.

**The workflow in Claude Code is entirely chat-driven.** You type `/opsx:propose add-density-model` in the chat, Claude reads the installed skill, queries the CLI for context, creates the planning artifacts, and waits. No custom tooling, no plugin to configure — just markdown files that Claude knows how to follow.

------------------------------------------------------------------------

## Installation (when you are ready to set up)

``` bash
# Install the CLI globally
npm install -g @fission-ai/openspec

# Initialise in the kelpbio repo root, targeting Claude Code
cd ~/Code/HakaiInstitute/kelpbio
openspec init --tools claude
```

During `openspec init` you will be prompted to create `openspec/config.yaml`. This is where you inject package-specific context so every artifact Claude generates knows it is working on an R package. See the Config section below.

To update skills after upgrading the CLI:

``` bash
npm update @fission-ai/openspec
openspec update
```

------------------------------------------------------------------------

## Core Concepts

### Specs

A spec describes **observable behavior** — what the function accepts, what it returns, error conditions. It does not describe implementation details.

Specs are organized by domain. For `kelpbio`, natural domains are:

```         
openspec/specs/
├── fitting/         # kb_fit_* function behavior
├── predictions/     # kb_predict_* function behavior
├── data/            # demo datasets, kb_check_* validation behavior
├── pre-fit/         # kb_default_* bundled model behavior
├── plotting/        # kb_plot_* function behavior
└── stan-engine/     # Stan model compilation and sampling behavior
```

A spec file uses Requirements and Scenarios:

``` markdown
# Fitting Specification

## Purpose
Behavior of the kb_fit_* model fitting functions.

## Requirements

### Requirement: Allometric Model Fitting
The system SHALL fit a Bayesian allometric relationship between a morphometric
predictor and plant weight using rstan::sampling().

#### Scenario: Valid data, default arguments
- GIVEN a data frame with columns diameter, plantW, and site
- WHEN kb_fit_allometric(data) is called
- THEN a kb_fit_allometric object is returned
- AND the object contains the rstan fit, the input data, and call metadata

#### Scenario: Custom priors supplied
- GIVEN prior_intercept = c(0, 3) is passed
- WHEN kb_fit_allometric(data, prior_intercept = c(0, 3)) is called
- THEN the fit uses the user-supplied prior hyperparameters
- AND the default priors are not used

#### Scenario: Invalid data
- GIVEN a data frame missing the plantW column
- WHEN kb_fit_allometric(data) is called
- THEN an informative error is raised via chk
- AND no Stan sampling is attempted
```

**What belongs in a spec:** - Function signatures (argument names and types) - Return value structure (class names, fields) - Error conditions (what triggers an error, what type) - Key behavioral constraints (default values, required vs optional arguments) - Scenarios that can be tested or explicitly verified

**What does not belong:** - Stan code internals - R implementation details (which tidyverse verb, which helper function) - File paths, class implementation

### Changes

A change is a proposed addition or modification to the package, packaged as a self-contained folder:

```         
openspec/changes/implement-weight-model/
├── proposal.md        # why and what
├── specs/
│   └── fitting/
│       └── spec.md    # delta: what is changing in the fitting spec
├── design.md          # how: Stan file structure, R wrapper design
└── tasks.md           # implementation checklist
```

Each change has:

| Artifact                 | Content                                          |
|--------------------------------------|----------------------------------|
| `proposal.md`            | Intent, scope (in/out), approach                 |
| `specs/<domain>/spec.md` | Delta spec — ADDED/MODIFIED/REMOVED requirements |
| `design.md`              | Technical approach, key decisions, file list     |
| `tasks.md`               | Checkbox implementation list                     |

### Delta Specs

The `specs/` folder inside a change is a *delta* — it describes only what is changing, not the full spec. Three sections:

``` markdown
# Delta for Fitting

## ADDED Requirements

### Requirement: Weight Model Fitting
The system SHALL fit a Bayesian weight-from-diameter allometric model
via rstan::sampling(stanmodels$weight, data = stan_data, ...).

#### Scenario: Successful fit
- GIVEN a valid allometric data frame
- WHEN kb_fit_allometric(data) is called
- THEN an object of class c("kb_fit_allometric", "kb_fit") is returned

## MODIFIED Requirements

### Requirement: ...
(Previously: ...)

## REMOVED Requirements

### Requirement: ...
(Deprecated because ...)
```

When you archive a change, ADDED requirements are appended to the main spec, MODIFIED requirements replace the existing version, and REMOVED requirements are deleted.

### Artifacts Build on Each Other

```         
proposal ──► specs ──► design ──► tasks ──► implement
```

`tasks.md` cannot be created until both `specs` and `design` exist, because tasks must be grounded in both what to build and how to build it. Claude enforces this dependency graph automatically through the CLI.

------------------------------------------------------------------------

## The Two Workflow Modes

### Core Profile (default)

The simplest path. Creates all planning artifacts in one shot:

```         
/opsx:propose ──► /opsx:apply ──► /opsx:sync ──► /opsx:archive
```

Best for: features with clear, well-understood scope.

### Expanded Workflow (optional)

Gives you explicit control over artifact creation:

```         
/opsx:new ──► /opsx:ff or /opsx:continue ──► /opsx:apply ──► /opsx:verify ──► /opsx:archive
```

Enable with:

``` bash
openspec config profile    # select expanded workflows
openspec update            # regenerate skill files
```

Use `/opsx:ff` when you know the full scope. Use `/opsx:continue` to create one artifact at a time and review each before proceeding.

------------------------------------------------------------------------

## Customizing for R Package Development

The `openspec/config.yaml` file injects context into every artifact Claude generates. For `kelpbio`:

``` yaml
# openspec/config.yaml
schema: spec-driven

context: |
  Package: kelpbio — R package for Bayesian kelp biomass estimation.
  Language: R (tidyverse style).
  Bayesian engine: rstan + rstantools. Stan models live in inst/stan/ and are
  pre-compiled at install time via rstantools::rstan_create_package(). Sampling
  uses rstan::sampling(stanmodels$<name>, data = stan_data, ...). Do not use
  cmdstanr.
  Public API prefix: kb_. All exported functions begin kb_.
  Documentation: roxygen2 with markdown. All exported arguments must be
  validated with chk. User-facing messages via cli.
  Testing: testthat 3e with snapshot testing.
  Code style: tidyverse; no lubridate, reshape2, plyr, or data.table.
  No library() calls in package code; use @importFrom or pkg::fun().
  See decisions/engine-choice.md for the Stan engine rationale.
  See openspec/specs/ for the public API (observable behaviour).

rules:
  proposal:
    - State which kb_* functions are added or changed
    - Identify which Stan files are affected (if any)
    - Note whether a new rstan::sampling() call pattern is needed
  specs:
    - Use Given/When/Then format for scenarios
    - Reference the kb_ function name in each Requirement heading
    - Describe return value class names explicitly (e.g., c("kb_fit_allometric", "kb_fit"))
  design:
    - Name the Stan file(s) involved (e.g., inst/stan/weight.stan)
    - List the R files to create or modify
    - Document any new data list structure passed to rstan::sampling()
  tasks:
    - Separate Stan work from R work into distinct sections
    - Stan tasks: write .stan file, smoke-test with rstan::stan_model() standalone
    - R tasks: write wrapper, write chk validation, write roxygen2 docs, write tests
```

**Context** is prepended to every artifact Claude writes. **Rules** are injected only for the matching artifact type.

------------------------------------------------------------------------

## Domain Structure for kelpbio

Suggested `openspec/specs/` layout based on the package design:

```         
openspec/specs/
├── fitting/
│   └── spec.md        # kb_fit_allometric, kb_fit_wetdry, kb_fit_carbon, kb_fit_density
├── predictions/
│   └── spec.md        # kb_predict_weight, kb_predict_wetdry, kb_predict_carbon,
│                      # kb_predict_density, kb_predict_biomass_*
├── data/
│   └── spec.md        # kb_data_*, kb_check_data_*, kb_priors_*
├── pre-fit/
│   └── spec.md        # kb_default_allometric, kb_default_wetdry, kb_default_carbon
├── plotting/
│   └── spec.md        # kb_plot_*
└── stan-engine/
    └── spec.md        # Stan file conventions, pre-compilation behavior, rstan::sampling contract
```

Each spec file grows organically as changes are archived. Start with empty or minimal files; they accumulate requirements over time.

------------------------------------------------------------------------

## Worked Examples

### Example 1: Setting Up the rstan Scaffold

```         
You: /opsx:propose scaffold-rstan-package

Claude creates:
  openspec/changes/scaffold-rstan-package/
  ├── proposal.md
  ├── specs/stan-engine/spec.md   ← delta adding Stan engine requirements
  ├── design.md
  └── tasks.md
```

**proposal.md** (what Claude would generate given the config):

``` markdown
# Proposal: Scaffold rstan Package

## Intent
Initialize the kelpbio package with the rstan + rstantools build system
so Stan models can be pre-compiled at install time.

## Scope
In scope:
- Run rstantools::rstan_create_package() to generate the scaffold
- Verify DESCRIPTION includes the full Stan-stack dependency set
- Confirm configure / configure.win are present and executable
- Place a placeholder weight.stan in inst/stan/ and verify it compiles

Out of scope:
- Writing any Stan model code beyond the placeholder
- Writing any R wrapper functions
```

**specs/stan-engine/spec.md** (delta):

``` markdown
# Delta for Stan Engine

## ADDED Requirements

### Requirement: Pre-Compiled Stan Models
The system SHALL pre-compile Stan models from inst/stan/ into the package
binary at R CMD INSTALL time using rstantools and rstan.

#### Scenario: Clean install
- GIVEN a machine with rstan and a C++17 toolchain installed
- WHEN devtools::install() is run
- THEN all .stan files in inst/stan/ are compiled into the package binary
- AND the compiled models are accessible via kelpbio::stanmodels$<name>

### Requirement: No Runtime Stan Toolchain
The system SHALL not require cmdstan or cmdstanr at runtime.

#### Scenario: User without cmdstan
- GIVEN a user who has never run cmdstanr::install_cmdstan()
- WHEN they install kelpbio and call kb_fit_allometric(data)
- THEN sampling proceeds without error
```

**tasks.md** (what Claude would generate):

``` markdown
# Tasks: Scaffold rstan Package

## 1. Package Skeleton
- [ ] 1.1 Run rstantools::rstan_create_package() with auto_config = TRUE
- [ ] 1.2 Verify DESCRIPTION includes: rstan, rstantools, BH, RcppEigen, RcppParallel, StanHeaders, Rcpp
- [ ] 1.3 Confirm configure and configure.win are present and executable (chmod +x configure)
- [ ] 1.4 Confirm R/stanmodels.R exists and R/kelpbio-package.R has useDynLib directives

## 2. Smoke Test
- [ ] 2.1 Write minimal placeholder inst/stan/weight.stan (intercept-only normal model)
- [ ] 2.2 Run devtools::install() and confirm no compile errors
- [ ] 2.3 Run kelpbio::stanmodels$weight to confirm model object is accessible
- [ ] 2.4 Run rstan::sampling(kelpbio::stanmodels$weight, data = list(nObs=1, y=1.0))
         as a smoke test
```

Then:

```         
You: /opsx:apply

Claude works through the task list, checking items off as it goes.

You: /opsx:archive

Claude merges the delta specs into openspec/specs/stan-engine/spec.md
and moves the change to openspec/changes/archive/2025-XX-XX-scaffold-rstan-package/
```

------------------------------------------------------------------------

### Example 2: Adding the Weight Model

```         
You: /opsx:propose implement-weight-model
```

**design.md** (what Claude would generate):

``` markdown
# Design: Weight Model

## Stan File
inst/stan/weight.stan — log-normal allometric regression:
  log(weight) ~ Normal(bIntercept + bSlope * predictor, sigma)

Prior hyperparameters passed as data (not hard-coded) so users can tune them.
Optional quadratic term controlled by a binary flag use_quadratic.

## R Wrapper
R/fit-allometric.R — kb_fit_allometric():
  - Validates data with kb_check_data_allometric(data)
  - Assembles stan_data list with observation vectors and prior hyperparameters
  - Dispatches rstan::sampling(stanmodels$weight, data = stan_data, ...)
  - Returns object of class c("kb_fit_allometric", "kb_fit")

## Data List Structure (passed to rstan::sampling)
  nObs, nsite, site (integer index), predictor, log_weight,
  use_quadratic (0/1 flag),
  prior_intercept_mu, prior_intercept_sd,
  prior_slope_mu, prior_slope_sd,
  prior_sigma_rate
```

**tasks.md**:

``` markdown
# Tasks: Weight Model

## 1. Stan Model
- [ ] 1.1 Write inst/stan/weight.stan: data, parameters, transformed parameters,
         model, generated quantities blocks
- [ ] 1.2 Standalone smoke test:
         mod <- rstan::stan_model("inst/stan/weight.stan")
         rstan::sampling(mod, data = list(...), chains = 1, iter = 100)
- [ ] 1.3 devtools::install() to compile into package binary

## 2. R Wrapper
- [ ] 2.1 Write R/fit-allometric.R: kb_fit_allometric() function
- [ ] 2.2 Add chk validation for all arguments (data columns, predictor values,
         prior vector lengths)
- [ ] 2.3 Write roxygen2 documentation with @param, @return, @examples
- [ ] 2.4 Register kb_fit_allometric S3 print method

## 3. Priors Interface
- [ ] 3.1 Write kb_priors_allometric() returning named list of defaults
- [ ] 3.2 Ensure kb_fit_allometric() uses kb_priors_allometric() defaults
         when priors = NULL

## 4. Tests
- [ ] 4.1 Write tests/testthat/test-fit-allometric.R
- [ ] 4.2 Test with kb_data_allometric (bundled demo data)
- [ ] 4.3 Snapshot test on print output of kb_fit_allometric result
```

------------------------------------------------------------------------

### Example 3: Exploratory — Before the Density Model

When the approach is not yet clear, use explore first:

```         
You: /opsx:explore

Claude: What would you like to explore?

You: For the density model, should we use a separate Stan file for the
     zero-inflated NB variant, or handle it with a flag in one file?
     The model could get complex.

Claude: Let me think through the trade-offs...

     Two Stan files (density_nb.stan, density_zinb.stan):
     + Cleaner Stan code — each file is readable without flag conditionals
     + Compile-time separation — users who never use ZINB pay no sampling cost
       for its extra parameters
     - Two files to maintain; shared logic is duplicated or requires #include

     One file with a flag (use_zinb = 0/1):
     + Single file to maintain
     - Parameters for the unused component are still sampled (small cost)
     - File becomes harder to read with flag-gated logic

     For kelpbio, the ZINB variant is likely a common user choice
     (excess zeros in stipe counts at low-density sites), so the
     unused-parameter cost is worth paying for the simpler file structure.
     The structural difference is small enough that one file with a flag
     is the right call here.

You: Agreed, one file with a flag. Let's start that change.

You: /opsx:propose implement-density-model
```

------------------------------------------------------------------------

### Example 4: Parallel Changes

Working on predictions while density is still in progress:

```         
You: /opsx:propose implement-wetdry-model

Claude creates openspec/changes/implement-wetdry-model/
(separate from implement-density-model, can work on both)

You: /opsx:apply implement-wetdry-model

... wetdry implementation complete ...

You: /opsx:archive implement-wetdry-model

You: /opsx:apply implement-density-model

... picks up density where it left off ...
```

When multiple changes are done simultaneously:

```         
You: /opsx:bulk-archive

Claude: Found 2 completed changes:
        - implement-carbon-model (all tasks done)
        - implement-wetdry-model (all tasks done)

        No spec conflicts.
        Archive both? Yes.
```

------------------------------------------------------------------------

## Command Reference for Claude Code

| Claude Code command | What it does |
|-------------------------------------------|-----------------------------|
| `/opsx:propose <name>` | Create a change and generate all planning artifacts (proposal, specs, design, tasks) in one step |
| `/opsx:explore` | Think through an approach before committing to a change |
| `/opsx:apply [name]` | Work through `tasks.md`, checking items off as each is implemented |
| `/opsx:sync [name]` | Merge delta specs into `openspec/specs/` without archiving |
| `/opsx:archive [name]` | Finalise: merge specs and move change to `changes/archive/` |

Expanded workflow (after enabling with `openspec config profile`):

| Command | What it does |
|----------------------------|-------------------------------------------|
| `/opsx:new <name>` | Create the change folder only; wait for `/opsx:ff` or `/opsx:continue` |
| `/opsx:ff [name]` | Fast-forward: create all planning artifacts at once |
| `/opsx:continue [name]` | Create the next ready artifact (one at a time) |
| `/opsx:verify [name]` | Check implementation against specs/design/tasks before archiving |
| `/opsx:bulk-archive` | Archive multiple completed changes at once |

CLI commands (terminal, not chat):

``` bash
openspec list                          # list active changes
openspec status --change <name>        # artifact completion status
openspec validate --change <name>      # structural validation
openspec show <name>                   # view change content
openspec archive <name> --yes          # archive from terminal
```

------------------------------------------------------------------------

## Tips for R Package Development with OpenSpec

**One feature, one change.** `implement-weight-model` is one change. Adding the allometric predictions later is a separate change. The archive history then records *why* each function exists, not just *what* it does.

**Stan work and R work can be separate changes.** If the Stan scaffolding is its own change (`scaffold-rstan-package`), the archive history documents when and why that decision was made, separate from the functional models.

**Specs are not documentation.** Roxygen2 documentation (`@param`, `@return`, `@examples`) lives in the R source and is generated for the user. OpenSpec specs describe behavioral contracts for development — they inform task generation and verify implementation. They serve the development process, not the end user.

**Use `/opsx:explore` before statistically complex changes.** For instance, before designing the biomass prediction pipeline (which chains allometric, wetdry, and carbon models), explore how the uncertainty propagation should work (`kb_predict_biomass_wet_samples()` vs summary-level propagation) before committing to a design.

**The `context` field in `config.yaml` is the most valuable customization.** A sentence about the rstan engine, the `kb_` prefix convention, and the tidyverse code style means every artifact Claude generates is already oriented correctly.

**`/opsx:verify` is especially useful in R package development** because the implementation surface is wide (Stan code, R wrapper, chk validation, roxygen2 docs, tests). Verify checks that all tasks are checked off and that the implementation matches the design decisions — catching cases where, for example, the Stan file was written but the R wrapper was never documented.

------------------------------------------------------------------------

## Summary of the Lifecycle

For each `kelpbio` feature, the cycle is:

1.  **Explore** (optional): `/opsx:explore` — clarify approach before creating artifacts
2.  **Propose**: `/opsx:propose <name>` — create proposal, delta specs, design, tasks
3.  **Review artifacts**: read and edit the generated files if needed before implementing
4.  **Implement**: `/opsx:apply` — Claude works through tasks.md
5.  **Verify** (optional): `/opsx:verify` — check completeness, correctness, coherence
6.  **Archive**: `/opsx:archive` — merge delta specs into main specs, move to archive

After archiving, `openspec/specs/fitting/spec.md` (for example) contains the accumulated behavioral requirements for all fitted models. Future changes that modify fitting behavior write delta specs against that accumulated source of truth.