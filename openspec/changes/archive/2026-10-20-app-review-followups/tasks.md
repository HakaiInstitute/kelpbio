## 1. Plots

- [x] 1.1 `kb_plot_trace()`: build the figure from the fit's draws with ggplot2 (`ncol` facet columns, default 2, free y, chain colours, "Chain" legend, "Iteration", no theme)
- [x] 1.2 `kb_plot_predictions()`: plain-number tick labels on linear numeric axes
- [x] 1.3 Tests for both

## 2. Informative priors

- [x] 2.1 Record `informative_priors = "tide_height_slope"` in the cover calibration fits' `meta_extra`
- [x] 2.2 `kb_sensitivity()`: `informative_prior` column from the fit's record (none when absent); document which parameters and why
- [x] 2.3 Tests
- [x] 2.4 `devtools::install()`, then refit the cover calibration pre-fits and fixtures (`--fits=cover_calibration`)

## 3. Documentation

- [x] 3.1 roxygen, `devtools::document()`
- [x] 3.2 Check the specs and reader docs against the code; archive the change
