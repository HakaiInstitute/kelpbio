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
      ! No survey in `data` has drone cover.
      i A survey has drone cover when plot_area_m2, canopy_area_m2, and canopy_tide_height_m are given.

