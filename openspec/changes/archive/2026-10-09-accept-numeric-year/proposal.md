## Why

A survey year is always a number, but the fit functions, their data checks, the
cover fit's `biomass`, and `kb_predict_site_biomass()` rejected a numeric `year`,
so users had to type `year = "2020"`. Prediction `new_data` and `kb_new_data()`
already accepted one, so the same column was valid in some places and not others.
`year` is a grouping factor with a random effect, so it stays a level, but there
is no reason to make the user convert it.

## What Changes

- Every place that reads user data accepts a whole-number numeric `year`: the
  data checks and fit functions of the grouped models, cover biomass `biomass`,
  prediction `new_data`, and `kb_predict_site_biomass()` `new_data`.
- A numeric year names the level of the same digits (2020 and `"2020"` are one
  year) and is converted to a factor, levels in numeric order, on the way in. Fits
  store it as a factor, and predictions return it as one, so plots keep a
  discrete year axis.
- A year that is not a whole number errors naming the column, as does a missing
  one.

## Non-goals

- `site` stays character or factor in fitting data. Numeric site codes are not
  in scope.
- `year` does not become a continuous predictor; there is no trend term.
- `sum_by` columns other than `year` keep their character-or-factor rule.
- `kb_new_data()` keeps returning a level given in `...` as character.
