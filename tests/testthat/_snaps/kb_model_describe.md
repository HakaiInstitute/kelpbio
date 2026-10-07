# kb_model_describe renders the nereo notation block

    Code
      kb_model_describe(weight_fit)
    Output
      Weight allometry - Nereocystis luetkeana
      Response: wet weight (kg); predictor: sub-bulb diameter (mm)
      
      Likelihood
        log(weight_kg) ~ Normal(log(mu), sd_residual)
        mu = weight_floor + alpha * x^diameter_power
        log(alpha) = intercept
                   + density_slope * density
                   + year_effect[year]
                   + site_effect[site]
                   + site_year_effect[site, year]
        x = diameter_mm / d0,  d0 = 23.4  (geometric mean diameter)
        density = (stipe density - 1.26) / 1.32  (standardised site-year density)
      
      Random effects
        year_effect[year]            ~ Normal(0, sd_year)       year effect on log(alpha)
        site_effect[site]            ~ Normal(0, sd_site)       site effect on log(alpha)
        site_year_effect[site, year] ~ Normal(0, sd_site_year)  site:year effect on log(alpha)
      
      Priors
        intercept      ~ Normal(0, 2)
        diameter_power ~ Normal(2, 1) T[0, ]
        weight_floor   ~ Normal(0, 0.5) T[0, ]
        density_slope  ~ Normal(0, 0.5)
        sd_residual    ~ Exponential(1)
        sd_year        ~ Exponential(1)
        sd_site        ~ Exponential(1)
        sd_site_year   ~ Exponential(1)

# kb_model_describe renders the macro notation block

    Code
      kb_model_describe(weight_macro_fit)
    Output
      Weight allometry - Macrocystis pyrifera
      Response: wet weight; predictor: frond count
      
      Likelihood
        weight_kg ~ Gamma(shape, shape / mu)
        log(mu) = intercept
                + fronds_slope * x
                + site_effect[site]
                + year_effect[year]
                + site_year_effect[site, year]
        x = log(fronds) - log(f0),  f0 = 4.61  (geometric mean frond count)
      
      Random effects
        site_effect[site]            ~ Normal(0, sd_site)       site intercept
        year_effect[year]            ~ Normal(0, sd_year)       year intercept
        site_year_effect[site, year] ~ Normal(0, sd_site_year)  site:year intercept
      
      Priors
        intercept      ~ Normal(0, 2)
        fronds_slope   ~ Normal(1, 0.5)
        shape          ~ Exponential(0.1)
        sd_site        ~ Exponential(1)
        sd_year        ~ Exponential(1)
        sd_site_year   ~ Exponential(1)

# kb_model_describe renders a methods paragraph with prose = TRUE

    Code
      kb_model_describe(weight_fit, prose = TRUE)
    Output
      Wet weight was modelled on the log scale with a Normal likelihood as an
      allometric function of sub-bulb diameter. Expected weight followed a
      three-parameter power function (Packard 2023) of diameter relative to the
      geometric mean diameter (23.4), in which weight_floor is the weight as
      diameter approaches zero, alpha the weight above the floor at the reference
      diameter, and diameter_power the allometric exponent. The log of alpha
      varied by year, by site, and by site-year. The log of alpha also varied
      linearly with site-year stipe density, standardised by its mean (1.26) and
      standard deviation (1.32). Regularizing priors were placed on all
      parameters (see the notation form for the hyperparameters).

# kb_model_describe renders the size notation blocks

    Code
      kb_model_describe(size_nereo_fit)
    Output
      Size distribution - Nereocystis luetkeana
      Response: maximum sub-bulb diameter (mm)
      
      Likelihood
        diameter_mm ~ Weibull(shape, mu / gamma(1 + 1 / shape))
        log(mu) = intercept
                + site_effect[site]
                + year_effect[year]
                + site_year_effect[site, year]
      
      Random effects
        site_effect[site]            ~ Normal(0, sd_site)       site effect on log(mu)
        year_effect[year]            ~ Normal(0, sd_year)       year effect on log(mu)
        site_year_effect[site, year] ~ Normal(0, sd_site_year)  site:year effect on log(mu)
      
      Priors
        intercept      ~ Normal(0, 2)
        shape          ~ Exponential(0.1)
        sd_site        ~ Exponential(1)
        sd_year        ~ Exponential(1)
        sd_site_year   ~ Exponential(1)

---

    Code
      kb_model_describe(size_macro_fit)
    Output
      Size distribution - Macrocystis pyrifera
      Response: fronds reaching 1 m above the holdfast
      
      Likelihood
        fronds ~ NegBinomial(mu, 1 / dispersion) T[1, ]
        E[fronds] = mu / (1 - P(fronds = 0))
        log(mu) = intercept
                + site_effect[site]
                + year_effect[year]
                + site_year_effect[site, year]
      
      Random effects
        site_effect[site]            ~ Normal(0, sd_site)       site effect on log(mu)
        year_effect[year]            ~ Normal(0, sd_year)       year effect on log(mu)
        site_year_effect[site, year] ~ Normal(0, sd_site_year)  site:year effect on log(mu)
      
      Priors
        intercept      ~ Normal(0, 2)
        dispersion     ~ Exponential(1)
        sd_site        ~ Exponential(1)
        sd_year        ~ Exponential(1)
        sd_site_year   ~ Exponential(1)

---

    Code
      kb_model_describe(size_macro_fit, prose = TRUE)
    Output
      The number of fronds reaching 1 m above the holdfast was modelled with a
      zero-truncated negative binomial likelihood, with an overdispersion common
      to all plants. The log of the untruncated mean, mu, varied by site, year,
      and site-year. Regularizing priors were placed on all parameters (see the
      notation form for the hyperparameters).

# kb_model_describe renders the density notation blocks

    Code
      kb_model_describe(density_nereo_fit)
    Output
      Density - Nereocystis luetkeana
      Response: stipes counted on a transect of area_m2 (m²)
      
      Likelihood
        stipes ~ ZeroInflatedNegBinomial(mu, 1 / dispersion, zi)
        zi = inv_logit(logit_zero_inflation)
        E[stipes] = (1 - zi) * mu
        log(mu) = log(area_m2)
                + intercept
                + site_effect[site]
                + year_effect[year]
                + site_year_effect[site, year]
      
      Random effects
        site_effect[site]            ~ Normal(0, sd_site)       site effect on log(mu)
        year_effect[year]            ~ Normal(0, sd_year)       year effect on log(mu)
        site_year_effect[site, year] ~ Normal(0, sd_site_year)  site:year effect on log(mu)
      
      Priors
        intercept            ~ Normal(0, 2)
        logit_zero_inflation ~ Normal(0, 2)
        dispersion           ~ Exponential(1)
        sd_site              ~ Exponential(1)
        sd_year              ~ Exponential(1)
        sd_site_year         ~ Exponential(1)

---

    Code
      kb_model_describe(density_nereo_fit, prose = TRUE)
    Output
      The number of stipes on a transect was modelled with a zero-inflated
      negative binomial likelihood, with the transect area as an offset. The
      zero-inflation probability, zi, and the overdispersion were common to all
      transects. The log stipe density on transects holding stipes varied by
      site, year, and site-year. Regularizing priors were placed on all
      parameters (see the notation form for the hyperparameters).

---

    Code
      kb_model_describe(density_macro_fit)
    Output
      Density - Macrocystis pyrifera
      Response: plants counted on a transect of area_m2 (m²)
      
      Likelihood
        plants ~ NegBinomial(mu, 1 / dispersion)
        log(mu) = log(area_m2)
                + intercept
                + site_effect[site]
                + year_effect[year]
                + site_year_effect[site, year]
      
      Random effects
        site_effect[site]            ~ Normal(0, sd_site)       site effect on log(mu)
        year_effect[year]            ~ Normal(0, sd_year)       year effect on log(mu)
        site_year_effect[site, year] ~ Normal(0, sd_site_year)  site:year effect on log(mu)
      
      Priors
        intercept      ~ Normal(0, 2)
        dispersion     ~ Exponential(1)
        sd_site        ~ Exponential(1)
        sd_year        ~ Exponential(1)
        sd_site_year   ~ Exponential(1)

# kb_model_describe renders the wet/dry model without random effects

    Code
      kb_model_describe(wetdry_nereo_fit)
    Output
      Wet/dry ratio - Nereocystis luetkeana
      Response: dry_mass_g / wet_mass_g, the dry:wet mass ratio of a sample
      
      Likelihood
        dry_wet_ratio ~ Beta(mu * precision, (1 - mu) * precision)
        logit(mu) = intercept
      
      Priors
        intercept      ~ Normal(0, 2)
        precision      ~ Exponential(0.01)

---

    Code
      kb_model_describe(wetdry_macro_fit, prose = TRUE)
    Output
      The dry:wet mass ratio of each sample was modelled with a Beta likelihood
      parameterised by its mean, mu, and precision, both common to all samples.
      Samples were pooled over the months, sites, and tissues they came from.
      Regularizing priors were placed on all parameters (see the notation form
      for the hyperparameters).

# kb_model_describe renders the carbon model

    Code
      kb_model_describe(carbon_nereo_fit)
    Output
      Carbon fraction - Nereocystis luetkeana
      Response: carbon_fraction = carbon_mass_ug / 1000 / sample_mass_mg, the fraction of a dry sample's mass that is carbon
      
      Likelihood
        carbon_fraction ~ Beta(mu * precision, (1 - mu) * precision)
        logit(mu) = intercept
      
      Priors
        intercept      ~ Normal(-0.8, 0.3)
        precision      ~ Exponential(0.001)

---

    Code
      kb_model_describe(carbon_macro_fit, prose = TRUE)
    Output
      The carbon fraction of each dried sample was modelled with a Beta
      likelihood parameterised by its mean, mu, and precision, both common to all
      samples. Samples were pooled over the months, sites, and tissues they came
      from. Regularizing priors were placed on all parameters (see the notation
      form for the hyperparameters).

# kb_model_describe renders the cover biomass model with each species' priors

    Code
      kb_model_describe(cover_biomass_nereo_fit)
    Output
      Cover biomass - Nereocystis luetkeana
      Response: estimate, the in situ wet biomass of a plot (kg/m²), with compatibility limits lower and upper
      
      Likelihood
        log(estimate) ~ Normal(log(mu), error_scaling * sd)
        mu = biomass_floor
           + cover_slope * exp(year_effect[year] + site_effect[site]) * cover
        cover = min(1, canopy_area_m2 * (1 + tide_height_slope * tide_height_m) / plot_area_m2)
        sd = (log(upper) - log(lower)) / (2 * 1.96)  (log-scale SD of the in situ estimate)
      
      Random effects
        year_effect[year] ~ Normal(0, sd_year)  year effect on log(cover_slope)
        site_effect[site] ~ Normal(0, sd_site)  site effect on log(cover_slope)
      
      Priors
        cover_slope       ~ LogNormal(2, 1)
        biomass_floor     ~ Normal(0, 0.1) T[0, ]
        tide_height_slope ~ Normal(0.276, 0.04) T[0, ]
        error_scaling     ~ Normal(1, 0.5) T[0, ]
        sd_year           ~ Exponential(1)
        sd_site           ~ Exponential(1)

---

    Code
      kb_model_describe(cover_biomass_macro_fit)
    Output
      Cover biomass - Macrocystis pyrifera
      Response: estimate, the in situ wet biomass of a plot (kg/m²), with compatibility limits lower and upper
      
      Likelihood
        log(estimate) ~ Normal(log(mu), error_scaling * sd)
        mu = biomass_floor
           + cover_slope * exp(year_effect[year] + site_effect[site]) * cover
        cover = min(1, canopy_area_m2 * (1 + tide_height_slope * tide_height_m) / plot_area_m2)
        sd = (log(upper) - log(lower)) / (2 * 1.96)  (log-scale SD of the in situ estimate)
      
      Random effects
        year_effect[year] ~ Normal(0, sd_year)  year effect on log(cover_slope)
        site_effect[site] ~ Normal(0, sd_site)  site effect on log(cover_slope)
      
      Priors
        cover_slope       ~ LogNormal(2, 1)
        biomass_floor     ~ Normal(0.4, 0.3) T[0, ]
        tide_height_slope ~ Normal(0.227, 0.03) T[0, ]
        error_scaling     ~ Normal(1, 0.5) T[0, ]
        sd_year           ~ Exponential(1)
        sd_site           ~ Exponential(1)

---

    Code
      kb_model_describe(cover_biomass_macro_fit, prose = TRUE)
    Output
      The in situ wet biomass of each surveyed plot was modelled as a biomass
      floor, common to all sites and years, plus a term proportional to the
      plot's tide-corrected canopy cover, whose slope varied by site and year.
      Canopy area was increased by a fixed fraction per metre of tide height, and
      cover was capped at 1. The log of each in situ estimate was modelled with a
      normal likelihood whose standard deviation was the log-scale standard
      deviation of that estimate multiplied by a scaling parameter. Regularizing
      priors were placed on all parameters, with an informative prior on the tide
      correction (see the notation form for the hyperparameters).

# kb_model_describe follows the power-law form

    Code
      kb_model_describe(power)
    Output
      Weight allometry - Nereocystis luetkeana
      Response: wet weight (kg); predictor: sub-bulb diameter (mm)
      
      Likelihood
        log(weight_kg) ~ Normal(log(mu), sd_residual)
        mu = alpha * x^diameter_power
        log(alpha) = intercept
                   + density_slope * density
                   + year_effect[year]
                   + site_effect[site]
                   + site_year_effect[site, year]
        x = diameter_mm / d0,  d0 = 23.4  (geometric mean diameter)
        density = (stipe density - 1.26) / 1.32  (standardised site-year density)
      
      Random effects
        year_effect[year]            ~ Normal(0, sd_year)       year effect on log(alpha)
        site_effect[site]            ~ Normal(0, sd_site)       site effect on log(alpha)
        site_year_effect[site, year] ~ Normal(0, sd_site_year)  site:year effect on log(alpha)
      
      Priors
        intercept      ~ Normal(0, 2)
        diameter_power ~ Normal(2, 1) T[0, ]
        density_slope  ~ Normal(0, 0.5)
        sd_residual    ~ Exponential(1)
        sd_year        ~ Exponential(1)
        sd_site        ~ Exponential(1)
        sd_site_year   ~ Exponential(1)

---

    Code
      kb_model_describe(power, prose = TRUE)
    Output
      Wet weight was modelled on the log scale with a Normal likelihood as an
      allometric function of sub-bulb diameter. Expected weight followed a power
      law in diameter relative to the geometric mean diameter (23.4), in which
      alpha is the weight at the reference diameter and diameter_power the
      allometric exponent. The log of alpha varied by year, by site, and by
      site-year. The log of alpha also varied linearly with site-year stipe
      density, standardised by its mean (1.26) and standard deviation (1.32).
      Regularizing priors were placed on all parameters (see the notation form
      for the hyperparameters).

