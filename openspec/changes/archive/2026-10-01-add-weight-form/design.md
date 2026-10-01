## Context

The Packard mean is `bFloor + alpha * x^bPower` with `log(alpha)` carrying the
intercept, random effects, and density. Setting `bFloor = 0` gives the power law
`log(eWeight) = log(alpha) + bPower * log(x)`, the analysis project's "linear
log-log" form with the full random-effect structure.

## Decisions

### A string argument, not a flag

`form = c("packard_floor", "power")`, matched with `rlang::arg_match()`. A later form
(for example a quadratic in log diameter) adds a value without changing the
signature. Alternative: `floor = TRUE`. Rejected because it cannot express a
third form.

`form` specifies the model, as `priors` does, so it is a descriptor before
`...`: `kb_fit_weight_nereo(data, priors, form, ...)`. It follows `priors` so
that `priors` stays the second argument of every fit function. It is validated
before sampling.

### One Stan model with a structural flag

The power law is the Packard model with the floor removed, so it keeps
`weight_nereo.stan` and gains a 0/1 data flag `floor_on` that multiplies
`bFloor`, as `site_year_on` and `density_on` do. The R layer sets the flag from
`form`. `bFloor` is still sampled from its prior when the flag is off; it is left
out of the terms, so it is never reported, and the R mean drops it. This follows
the rule that a separate `.stan` is reserved for a different likelihood or a
major variant (`decisions/species-as-variant.md`). Alternative: a second Stan
file per form. Rejected for a one-term difference; a later form with different
parameters can take its own file.

### The form is stored in meta

`meta$form` records the fitted form. `.linpred.kb_fit_weight_nereo` and the
model description read it, as they read `meta$density_on`. Alternative: a
subclass per form. Rejected because the methods differ only in one term, and
the class tier is reserved for model and species (`decisions/architecture.md`,
"Meta Versus Dispatch").

### Priors are shared

Both forms take `kb_priors_weight_nereo()`. The `power` prior, `Normal(2, 1)`,
matches the analysis power-law prior; under `"power"` the `floor` entry is
unused. Alternative: a prior function per form. Rejected because the entries are
otherwise identical and a user switching forms should not have to rebuild the
list.
