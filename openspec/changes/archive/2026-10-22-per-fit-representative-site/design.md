## Context

The two-fit derived verbs pass one `representative_site` to both the weight fit's group effects and the size fit's linear predictor, and validate it against each fit. Only the weight, size, and cover calibration fits have site effects; wet/dry and carbon do not. With a reference weight fit, the survey sites are usually new to the weight fit and fitted in the size fit, so the useful request is a representative site for the weight fit alone.

## Goals / Non-Goals

**Goals:**

- Let each fit with site effects take its own representative sites, or none.
- Keep the single-vector call for the case where both fits share sites.

**Non-Goals:**

- Per-site mapping within one call.
- Any change to the one-fit verbs, `predict()`, or `posterior_*()`.

## Decisions

### A list named by fit argument

`representative_site = list(weight = "a")` names the fits by the verb's own argument names, so the call reads as "the weight fit takes site a". Alternatives considered:

- Separate arguments (`representative_site_weight`, `representative_site_size`): two more name-only arguments on verbs that already take many, and a pattern that would grow with every fit added.
- One vector applied to whichever fits contain each name: silent when a name happens to exist in a fit the user did not mean, and an error only when a name is in no fit. Rejected as hard to explain to a client.

### Keep the character vector

A character vector still applies to every fit with site effects. When both fits come from one set of surveys this is the natural call, and it is what the one-fit verbs take, so the argument keeps one meaning across the package. Requiring the list form in the two-fit verbs was considered: more explicit, but wordier for the common own-data case.

### Validation

The list is resolved to one value per fit before any prediction, and each value goes through the existing per-fit check, so an invalid site lists that fit's sites. `size` is rejected when `size` is a size census, since a table has no site effects to stand in for.

## Risks / Trade-offs

- [The argument now takes two types] → The roxygen states both forms in one sentence each, and the error for a malformed list shows the expected form.
