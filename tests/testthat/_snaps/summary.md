# print.summary_kb_fit shows the slim header, table, and footer

    Code
      print(summary(weight_fit))
    Output
      <summary_kb_fit>
      Model:     Weight (Nereocystis luetkeana)
      Predictor: diameter, centered at its geometric mean, <value>
      Data:      240 observations; groups: site (4), site:year (12)
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Converged: TRUE
      
      # A tibble: 7 x 7
        term          estimate    lower  upper  rhat ess_bulk ess_tail
        <chr>            <dbl>    <dbl>  <dbl> <dbl>    <dbl>    <dbl>
      1 bWeight <numerics>
      2 bDiameter <numerics>
      3 bDiameter2 <numerics>
      4 sSite <numerics>
      5 sSiteDiameter <numerics>
      6 sSiteYear <numerics>
      7 sWeight <numerics>
      
      estimate: posterior point estimate; lower, upper: 95% compatibility limits.
      rhat: potential scale reduction factor (1 at convergence).
      ess_bulk, ess_tail: bulk and tail effective sample sizes.
      <n>% divergent transitions; <n>% max-treedepth; min E-BFMI <n>.

