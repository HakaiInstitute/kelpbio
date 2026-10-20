# a plant with no frond at 1 m errors

    Code
      kb_check_data_size_census_macro(transform(size_census(), fronds = c(0, 3)))
    Condition
      Error in `kb_check_data_size_census_macro()`:
      ! Column `fronds` of `transform(size_census(), fronds = c(0, 3))` must be at least 1.
      i The model describes plants with at least one frond reaching 1 m above the holdfast.
      i Remove plants with 0 fronds.

