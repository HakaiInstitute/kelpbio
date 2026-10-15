# a log x-axis errors over zero cover and over groups

    Code
      kb_plot_predictions(p, log_axis = "xy")
    Condition
      Error in `kb_plot_predictions()`:
      ! A log x-axis needs positive cover values.
      i Predict at positive cover values, for example with `kb_new_data()`.

---

    Code
      kb_plot_predictions(by_site, log_axis = "xy")
    Condition
      Error in `kb_plot_predictions()`:
      ! A log x-axis needs a numeric x-axis, not site.
      i Use `log_axis = "y"`.

# a log y-axis errors over non-positive values

    Code
      kb_plot_predictions(p, log_axis = "y")
    Condition
      Error in `kb_plot_predictions()`:
      ! A log y-axis needs positive estimate, lower, and upper values.
      i Use `log_axis = "none"`.

