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
      Family:    Student-t (df = 4) on log(weight)
      Fixed:     intercept + linear + quadratic log(diameter/d0)
      Random:    site (intercept, slope); site:year (intercept)
      Centered:  log-diameter at d0 = 38.8 (geometric mean of diameter)
      Data:      72 observations; groups: site (4), site:year (12)
      Draws:     2 chains, 300 post-warmup draws each (thin = 1), 600 total
      Converged: TRUE

# print.kb_fit shows the macro Gamma family and structure

    Code
      print(weight_macro_fit)
    Output
      <kb_fit_weight_macro>
      Model:     Weight (Macrocystis pyrifera)
      Family:    Gamma on weight
      Fixed:     intercept + linear log(fronds/f0)
      Random:    site (intercept); year (intercept); site:year (intercept)
      Centered:  log-fronds at f0 = 5.36 (geometric mean of fronds)
      Data:      72 observations; groups: site (4), year (3), site:year (12)
      Draws:     2 chains, 300 post-warmup draws each (thin = 1), 600 total
      Converged: TRUE

