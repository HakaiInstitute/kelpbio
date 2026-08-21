# Design

## Proof that it is a pure refactor

The public methods moved class, five internal generics were renamed, `.deviance`
changed orientation and lost its internal reduction, and three bodies swapped
`exp()` for a generic. None of that should change a number. Verified against the
pre-refactor code (the installed package predates this branch), on both fixtures,
at `tolerance = 0`:

| quantity | nereo | macro |
|---|---|---|
| `fitted` | identical | identical |
| `residuals` | identical | identical |
| `log_lik` | identical | identical |
| `posterior_epred` | identical | identical |
| `posterior_linpred` | identical | identical |
| `posterior_linpred(transform = TRUE)` | identical | identical |
| `tidy` | identical | identical |

`residuals` is the one worth noting: its internal generic now returns `D x N` instead of
`N x D` and the median moved out to the method, so identity there is a real check
rather than a tautology.

## Two things the implementation found that the plan had wrong

**Attribution via `caller_env()` does not work.** The plan had each internal generic's
`.default` pass `call = rlang::caller_env()`, on the
reasoning that `UseMethod()` pushes no frame so the caller is the public method.
It is not: an internal generic is reached through a shared entry point, so
`.linpred.default`'s caller is `.linpred_obs()`, and the error would have been
attributed to an internal dotted name. The defaults now pass `call = NULL`, making
the error unattributed and the message self-contained.

**`fitted()` reports `.epred`, not `.linpred`.** `fitted.kb_fit` is
`median(.epred(object, .linpred_obs(object)))`. R dispatches the outer call before
forcing its arguments, so on a fit with no methods `.epred.default` fires before
`.linpred_obs()` is ever evaluated. Both are missing, so either message is
correct, but the test had to match reality.

## `.epred` and the expectation flag

```r
.epred(fit, lp, expectation = TRUE)
```

`expectation = TRUE` is the response mean; `FALSE` is the inverse link. They
differ only for a mixture likelihood (a zero-inflated model's mean is
`(1 - p) * invlink(lp)`), so for both weight models one body serves both and
ignores the flag. `posterior_epred()` and `fitted()` take the expectation;
`posterior_linpred(transform = TRUE)` takes the inverse link, which is what
`rstantools` contractually defines it to be.

Registered at the model tier (`.epred.kb_fit_weight`), since the link does not
vary by species. That makes it the first working example of the middle tier, which
wetdry and carbon will use throughout.

Chosen over two generics (`.invlink` plus `.epred`) because two would mean 12
method registrations across six sub-models, 10 of them identical pairs. The flag
puts the obligation in the signature the author is already writing: a zero-inflated
model that ignored `expectation` is a visible omission, whereas a missing
`.invlink` method would be an invisible one.

**Write these with arithmetic, not `stats` transforms.** `1 / (1 + exp(-lp))`, not
`plogis(lp)`: `/`, `+`, `-` and `exp` are `Ops`/`Math` group generics, so that form
works unchanged on a `posterior::rvar` and on a plain matrix, agreeing with
`plogis()` exactly. `plogis(rvar)` errors ("Non-numeric argument to mathematical
function"). This is why `fitted.kb_fit` can keep passing an rvar straight through.
A link with no arithmetic form (probit's `pnorm`) would need `posterior::rfun()`,
which loops over draws; none of the six sub-models needs it.

## Why the defaults are terminal

Before the lift, `residuals(some_non_weight_fit)` failed at *dispatch*. After it,
the call enters `residuals.kb_fit`, passes `.chk_kb_fit`, and reaches an internal generic. If
that generic had a total default returning something plausible, a sub-model added
without its methods would compute a wrong number silently. So every default
aborts.

The message says only what the caller can see: the object's class, and the
`kb_fit_*()` name pattern. One internal generic serves several verbs, so naming it
or the quantity it produces would tell a caller of `residuals()` that there is no
"linear predictor", leaving them unable to tell whether they made a mistake. Nor do
the constructors carrying one of its methods delimit which fits the package
supports: a missing `.linpred` on a size fit would be answered with the two weight
constructors. Enumerating is right only for a model-named public generic, where
`kb_predict_weight()` genuinely works on the two weight fits alone.
`.abort_no_method()` takes `generic = NULL` for the internal form, which selects
both behaviours at once.

Naming the verb the user called was tried two ways, and neither earns its cost:
threading `call` down needs a `call` argument in every `.linpred` method, twelve of
them once the sub-models land, and recovering it by scanning `sys.frames()` for the
nearest `.Generic` needs a stack-walking helper on the abort path. Both work. The
class and the name pattern already tell the reader what to do.

A latent bug in `R/abort.R` surfaced on the way: `.fit_constructors()` built its
prefix as `paste0("^", generic, "[.]")`, leaving a leading `.` unescaped, so
`"^.log_lik[.]"` would also match `xlog_lik.foo`. It now matches with
`startsWith()` instead of a regex.

## The silent-zero guard

`.linpred_obs()` called `.linpred(fit, fit$data, new_levels = "average")` with the
comment "every observed row is a known level". That was unchecked, and
`resolve_re1()`/`resolve_re2()` zero an unmatched level under `"average"`. So a fit
whose stored data lost its `site` column, or whose values failed
`match(as.character(grid$site), fit$meta$site_levels)`, would have produced
`fitted()`, `residuals()`, `augment()` and `log_lik()` computed with every random
effect at zero, with no error and `loo()` output that looked plausible.
`.chk_observed_levels()` now asserts it, on both the `.linpred_obs` and
`data_linpred(new_data = NULL)` paths.

## Contract normalisation

Done now because a pure rename would have baked the inconsistencies into an API
five more sub-models copy:

- **First argument `fit`** throughout, replacing a mix of `fit`, `object` and `x`.
  All call sites were positional, so the change is invisible.
- **`.deviance` returns `D x N`**, matching `.log_lik`, with the median moved to
  `residuals()`. Previously one returned unreduced `D x N` and its neighbour
  reduced `N x D` internally: two orientations and two reduction conventions
  across two adjacent generics, which would have been replicated twelve times.
- **`.add_noise` loses `grid`**, unused by both methods.

## File layout

Methods group by the generic they implement, with the internal generic beside the
public one it serves. That is CLAUDE.md's existing rule, and what ssdtools does
(`R/tidy.R` holds `tidy.tmbfit` *and* `tidy.fitdists`; `.glance_tmbfit` sits in
`glance.R`). ssdtools' per-distribution files are not a counter-example: those
distributions are not S3 classes, so `gamma.R` holds plain functions found by name
construction, not methods.

kelpbio already followed this for four of the five internal generics. Only
`.linpred` was misplaced, split across `R/weight_nereo_linpred.R` and
`R/weight_macro_linpred.R`, so only it moves, into `R/linpred.R`, with the shared
entry points `.linpred_obs` and `data_linpred`. `.epred` gets `R/epred.R` because it
serves three public generics rather than one, and the random-effect resolvers get
`R/re_resolve.R` because they are plain functions, not methods. The curve helpers
those two deleted files also held move in with `kb_predict_weight_by()`, their only
consumer.

The cost this accepts: adding a sub-model edits six shared files rather than
creating its own. Six short method additions is a smaller price than departing from
the convention. An earlier draft of this change grouped by fit class instead, on a
false analogy to ssdtools, and reorganised six things that were already right to fix
the one that wasn't.

## Deferred

`resolve_re1`/`resolve_re2`/`re_draw` are now model-agnostic infrastructure serving
every fit class, and they encode assumptions worth stating: the random effects are
independent, mean-zero, Gaussian and additive on the link scale. `"average"`
therefore means zeroing the effect, which is the *median* group under a
non-identity link, not the mean over the random-effect distribution.
`resolve_re1` is called separately for `bSite` and `bSiteDiameter`, which is
correct only because the Stan model estimates them independently; a future
correlated intercept-slope pair would get independently drawn marginals and a
too-narrow interval, silently.
