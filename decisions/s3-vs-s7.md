# S3 vs S7 for kelpbio

**Question:** Which OOP system should `kelpbio` use for its `kb_fit` class hierarchy?\
**Conclusion up front:** S3. Detailed reasoning follows.

------------------------------------------------------------------------

## What the Package Needs from an OOP System

The `kb_fit` objects in `kelpbio` are containers. Each wraps:

- An `rstan` fit (a `stanfit` S4 object)
- The input data passed to the model
- Call metadata (species, family, priors used, etc.)

The class hierarchy is shallow: a model-specific subclass inherits from a common parent.

```         
kb_fit_allometric ─┐
kb_fit_wetdry      ├─► kb_fit
kb_fit_carbon      │
kb_fit_density     ─┘
```

Methods needed:

| Generic     | Source              |
|-------------|---------------------|
| `print`     | base R              |
| `tidy`      | generics / broom    |
| `glance`    | generics / broom    |
| `coef`      | base R              |
| `augment`   | generics / broom    |
| `converged` | universals / custom |
| `samples`   | custom              |

The method dispatch problem is not complex. The main question is what overhead, dependencies, and conventions come with each system.

------------------------------------------------------------------------

## S3

### How it looks in kelpbio

Following the bboutools pattern exactly (`class(fit) <- c("bboufit_survival", "bboufit")`):

``` r
# Constructor (internal)
new_kb_fit_allometric <- function(stanfit, data, meta) {
  fit <- list(
    fit  = stanfit,
    data = data,
    meta = meta
  )
  class(fit) <- c("kb_fit_allometric", "kb_fit")
  fit
}

# S3 methods
print.kb_fit <- function(x, ...) {
  cli::cli_h1("kb_fit")
  cli::cli_text("Model: {x$meta$model}")
  cli::cli_text("Species: {x$meta$species}")
  invisible(x)
}

augment.kb_fit <- function(x, ...) {
  chk::chk_unused(...)
  x$data
}

tidy.kb_fit_allometric <- function(x, conf_level = 0.95, ...) {
  chk::chk_unused(...)
  # extract posterior summaries from x$fit
}

converged.kb_fit <- function(x, ...) {
  chk::chk_unused(...)
  all(rstan::summary(x$fit)$summary[, "Rhat"] < 1.05)
}
```

Subclass methods automatically fall back to the parent when not defined:

``` r
# augment.kb_fit handles all subclasses unless overridden
augment(fit_allometric)  # dispatches to augment.kb_fit
augment(fit_density)     # dispatches to augment.kb_fit
```

### What S3 gives you

- Zero additional dependencies
- Direct bboutools precedent — the pattern is `class(fit) <- c("bboufit_survival", "bboufit")`
- Seamless integration with `generics` and `broom` — tidy/glance/augment are S3 generics
- `$` access to list elements (`x$fit`, `x$data`, `x$meta`) is consistent with bboutools
- `inherits(x, "kb_fit")` works for all subclasses
- Full compatibility with `universals::converged()` and similar S3-based generic ecosystems
- No friction wrapping rstan's S4 `stanfit` objects — they sit inside the list untouched

### What S3 does not give you

- No formal slot typing — nothing prevents `x$data <- "oops"` after construction
- No built-in validators — you cannot declare "the `fit` slot must be a `stanfit`"
- No formal constructor schema — the structure is implicit, not declared

These are real gaps, but they matter less when: 1. Objects are returned only from `kb_fit_*()` functions, never assembled by users 2. Input validation is done by `kb_check_data_*()` before the object is created 3. The codebase is small enough that informal convention holds

------------------------------------------------------------------------

## S7

S7 (formerly R7) is a new formal OOP system developed by the R Consortium OOP Working Group, available via `install.packages("S7")`. It sits between S3 (informal) and S4 (formal but complex). Released to CRAN in late 2023.

### How it looks in kelpbio

``` r
library(S7)

kb_fit <- new_class(
  "kb_fit",
  properties = list(
    fit  = class_any,   # stanfit is S4; S7 cannot type-check S4 classes natively
    data = class_data.frame,
    meta = class_list
  )
)

kb_fit_allometric <- new_class(
  "kb_fit_allometric",
  parent = kb_fit
)

# Instantiation
fit <- kb_fit_allometric(
  fit  = stanfit_object,
  data = input_data,
  meta = list(model = "allometric", species = "nereocystis")
)

# Property access uses @
fit@meta$species

# Method registration
method(print, kb_fit) <- function(x, ...) {
  cli::cli_h1("kb_fit")
  cli::cli_text("Model: {x@meta$model}")
  invisible(x)
}

# For S3 generics (tidy, glance, augment), S7 objects dispatch via S3
# You still define the S3 method, just with @ instead of $
augment.kb_fit <- function(x, ...) {
  x@data
}
```

### What S7 gives you over S3

**Formal property validation.** You can enforce slot types at construction time:

``` r
kb_fit <- new_class(
  "kb_fit",
  properties = list(
    data = new_property(
      class = class_data.frame,
      validator = function(value) {
        if (nrow(value) == 0) "data must have at least one row"
      }
    )
  )
)
```

**Cleaner inheritance declaration.** `parent = kb_fit` is explicit. S3's `c("kb_fit_allometric", "kb_fit")` is a convention; S7's parent is enforced.

**Better error messages on method dispatch failure.** S7 tells you exactly what class was dispatched and why no method matched.

**Formal introspection.** `S7_class(x)`, `S7_inherits(x, kb_fit)`, and `S7_methods(kb_fit)` expose the class system to inspection.

### What S7 costs in this context

**An additional dependency.** `kelpbio` already has a complex install path — Stan model compilation takes 10 to 20 minutes on first install and requires a C++17 toolchain. Adding `S7` to `Imports` is a small but real increase in surface area for install failures, especially since `S7` is young and infrequently battle-tested in packages that already have non-standard build systems.

**No direct S4 interoperability.** rstan's `stanfit` is an S4 object. S7 cannot natively type-check S4 classes in property definitions without wrapping:

``` r
# This does not work as expected:
properties = list(fit = methods::is("stanfit"))

# Workaround: use class_any and validate manually
properties = list(
  fit = new_property(
    class = class_any,
    validator = function(value) {
      if (!methods::is(value, "stanfit")) "fit must be a stanfit object"
    }
  )
)
```

This is verbose and loses the declarative benefit S7 offers.

**broom generics are S3.** `tidy`, `glance`, and `augment` from the `generics` package are S3 generics. S7 objects participate in S3 dispatch, but the method registration is still `tidy.kb_fit_allometric <- function(x, ...) { ... }` — the same as pure S3. S7's `method()` registration syntax is unused for these generics.

**`@` vs `$` access breaks bboutools convention.** bboutools accesses stored data as `x$data`, `x$mcmc`, etc. S7 properties use `x@data`. Mixing the two conventions in closely related packages adds cognitive friction. Users moving between `bboutools` and `kelpbio` see different access patterns for structurally equivalent objects.

**Community familiarity.** S7 was released in 2023 and is not yet widely used in statistical R packages. S3 is understood by every R developer. When a contributor encounters `augment.kb_fit <- function(x, ...) { x$data }` they immediately understand it. S7 syntax requires knowing the package.

**More boilerplate for shallow hierarchies.** The depth of the `kb_fit` hierarchy is one level. S7's formal inheritance machinery provides diminishing returns for a hierarchy this shallow.

------------------------------------------------------------------------

## Side-by-Side Comparison

| Criterion | S3 | S7 |
|---------------------------------------|-----------------|-----------------|
| Dependencies | None | `S7` package |
| bboutools precedent | Exact match | Diverges |
| rstan (S4) interop | Transparent (stored in list) | Awkward (no native S4 typing) |
| broom generics | Native | Still use S3 dispatch |
| `$` vs `@` access | `$` (matches bboutools) | `@` (different convention) |
| Formal slot validation | No | Yes |
| Inheritance declaration | Implicit (`class()` vector) | Explicit (`parent =`) |
| Error messages | Generic | Informative |
| Community familiarity | Universal | Low (new system) |
| Boilerplate for 2-level hierarchy | Minimal | Moderate |
| Install complexity | None | Minor (one more CRAN package) |

------------------------------------------------------------------------

## Recommendation: S3

For `kelpbio`, S3 is the right choice. The reasons:

1.  **The validation problem is solved elsewhere.** `kb_check_data_*()` validates inputs before fitting. `kb_fit_*()` functions are the only constructors — users never build `kb_fit` objects by hand. The primary safety risk S7 addresses does not arise here.

2.  **bboutools is the reference.** The package explicitly follows bboutools conventions. bboutools uses `class(fit) <- c("bboufit_survival", "bboufit")`. Diverging from this without a clear benefit imposes ongoing maintenance and cognitive overhead.

3.  **The class hierarchy is shallow.** Four subclasses, one parent, well-defined method set. There is no complex dispatch problem that S7 solves better.

4.  **rstan's S4 types do not compose well with S7.** The core stored object (`stanfit`) is S4. S7 cannot type-check S4 classes declaratively. The main validator benefit disappears for the most important slot.

5.  **broom and generics are S3-based.** The method surface for `tidy`, `glance`, and `augment` is S3 regardless of which system owns the class definition. Choosing S7 does not simplify the method registration; it only changes property access syntax.

The case for S7 would strengthen if: the class hierarchy grew to three or more levels; multiple packages needed to extend `kb_fit` formally; or rstan's S4 objects were replaced by an S7-compatible backend.

------------------------------------------------------------------------

## Implementation Pattern

Following bboutools directly:

``` r
# R/fit-allometric.R

new_kb_fit_allometric <- function(stanfit, data, meta) {
  fit <- list(
    fit  = stanfit,
    data = data,
    meta = meta
  )
  class(fit) <- c("kb_fit_allometric", "kb_fit")
  fit
}

kb_fit_allometric <- function(data, species = "nereocystis",
                               predictor = "Sbulb_max",
                               priors = NULL, nthin = 10L, ...) {
  kb_check_data_allometric(data)
  priors <- priors %||% kb_priors_allometric(predictor, species)
  stan_data <- assemble_stan_data_allometric(data, predictor, priors)
  stanfit <- rstan::sampling(stanmodels$weight, data = stan_data,
                              chains = 4, thin = nthin, ...)
  new_kb_fit_allometric(
    stanfit = stanfit,
    data    = data,
    meta    = list(species = species, predictor = predictor, priors = priors)
  )
}

# R/print.R
#' @export
print.kb_fit <- function(x, ...) {
  cli::cli_h1("kb_fit")
  cli::cli_text("Model:   {x$meta$model}")
  cli::cli_text("Species: {x$meta$species}")
  invisible(x)
}

# R/augment.R
#' @export
generics::augment

#' @export
augment.kb_fit <- function(x, ...) {
  chk::chk_unused(...)
  x$data
}

# R/tidy.R
#' @export
generics::tidy

#' @export
tidy.kb_fit_allometric <- function(x, conf_level = 0.95, ...) {
  chk::chk_number(conf_level)
  chk::chk_range(conf_level, c(0, 1))
  chk::chk_unused(...)
  # extract from x$fit (stanfit)
}
```

This is the full pattern. No extra dependencies, no unfamiliar syntax, consistent with every analogous Poisson Consulting package.