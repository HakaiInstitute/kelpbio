# census surveys sum each plant's expected weight, half for a partial plant

    Code
      p <- kb_predict_biomass_survey(weight_macro_fit, plants, survey, per_area = FALSE,
        new_levels = "average")
    Message
      i 1 survey with no plant rows has no biomass.
        Survey: "seal_ledge:2:2019-08-11".

# an empty plant table gives zero biomass for every survey

    Code
      p <- kb_predict_biomass_survey(weight_macro_fit, data_plants_sim_macro[0, ],
      survey, new_levels = "average")
    Message
      i 10 surveys with no plant rows have no biomass.
        Surveys: "seal_ledge:1:2019-08-11", "mussel_point:3:2019-08-12", "mussel_point:1:2019-08-12", "seal_ledge:1:2020-08-11", "seal_ledge:2:2020-08-11", "mussel_point:1:2020-08-12", "seal_ledge:1:2021-08-11", "mussel_point:1:2021-08-12", "seal_ledge:1:2022-08-11", and "mussel_point:1:2022-08-12".

# a survey table with no rows errors

    Code
      kb_predict_biomass_survey(weight_nereo_fit, size_nereo_fit,
        data_survey_sim_nereo[0, ])
    Condition
      Error in `kb_predict_biomass_survey()`:
      ! `survey` must have at least one row.

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

---

    Code
      kb_predict_biomass_survey(weight_nereo_fit, NULL, data_survey_sim_nereo)
    Condition
      Error in `kb_predict_biomass_survey()`:
      ! `size` must be a <kb_fit_size> object or a data frame of counted plants.

# representative_site lends a fitted site's effects on both paths

    Code
      tallied("new_reef", representative_site = "nowhere")
    Condition
      Error in `kb_predict_biomass_survey()`:
      ! Invalid `representative_site` value: "nowhere".
      i Available sites: "otter_cove", "gull_rock", "cedar_bay", and "heron_reef".

