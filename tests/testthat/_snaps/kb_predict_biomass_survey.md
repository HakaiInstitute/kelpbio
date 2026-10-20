# census surveys sum each plant's expected weight, half for a partial plant

    Code
      p <- kb_predict_biomass_survey(weight_macro_fit, plants, survey, per_area = FALSE,
        new_levels = "average")
    Message
      i 1 survey with no size census rows has no biomass.
        Survey: "s2".

# an empty size census gives zero biomass for every survey

    Code
      p <- kb_predict_biomass_survey(weight_macro_fit, data_size_census_sim_macro[0, ],
      survey, new_levels = "average")
    Message
      i 10 surveys with no size census rows have no biomass.
        Surveys: "seal_ledge-2019-1", "mussel_point-2019-1", "mussel_point-2019-2", "seal_ledge-2020-1", "seal_ledge-2020-2", "mussel_point-2020-1", "seal_ledge-2021-1", "mussel_point-2021-1", "seal_ledge-2022-1", and "mussel_point-2022-1".

# a survey table with no rows errors

    Code
      kb_predict_biomass_survey(weight_nereo_fit, size_nereo_fit,
        data_survey_sim_nereo[0, ])
    Condition
      Error in `kb_predict_biomass_survey()`:
      ! `survey` must have at least one row.

# invalid and mismatched inputs error

    Code
      kb_predict_biomass_survey(weight_macro_fit, data_size_census_sim_macro,
        data_survey_sim_macro, n_plants = 10)
    Condition
      Error in `kb_predict_biomass_survey()`:
      ! `n_plants` applies only with a size fit.
      i With a size census, every plant's own size is used.

---

    Code
      kb_predict_biomass_survey(weight_nereo_fit, data_size_census_sim_macro,
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
      ! `size` must be a <kb_fit_size> object or a size census data frame.

# representative_site lends a fitted site's effects on both paths

    Code
      tallied("new_reef", representative_site = "nowhere")
    Condition
      Error in `kb_predict_biomass_survey()`:
      ! Invalid `representative_site` value: "nowhere".
      i Available sites: "otter_cove", "gull_rock", "cedar_bay", and "heron_reef".

# representative_site can name sites per fit on both paths

    Code
      kb_predict_biomass_survey(weight_macro_fit, plants, survey,
        representative_site = list(size = "seal_ledge"))
    Condition
      Error in `kb_predict_biomass_survey()`:
      ! `representative_site` cannot name "size" with a size census.
      i A size census has no site effects; name only "weight".

