# a table with no rows errors

    Code
      kb_check_data_survey(survey()[0, ])
    Condition
      Error in `kb_check_data_survey()`:
      ! `survey()[0, ]` must have at least one row.

# a bad or contradicting date errors

    Code
      kb_check_data_survey(transform(survey(), date = "2021-08-01"))
    Condition
      Error in `kb_check_data_survey()`:
      ! Column `date` of `transform(survey(), date = "2021-08-01")` must be a <Date>.
      i Convert it with `as.Date()`, giving the `format` of the text.

---

    Code
      kb_check_data_survey(survey(year = "2020"))
    Condition
      Error in `kb_check_data_survey()`:
      ! Column `year` of `survey(year = "2020")` must be the year of date.
      i Drop year: it is taken from date.

# counts must come from one place

    Code
      kb_check_data_survey(survey(), plants())
    Condition
      Error in `kb_check_data_survey()`:
      ! `survey()` must not have a plants column when plant rows are given.
      i The counts come from the plant rows.

# repeated surveys and unmatched plants error

    Code
      kb_check_data_survey(rbind(survey(), survey()[1, ]))
    Condition
      Error in `kb_check_data_survey()`:
      ! `rbind(survey(), survey()[1, ])` must have one row per site, plot_id, and date.
      i Repeated: "a:1:2021-08-01".

---

    Code
      kb_check_data_survey(census(), p)
    Condition
      Error in `kb_check_data_survey()`:
      ! 1 plant in `p` matches no survey.
      i Plants join to their survey by site, plot_id, and date.
      i Unmatched: "a:9:2021-08-01".

# the drone columns are given together

    Code
      kb_check_data_survey(transform(survey(), tide_height_m = c(0.8, NA, NA)))
    Condition
      Error in `kb_check_data_survey()`:
      ! Column `tide_height_m` of `transform(survey(), tide_height_m = c(0.8, NA, NA))` must not be missing where the other drone columns are given.
      i Give plot_area_m2, canopy_area_m2, and tide_height_m together, or leave all three missing for a survey without drone cover.

