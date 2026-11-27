## Context

The check is for users who are not statisticians. An in-sample posterior
predictive check of a hierarchical model only catches gross misfit, which is the
aim; anything finer needs statistical interpretation.

## Decisions

### Method on bayesplot's generic, re-exported

`pp_check()` is bayesplot's S3 generic, which asks methods to return a bayesplot
`ggplot`. kelpbio registers `pp_check.kb_fit()` and re-exports the generic, with
bayesplot in Imports, as brms and rstanarm do. Alternative: keep bayesplot in
Suggests and register the method lazily; rejected because users would have to
know to load bayesplot first.

### One plot type for every model

Every model uses a density overlay (`bayesplot::ppc_dens_overlay()`), counts
included. The count responses span wide ranges (up to hundreds of stipes per
transect with most values distinct), where bar plots are unreadable, and the
analysis report uses density overlays for its count models. Alternatives: a
discrete ECDF overlay or a rootogram, exact for counts but harder for
non-statisticians to read.

### Residual overlay

The observed residuals are the posterior medians that `residuals()` reports, and
each replicate's residuals are those of the replicate under the draw that
generated it, as in the analysis report's residual overlay. Simulated residuals
share any banding that discreteness gives the observed ones, so the comparison
is fair for counts.

### 50 draws by default

Matches the analysis report's residual overlay: enough curves to show the spread
without a solid band. Draws are sampled at random, so a seed makes the plot
reproducible.
