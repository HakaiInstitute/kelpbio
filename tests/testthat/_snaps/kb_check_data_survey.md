# a table with no rows errors

    Code
      kb_check_data_survey(survey()[0, ])
    Condition
      Error in `kb_check_data_survey()`:
      ! `survey()[0, ]` must have at least one row.

# year and survey_id may be numeric

    Code
      kb_check_data_survey(transform(survey(), year = 2021.5))
    Condition
      Error in `kb_check_data_survey()`:
      ! Column `year` of `transform(survey(), year = 2021.5)` must be a whole numeric vector (integer vector or double equivalent).

# counts must come from one place

    Code
      kb_check_data_survey(survey(), size_census())
    Condition
      Error in `kb_check_data_survey()`:
      ! `survey()` must not have a plants column when a size census is given.
      i The counts come from the size census rows.

# repeated survey ids and unmatched plants error

    Code
      kb_check_data_survey(rbind(survey(), survey()[1, ]))
    Condition
      Error in `kb_check_data_survey()`:
      ! Column `survey_id` of `rbind(survey(), survey()[1, ])` must identify each survey once.
      i Repeated: "s1".

---

    Code
      kb_check_data_survey(census(), p)
    Condition
      Error in `kb_check_data_survey()`:
      ! 1 plant in `p` matches no survey.
      i Plants join to their survey by survey_id.
      i Unmatched survey_id: "s9".

# the drone columns are given together

    Code
      kb_check_data_survey(transform(survey(), tide_height_m = c(0.8, NA, NA)))
    Condition
      Error in `kb_check_data_survey()`:
      ! Column `tide_height_m` of `transform(survey(), tide_height_m = c(0.8, NA, NA))` must not be missing where the other drone columns are given.
      i Give plot_area_m2, canopy_area_m2, and tide_height_m together, or leave all three missing for a survey without drone cover.

