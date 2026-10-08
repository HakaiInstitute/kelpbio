## Why

`representative_site` gives a new site a fitted site's site effect, but its
site:year effect followed `new_levels`. A new site predicted in a year the
representative site was surveyed therefore differed between `"average"` and
`"sample"`, and from the representative site itself, which users found
unexpected.

## What Changes

- In a fitted year, `representative_site` also gives a new or absent site the
  named sites' site:year effect for that year, averaged per draw over the named
  sites observed in that year. Only a site:year effect none of them has, such
  as in a new year, follows `new_levels`.
- Applies wherever `representative_site` is taken: the prediction verbs,
  `posterior_*()`, and the biomass compositions.

## Non-goals

- No change to how a fitted site, a new site without `representative_site`, or
  the year effect is resolved, nor to the recorded density a new site takes.
