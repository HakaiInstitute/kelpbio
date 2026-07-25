# Package index

## Fitting Models

Fit Bayesian Stan models.

- [`kb_fit_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_weight_nereo.md)
  : Fit a Nereocystis Weight Model
- [`kb_fit_progress()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_fit_progress.md)
  : Completed Fraction of a Running Fit

## Priors

Specify priors for model parameters.

- [`kb_priors_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_priors_weight_nereo.md)
  : Default Priors for the Nereocystis Weight Model
- [`kb_prior_normal()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_prior_normal.md)
  : Normal Prior
- [`kb_prior_exponential()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_prior_exponential.md)
  : Exponential Prior

## Data

Validate and explore input data.

- [`kb_check_data_weight_nereo()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_check_data_weight_nereo.md)
  : Validate Nereocystis Weight Model Data
- [`data_weight_sim_nereo`](https://hakaiinstitute.github.io/kelpbio/reference/data_weight_sim_nereo.md)
  : Simulated Nereocystis Weight Dataset
- [`fit_weight_sim_nereo`](https://hakaiinstitute.github.io/kelpbio/reference/fit_weight_sim_nereo.md)
  : Example Weight Model Fit

## Predictions and Plotting

Predict and visualise model output.

- [`kb_predict_weight()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_weight.md)
  : Predict Weight for New Data
- [`kb_predict_weight_by()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_predict_weight_by.md)
  : Predict Weight Over a Diameter Sequence by Grouping Factor
- [`kb_plot_predictions()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_plot_predictions.md)
  : Plot Model Predictions

## Model Summaries and Diagnostics

Summarise fits, extract coefficients and draws, and assess convergence.

- [`samples()`](https://hakaiinstitute.github.io/kelpbio/reference/samples.md)
  : Posterior Draws
- [`kb_stancode()`](https://hakaiinstitute.github.io/kelpbio/reference/kb_stancode.md)
  : Stan Source for a Model Fit
- [`tidy(`*`<kb_fit_weight>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/tidy.kb_fit_weight.md)
  : Tidy a Weight Model Fit
- [`coef(`*`<kb_fit>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/coef.kb_fit.md)
  : Coefficients of a Model Fit
- [`glance(`*`<kb_fit>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/glance.kb_fit.md)
  : Model Fit Diagnostic Summary
- [`summary(`*`<kb_fit>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/summary.kb_fit.md)
  : Summarise a Model Fit
- [`augment(`*`<kb_fit>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/augment.kb_fit.md)
  : Augment Model Data
- [`converged(`*`<kb_fit>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/converged.kb_fit.md)
  : Convergence of a Model Fit
- [`prior_summary(`*`<kb_fit>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/prior_summary.kb_fit.md)
  : Prior Summary
- [`log_lik(`*`<kb_fit>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/log_lik.kb_fit.md)
  : Pointwise Log-Likelihood
- [`fitted(`*`<kb_fit_weight>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/fitted.kb_fit_weight.md)
  : Fitted Weights
- [`residuals(`*`<kb_fit_weight>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/residuals.kb_fit_weight.md)
  : Deviance Residuals
- [`predict(`*`<kb_fit_weight>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/predict.kb_fit_weight.md)
  : Predict Method for a Weight Model Fit
- [`posterior_epred(`*`<kb_fit_weight>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_epred.kb_fit_weight.md)
  : Expected Weight Posterior Draws
- [`posterior_linpred(`*`<kb_fit_weight>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_linpred.kb_fit_weight.md)
  : Linear-Predictor Posterior Draws
- [`posterior_predict(`*`<kb_fit_weight>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/posterior_predict.kb_fit_weight.md)
  : Posterior-Predictive Weight Draws
- [`autoplot(`*`<kb_predictions>`*`)`](https://hakaiinstitute.github.io/kelpbio/reference/autoplot.kb_predictions.md)
  : Autoplot Method for Predictions
