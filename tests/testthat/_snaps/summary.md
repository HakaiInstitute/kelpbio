# print.summary_kb_fit shows the slim header, table, and footer

    Code
      print(summary(weight_fit))
    Output
      <summary_kb_fit>
      Model:     Weight (Nereocystis luetkeana)
      Predictor: diameter_mm, reference <value> (geometric mean)
      Data:      240 observations; groups: site (4), year (4), site:year (12)
      Draws:     2 chains, 300 post-warmup draws each (thin = 5), 600 total
      Converged: FALSE
      
      # A tibble: 8 x 7
        term           estimate   lower  upper  rhat ess_bulk ess_tail
        <chr>             <dbl>   <dbl>  <dbl> <dbl>    <dbl>    <dbl>
      1 intercept <numerics>
      2 diameter_power <numerics>
      3 weight_floor <numerics>
      4 density_slope <numerics>
      5 sd_site <numerics>
      6 sd_year <numerics>
      7 sd_site_year <numerics>
      8 sd_residual <numerics>
      
      estimate: posterior point estimate; lower, upper: 95% compatibility limits.
      rhat: potential scale reduction factor (1 at convergence).
      ess_bulk, ess_tail: bulk and tail effective sample sizes.
      <n>% divergent transitions; <n>% max-treedepth; min E-BFMI <n>.

