# kb_model_describe renders the nereo notation block

    Code
      kb_model_describe(weight_fit)
    Output
      Weight allometry - Nereocystis luetkeana
      Response: wet weight (kg); predictor: sub-bulb diameter (mm)
      
      Likelihood
        log(weight) ~ Normal(log(mu), sWeight)
        mu = bFloor + alpha * x^bPower
        log(alpha) = bWeight
                   + bYear[year]
                   + bSite[site]
                   + bSiteYear[site, year]
        x = diameter / d0,  d0 = 35.4  (geometric mean diameter)
      
      Random effects
        bYear[year]           ~ Normal(0, sYear)      year effect on log(alpha)
        bSite[site]           ~ Normal(0, sSite)      site effect on log(alpha)
        bSiteYear[site, year] ~ Normal(0, sSiteYear)  site:year effect on log(alpha)
      
      Priors
        bWeight        ~ Normal(0, 2)
        bPower         ~ Normal(2, 1) T[0, ]
        bFloor         ~ Normal(0, 0.5) T[0, ]
        sWeight        ~ Exponential(1)
        sYear          ~ Exponential(1)
        sSite          ~ Exponential(1)
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
      Wet weight was modelled on the log scale with a Normal likelihood as an
      allometric function of sub-bulb diameter. Expected weight followed a
      three-parameter power function (Packard 2008) of diameter relative to the
      geometric mean diameter (35.4), in which bFloor is the weight as diameter
      approaches zero, alpha the weight above the floor at the reference
      diameter, and bPower the allometric exponent. The log of alpha varied by
      year, by site, and by site-year. Regularizing priors were placed on all
      parameters (see the notation form for the hyperparameters).

