# a missing conversion fit errors naming it

    Code
      kb_predict_plot_biomass(weight_fit, size_nereo_fit, density_nereo_fit, measure = "dry")
    Condition
      Error in `kb_predict_plot_biomass()`:
      ! `wetdry` is required for dry biomass.

# mismatched or wrong fits error

    Code
      kb_predict_plot_biomass(weight_fit, size_macro_fit, density_nereo_fit)
    Condition
      Error in `kb_predict_plot_biomass()`:
      ! The fits must be of one species.
      i `weight`, `size`, and `density` are "Nereocystis luetkeana", "Macrocystis pyrifera", and "Nereocystis luetkeana".

---

    Code
      kb_predict_plot_biomass(fit_weight_sim_nereo, size_nereo_fit, density_nereo_fit)
    Condition
      Error in `kb_predict_plot_biomass()`:
      ! The fits must have the same number of posterior draws.
      i `weight`, `size`, and `density` have 1500, 600, and 600 draws.

