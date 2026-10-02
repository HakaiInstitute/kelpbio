# new_data must carry a valid area_m2

    Code
      kb_predict_density(density_nereo_fit, data.frame(site = "site1"))
    Condition
      Error in `.chk_new_data_density()`:
      ! `new_data` must have an area_m2 column.
      i Its rows predict the count on a transect of that area; use `kb_predict_density_by()` for density per m².

