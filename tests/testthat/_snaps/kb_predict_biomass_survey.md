# census surveys sum each plant's expected weight, half for a partial plant

    Code
      p <- kb_predict_biomass_survey(weight_macro_fit, plants, survey, per_area = FALSE,
        new_levels = "average")
    Message
      i 1 survey with no plant rows has no biomass.
        Survey: "seal_ledge:2:2019-08-11".

# invalid and mismatched inputs error

    Code
      kb_predict_biomass_survey(weight_macro_fit, data_plants_sim_macro,
        data_survey_sim_macro, n_plants = 10)
    Condition
      Error in `kb_predict_biomass_survey()`:
      ! `n_plants` applies only with a size fit.
      i With a table of counted plants, every plant's own size is used.

---

    Code
      kb_predict_biomass_survey(weight_nereo_fit, data_plants_sim_macro,
        data_survey_sim_macro)
    Condition
      Error in `kb_predict_biomass_survey()`:
      ! `size` must have a diameter_mm column, the predictor of `weight`.
      i `weight` is a "Nereocystis luetkeana" weight fit.

