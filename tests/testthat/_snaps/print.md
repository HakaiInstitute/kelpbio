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
      Family:    Student-t (df = 4); response modelled as log(weight)
      Formula:   log(weight) ~ 1 + log(diameter/d0) + log(diameter/d0)^2 + (1 + log(diameter/d0) | site) + (1 | site:year)
      Centered:  log-diameter at d0 = 39 (geometric mean of diameter)
      Data:      300 observations; groups: site (4), site:year (12)
      Draws:     2 chains, 300 post-warmup draws each (thin = 1), 600 total
      Converged: TRUE

