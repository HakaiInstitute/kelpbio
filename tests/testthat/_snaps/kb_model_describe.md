# kb_model_describe renders the nereo notation block

    Code
      kb_model_describe(weight_fit)
    Output
      Weight allometry - Nereocystis luetkeana
      Response: wet weight; predictor: sub-bulb diameter
      
      Likelihood
        log(weight) ~ Student-t(bNu, mu, sWeight)
        mu = bWeight
           + bYear[year]
           + bSite[site]
           + log(bFloor + (1 - bFloor) * x^power[site])
           + bSiteYear[site, year]
        x = diameter / d0,  d0 = 43.1  (geometric mean diameter)
        power[site] = bPower * exp(bSitePower[site])
      
      Random effects
        bYear[year]           ~ Normal(0, sYear)       year intercept
        bSite[site]           ~ Normal(0, sSite)       site intercept
        bSitePower[site]      ~ Normal(0, sSitePower)  site exponent multiplier (log scale)
        bSiteYear[site, year] ~ Normal(0, sSiteYear)   site:year intercept
      
      Priors
        bWeight        ~ Normal(0, 2)
        bPower         ~ Normal(2, 1)
        bFloor         ~ Beta(1, 5)
        bNu            ~ Gamma(2, 0.1)
        sWeight        ~ Exponential(1)
        sYear          ~ Exponential(1)
        sSite          ~ Exponential(1)
        sSitePower     ~ Exponential(1)
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
      Wet weight was modelled on the log scale with a Student-t likelihood, with
      the degrees of freedom estimated, as an allometric function of sub-bulb
      diameter. Expected weight followed a three-parameter power function
      (Packard 2012) of diameter relative to the geometric mean diameter (43.1),
      in which bFloor is the share of expected weight at that reference diameter
      that does not vary with size. The allometric exponent varied by site on the
      log scale, so it remained positive and expected weight increased
      monotonically with diameter within every site. The intercept varied by
      year, by site, and by site-year. Regularizing priors were placed on all
      parameters (see the notation form for the hyperparameters).

