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
                   + bDensity * density
                   + bYear[year]
                   + bSite[site]
                   + bSiteYear[site, year]
        x = diameter / d0,  d0 = 35.8  (geometric mean diameter)
        density = (stipe density - 4.23) / 1.84  (standardised site-year density)
      
      Random effects
        bYear[year]           ~ Normal(0, sYear)      year effect on log(alpha)
        bSite[site]           ~ Normal(0, sSite)      site effect on log(alpha)
        bSiteYear[site, year] ~ Normal(0, sSiteYear)  site:year effect on log(alpha)
      
      Priors
        bWeight        ~ Normal(0, 2)
        bPower         ~ Normal(2, 1) T[0, ]
        bFloor         ~ Normal(0, 0.5) T[0, ]
        bDensity       ~ Normal(0, 0.5)
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
        weight ~ Gamma(bShape, bShape / mu)
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
        bShape         ~ Exponential(0.1)
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
      geometric mean diameter (35.8), in which bFloor is the weight as diameter
      approaches zero, alpha the weight above the floor at the reference
      diameter, and bPower the allometric exponent. The log of alpha varied by
      year, by site, and by site-year. The log of alpha also varied linearly with
      site-year stipe density, standardised by its mean (4.23) and standard
      deviation (1.84). Regularizing priors were placed on all parameters (see
      the notation form for the hyperparameters).

# kb_model_describe renders the size notation blocks

    Code
      kb_model_describe(size_nereo_fit)
    Output
      Size distribution - Nereocystis luetkeana
      Response: maximum sub-bulb diameter (mm)
      
      Likelihood
        diameter ~ Weibull(bShape, mu / gamma(1 + 1 / bShape))
        log(mu) = bDiameter
                + bSite[site]
                + bYear[year]
                + bSiteYear[site, year]
      
      Random effects
        bSite[site]           ~ Normal(0, sSite)      site effect on log(mu)
        bYear[year]           ~ Normal(0, sYear)      year effect on log(mu)
        bSiteYear[site, year] ~ Normal(0, sSiteYear)  site:year effect on log(mu)
      
      Priors
        bDiameter      ~ Normal(0, 2)
        bShape         ~ Exponential(0.1)
        sSite          ~ Exponential(1)
        sYear          ~ Exponential(1)
        sSiteYear      ~ Exponential(1)

---

    Code
      kb_model_describe(size_macro_fit)
    Output
      Size distribution - Macrocystis pyrifera
      Response: fronds reaching 1 m above the holdfast
      
      Likelihood
        fronds ~ NegBinomial(mu, 1 / bDispersion) T[1, ]
        E[fronds] = mu / (1 - P(fronds = 0))
        log(mu) = bFronds
                + bSite[site]
                + bYear[year]
                + bSiteYear[site, year]
      
      Random effects
        bSite[site]           ~ Normal(0, sSite)      site effect on log(mu)
        bYear[year]           ~ Normal(0, sYear)      year effect on log(mu)
        bSiteYear[site, year] ~ Normal(0, sSiteYear)  site:year effect on log(mu)
      
      Priors
        bFronds        ~ Normal(0, 2)
        bDispersion    ~ Exponential(1)
        sSite          ~ Exponential(1)
        sYear          ~ Exponential(1)
        sSiteYear      ~ Exponential(1)

---

    Code
      kb_model_describe(size_macro_fit, prose = TRUE)
    Output
      The number of fronds reaching 1 m above the holdfast was modelled with a
      zero-truncated negative binomial likelihood, with an overdispersion common
      to all plants. The log of the untruncated mean, mu, varied by site, year,
      and site-year. Regularizing priors were placed on all parameters (see the
      notation form for the hyperparameters).

