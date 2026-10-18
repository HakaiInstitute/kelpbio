# survey_calibration_rows keeps covered rows as their mean and SD

    Code
      rows <- survey_calibration_rows(data)
    Message
      i 1 survey without drone cover is not fitted.

# calibration data without drone cover errors

    Code
      kb_fit_cover_calibration_nereo(data, progress = "none")
    Condition
      Error in `kb_fit_cover_calibration_nereo()`:
      ! Column `plot_area_m2` of `data` must be numeric.

