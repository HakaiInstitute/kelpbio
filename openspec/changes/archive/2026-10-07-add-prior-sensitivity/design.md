## Context

Power-scaling sensitivity (Kallioinen et al. 2024, priorsense) perturbs the prior
and the likelihood by raising each to a power near 1 and measures how far each
parameter's posterior moves, using importance sampling on the existing draws. It
needs, per draw: the parameter values, the joint log prior density, and the
pointwise log-likelihood, with chains identified for the Pareto diagnostics.

A kelpbio fit stores extracted draws (chains preserved, chain-major), its resolved
priors in `meta`, its fitted fixed terms in `meta$terms$fixed`, and computes the
pointwise log-likelihood in R (`log_lik()`). Every prior entry is named after the
parameter it sets, so a fitted term's prior is `meta$priors[[term]]`.

The analysis project calls priorsense through `embr::sensitivity()`, which adds the
flags `weak_prior = prior < 0.1` and `strong_data = likelihood >= 0.05`, and
restricts its tables to scalar parameters with a directly placed prior.

## Goals / Non-Goals

**Goals:** one call that answers "are my estimates driven by the priors?" for any
sub-model, with flags that match the analysis project's reporting; full
priorsense functionality (plots, other diagnostics) on a fit without kelpbio
wrapping each function.

**Non-Goals:** see the proposal.

## Decisions

### The log prior covers the fitted terms' priors only

The joint log prior is the sum, per draw, of the log density of each fitted fixed
term under the prior entry of the same name, at the fit's stored hyperparameters.
The density is chosen by the prior's class (Normal, Exponential, lognormal), so a
new prior family needs one method. The standard-normal priors on the non-centred
deviates (`z_*`) are excluded: they are fixed by the parameterisation, not a choice
a user can change, and power-scaling them would attribute hierarchical shrinkage
to "the prior". brms's `lprior` makes the same choice. The renormalisation of
priors truncated at zero is constant across draws and does not affect
power-scaling, so it is omitted. Iterating over the fitted terms, not the prior
list, leaves out entries for effects the fit omitted (density, floor,
site:year).

### Register on priorsense's generic; `kb_sensitivity()` wraps it

`create_priorsense_data.kb_fit()` is registered on priorsense's generic with
delayed registration (`@exportS3Method priorsense::create_priorsense_data`), so it
activates only when priorsense is installed and kelpbio does not import it. It
builds the priorsense data object from the fitted terms' draws, the log prior, and
`log_lik()` as a draws array with the fit's chains. Every priorsense function that
accepts a priorsense data object (sensitivity, plots, sequences) then works on a
fit.

`kb_sensitivity()` calls `powerscale_sensitivity()` through that method, renames to
the package's column vocabulary, and sets the flags from the thresholds. The CJS
values are returned unrounded; priorsense's own text diagnosis column is dropped,
since the two flags carry the same information in a form the app can filter on.

Alternatives considered: a kelpbio-only implementation of power-scaling
(duplicates priorsense, diverges from the analysis numbers); exposing only the S3
method (no flags, so the app would have to re-derive them). An earlier version
stored a parameter-to-prior pairing on each fit and reported a `prior` column;
renaming the parameters to their prior entries (`rename-parameters`) made both
unnecessary.

### Names

`kb_sensitivity()` rather than `kb_prior_sensitivity()`: the `kb_prior_` prefix
belongs to the prior constructors. `likelihood_cjs` rather than the analysis
tables' `lik_cjs`, following the package's preference for unabbreviated names.
Threshold arguments are named for what they are compared with
(`prior_threshold`, `likelihood_threshold`) rather than after the embr options.

## Risks / Trade-offs

- [priorsense API changes] → priorsense stays in Suggests; tests skip when it is
  absent and pin structure, not values.
- [Test fixtures are short (2 chains x 300 draws) and may give noisy or
  Pareto-warned CJS values] → tests check columns, rows, flags against thresholds,
  and agreement with `powerscale_sensitivity()`, never CJS magnitudes.
- [Flag semantics are easy to misread: `weak_prior = TRUE` is the desirable state]
  → the roxygen `@details` states which combinations need attention.
