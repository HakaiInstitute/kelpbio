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
      <kb_fit_weight>
      Model:     weight (nereocystis)
      Family:    Student-t (df = 4); response modelled as log(weight_kg)
      Formula:   log(weight_kg) ~ 1 + log(diameter_mm/30) + log(diameter_mm/30)^2 + (1 + log(diameter_mm/30) | site) + (1 | site:year)
      Data:      300 observations; groups: site (4), site:year (12)
      Draws:     2 chains, 300 post-warmup draws each (thin = 1), 600 total
      Converged: TRUE

