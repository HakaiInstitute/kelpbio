# missing or bad survey columns error

    Code
      kb_check_data_cover_biomass_nereo(good[setdiff(names(good), "tide_height_m")])
    Condition
      Error in `kb_check_data_cover_biomass_nereo()`:
      ! `good[setdiff(names(good), "tide_height_m")]` must include 'tide_height_m'.

---

    Code
      kb_check_data_cover_biomass_nereo(bad)
    Condition
      Error in `kb_check_data_cover_biomass_nereo()`:
      ! Column `canopy_area_m2` of `bad` must not exceed plot_area_m2.
      i The canopy is the area delineated within the plot.

# a response in the survey data errors, pointing to biomass

    Code
      kb_check_data_cover_biomass_nereo(data)
    Condition
      Error in `kb_check_data_cover_biomass_nereo()`:
      ! `data` must not have the column estimate.
      i Supply the in situ biomass through `biomass`.

# bad biomass limits and repeated site-years error

    Code
      kb_check_data_cover_biomass_nereo(data, bad)
    Condition
      Error in `kb_check_data_cover_biomass_nereo()`:
      ! Column `lower` of `biomass` must not exceed estimate.

---

    Code
      kb_check_data_cover_biomass_nereo(data, rbind(good, good[1, ]))
    Condition
      Error in `kb_check_data_cover_biomass_nereo()`:
      ! `biomass` must have one row per site-year.
      i Repeated: "a:2020".

# a dry or carbon biomass prediction errors

    Code
      kb_check_data_cover_biomass_nereo(data, dry)
    Condition
      Error in `kb_check_data_cover_biomass_nereo()`:
      ! `biomass` must be wet biomass (biomass_kg_m2), not dry_biomass_kg_m2.
      i Predict it with `kb_predict_plot_biomass(measure = "wet")`.

