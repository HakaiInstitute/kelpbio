# kb_model_describe renders the nereo notation block

    Code
      kb_model_describe(weight_fit)
    Output
      Weight allometry - Nereocystis luetkeana
      Response: wet weight; predictor: sub-bulb diameter
      
      Likelihood
        log(weight) ~ Student-t(4, mu, sWeight)
        mu = bWeight
           + bSite[site]
           + (bDiameter + bSiteDiameter[site]) * x
           + bDiameter2 * x^2
           + bSiteYear[site, year]
        x = log(diameter) - log(d0),  d0 = 43.1  (geometric mean diameter)
      
      Random effects
        bSite[site]           ~ Normal(0, sSite)          site intercept
        bSiteDiameter[site]   ~ Normal(0, sSiteDiameter)  site slope on log-diameter
        bSiteYear[site, year] ~ Normal(0, sSiteYear)      site:year intercept
      
      Priors
        bWeight        ~ Normal(0, 2)
        bDiameter      ~ Normal(2, 1)
        bDiameter2     ~ Normal(0, 0.5)
        sWeight        ~ Exponential(1)
        sSite          ~ Exponential(1)
        sSiteDiameter  ~ Exponential(1)
        sSiteYear      ~ Exponential(1)

# kb_model_describe renders the macro notation block

    Code
      kb_model_describe(weight_macro_fit)
    Output
      Weight allometry - Macrocystis pyrifera
      Response: wet weight; predictor: frond count
      
      Likelihood
        weight ~ Gamma(shape, shape / mu)
        log(mu) = bWeight
                + bFronds * x
                + bSite[site]
                + bYear[year]
                + bSiteYear[site, year]
        x = log(fronds) - log(f0),  f0 = 4.95  (geometric mean frond count)
      
      Random effects
        bSite[site]           ~ Normal(0, sSite)      site intercept
        bYear[year]           ~ Normal(0, sYear)      year intercept
        bSiteYear[site, year] ~ Normal(0, sSiteYear)  site:year intercept
      
      Priors
        bWeight        ~ Normal(0, 2)
        bFronds        ~ Normal(1, 0.5)
        shape          ~ Exponential(0.1)
        sSite          ~ Exponential(1)
        sYear          ~ Exponential(1)
        sSiteYear      ~ Exponential(1)

# kb_model_describe renders a methods paragraph with prose = TRUE

    Code
      kb_model_describe(weight_fit, prose = TRUE)
    Output
      Wet weight was modelled on the log scale with a Student-t likelihood (4
      degrees of freedom) as an allometric function of sub-bulb diameter.
      Expected log weight was a quadratic function of log diameter, centered at
      the geometric mean diameter (43.1), with the intercept and the log-diameter
      slope varying by site and the intercept additionally varying by site-year.
      Regularizing priors were placed on all parameters (see the notation form
      for the hyperparameters).

