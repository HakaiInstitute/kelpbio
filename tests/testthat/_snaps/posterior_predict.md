# cover posterior_predict needs the in situ limits in new_data

    Code
      posterior_predict(cover_biomass_nereo_fit, nd)
    Condition
      Error in `posterior_predict()`:
      ! `new_data` must have lower and upper columns.
      i They are the compatibility limits of the in situ biomass estimate, which set its precision.

