# kelpbio 0.0.0.9000

- Added the *Macrocystis pyrifera* weight model: `kb_fit_weight_macro()`,
  `kb_priors_weight_macro()`, `kb_check_data_weight_macro()`, and the bundled
  `data_weight_sim_macro` / `fit_weight_sim_macro` objects. The prediction and
  summary methods dispatch on species; the *Macrocystis* model is a Gamma GLM on
  a frond-count predictor with a year main effect.
- Renamed the `diameter` argument of `kb_predict_weight_by()` to `predictor`
  (the predictor values to predict over: diameter for *Nereocystis*, fronds for
  *Macrocystis*).
- Added a `NEWS.md` file to track changes to the package.
