# missing, invalid, and mismatched inputs error

    Code
      kb_predict_biomass_canopy(fit)
    Condition
      Error in `kb_predict_biomass_canopy()`:
      ! `new_data` is absent but must be supplied.

---

    Code
      kb_predict_biomass_canopy(fit, surveys(), measure = "carbon", wetdry = wetdry_nereo_fit)
    Condition
      Error in `kb_predict_biomass_canopy()`:
      ! `carbon` is required for carbon biomass.

---

    Code
      kb_predict_biomass_canopy(fit, surveys(site_area_m2 = 300))
    Condition
      Error in `kb_predict_biomass_canopy()`:
      ! Column `canopy_area_m2` of `new_data` must not exceed site_area_m2.
      i The canopy is the area mapped within the site boundary.

---

    Code
      kb_predict_biomass_canopy(fit, surveys(), pool_by = "zone")
    Condition
      Error in `kb_predict_biomass_canopy()`:
      ! `pool_by` names column zone that `new_data` does not have.

