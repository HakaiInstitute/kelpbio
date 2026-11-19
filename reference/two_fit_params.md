# Parameter Descriptions for the Two-Fit Derived Verbs

Parameter descriptions shared by
[`kb_predict_mean_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_mean_weight.md)
and
[`kb_predict_biomass_in_situ()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_biomass_in_situ.md).

## Arguments

- representative_site:

  A character vector of sites whose effects a new site takes in every
  fit (averaged when several are named), a list naming the sites per
  fit, such as `list(weight = "site_a")`, where a fit left out follows
  `new_levels`, or `NULL` (the default) to follow `new_levels`.
