# new_data must carry valid survey columns

    Code
      kb_predict_cover_calibration(cover_calibration_nereo_fit, data.frame(
        canopy_area_m2 = 1, plot_area_m2 = 2))
    Condition
      Error in `kb_predict_cover_calibration()`:
      ! `new_data` must include 'tide_height_m'.

# kb_predict_cover_calibration errors on other models and a non-fit

    Code
      kb_predict_cover_calibration(1)
    Condition
      Error in `kb_predict_cover_calibration()`:
      ! `fit` must be a <kb_fit_cover_calibration> object.
      i Supported fits are created by the `kb_fit_cover_calibration_*()` functions.

