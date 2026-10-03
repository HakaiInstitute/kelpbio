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
      print(weight_fit)
    Output
      <kb_fit_weight_nereo>
      Model:     Weight (Nereocystis luetkeana)
      Predictor: diameter_mm, reference 35.8 (geometric mean)
      Data:      320 observations; groups: site (4), year (4), site:year (16)
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Converged: TRUE
      See kb_model_describe(fit) for the model equation and priors.

# print.kb_fit shows the macro slim header

    Code
      print(weight_macro_fit)
    Output
      <kb_fit_weight_macro>
      Model:     Weight (Macrocystis pyrifera)
      Predictor: fronds, reference 4.95 (geometric mean)
      Data:      240 observations; groups: site (4), year (3), site:year (12)
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Converged: FALSE
      See kb_model_describe(fit) for the model equation and priors.

# print.kb_fit shows the size headers without a predictor line

    Code
      print(size_nereo_fit)
    Output
      <kb_fit_size_nereo>
      Model:     Size (Nereocystis luetkeana)
      Data:      240 observations; groups: site (4), year (4), site:year (16)
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Converged: TRUE
      See kb_model_describe(fit) for the model equation and priors.

---

    Code
      print(size_macro_fit)
    Output
      <kb_fit_size_macro>
      Model:     Size (Macrocystis pyrifera)
      Data:      320 observations; groups: site (4), year (4), site:year (16)
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Converged: TRUE
      See kb_model_describe(fit) for the model equation and priors.

# print.kb_fit shows the wet/dry header without predictor or group lines

    Code
      print(wetdry_nereo_fit)
    Output
      <kb_fit_wetdry_nereo>
      Model:     Wet/dry (Nereocystis luetkeana)
      Data:      80 observations
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Converged: TRUE
      See kb_model_describe(fit) for the model equation and priors.

# print.kb_fit shows the carbon header

    Code
      print(carbon_nereo_fit)
    Output
      <kb_fit_carbon_nereo>
      Model:     Carbon (Nereocystis luetkeana)
      Data:      80 observations
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Converged: TRUE
      See kb_model_describe(fit) for the model equation and priors.

# print.kb_fit shows the density headers without a predictor line

    Code
      print(density_nereo_fit)
    Output
      <kb_fit_density_nereo>
      Model:     Density (Nereocystis luetkeana)
      Data:      64 observations; groups: site (4), year (4), site:year (16)
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Converged: TRUE
      See kb_model_describe(fit) for the model equation and priors.

---

    Code
      print(density_macro_fit)
    Output
      <kb_fit_density_macro>
      Model:     Density (Macrocystis pyrifera)
      Data:      64 observations; groups: site (4), year (4), site:year (16)
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Converged: TRUE
      See kb_model_describe(fit) for the model equation and priors.

