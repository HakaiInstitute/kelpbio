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
      Predictor: diameter, centered at its geometric mean, 38.8
      Data:      72 observations; groups: site (4), site:year (12)
      Draws:     2 chains, 300 post-warmup draws each (thin = 1), 600 total
      Converged: TRUE
      See kb_model_describe(fit) for the model equation and priors.

# print.kb_fit shows the macro slim header

    Code
      print(weight_macro_fit)
    Output
      <kb_fit_weight_macro>
      Model:     Weight (Macrocystis pyrifera)
      Predictor: fronds, centered at its geometric mean, 5.36
      Data:      72 observations; groups: site (4), year (3), site:year (12)
      Draws:     2 chains, 300 post-warmup draws each (thin = 1), 600 total
      Converged: TRUE
      See kb_model_describe(fit) for the model equation and priors.

