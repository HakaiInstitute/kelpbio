# new_data must carry valid survey columns

    Code
      kb_predict_cover_biomass(cover_biomass_nereo_fit, data.frame(canopy_area_m2 = 1,
        plot_area_m2 = 2))
    Condition
      Error in `.chk_cover_survey()`:
      ! `new_data` must include 'tide_height_m'.

# kb_predict_cover_biomass errors on other models and a non-fit

    Code
      kb_predict_cover_biomass(1)
    Condition
      Error in `kb_predict_cover_biomass()`:
      ! `fit` must be a <kb_fit_cover_biomass> object.
      i Supported fits are created by the `kb_fit_cover_biomass_*()` functions.

