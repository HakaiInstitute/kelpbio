# prior print methods show family and hyperparameters

    Code
      print(kb_prior_normal(mean = 0, sd = 2))
    Output
      normal(mean = 0, sd = 2)

---

    Code
      print(kb_prior_exponential(rate = 1))
    Output
      exponential(rate = 1)

# print.kb_fit shows stable metadata

    Code
      print(weight_nereo_fit)
    Output
      <kb_fit_weight_nereo>
      Model:     Weight (Nereocystis luetkeana)
      Predictor: diameter_mm, reference <value> (geometric mean)
      Data:      320 observations; groups: site (4), year (5), site:year (16)
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Converged: <value>
      See kb_model_describe(fit) for the model equation and priors.

# print.kb_fit shows the size headers without a predictor line

    Code
      print(size_nereo_fit)
    Output
      <kb_fit_size_nereo>
      Model:     Size (Nereocystis luetkeana)
      Data:      360 observations; groups: site (4), year (5), site:year (18)
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Converged: <value>
      See kb_model_describe(fit) for the model equation and priors.

# print.kb_fit shows the wet/dry header without predictor or group lines

    Code
      print(wetdry_nereo_fit)
    Output
      <kb_fit_wetdry_nereo>
      Model:     Wet/dry (Nereocystis luetkeana)
      Data:      80 observations
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Converged: <value>
      See kb_model_describe(fit) for the model equation and priors.

# print.kb_fit notes a prior-only fit

    Code
      print(fit)
    Output
      <kb_fit_wetdry_nereo>
      Model:     Wet/dry (Nereocystis luetkeana)
      Data:      80 observations
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Note:      prior-only fit (likelihood off)
      Converged: <value>
      See kb_model_describe(fit) for the model equation and priors.

