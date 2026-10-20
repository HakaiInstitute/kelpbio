# kb_model_describe renders the nereo notation block

    Code
      kb_model_describe(weight_nereo_fit)
    Output
      Weight allometry - Nereocystis luetkeana
      Response: wet weight (kg); predictor: sub-bulb diameter (mm)
      
      Likelihood
        log(weight_kg) ~ Normal(log(mu), sd_residual)
        mu = weight_floor + alpha * x^diameter_power
        log(alpha) = intercept
                   + site_effect[site]
                   + year_effect[year]
                   + site_year_effect[site, year]
        x = diameter_mm / d0,  d0 = 23.4  (geometric mean diameter)
      
      Random effects
        site_effect[site]            ~ Normal(0, sd_site)       site effect on log(alpha)
        year_effect[year]            ~ Normal(0, sd_year)       year effect on log(alpha)
        site_year_effect[site, year] ~ Normal(0, sd_site_year)  site:year effect on log(alpha)
      
      Priors
        intercept      ~ Normal(0, 2)
        diameter_power ~ Normal(2, 1) T[0, ]
        weight_floor   ~ Normal(0, 0.5) T[0, ]
        sd_residual    ~ Exponential(1)
        sd_site        ~ Exponential(1)
        sd_year        ~ Exponential(1)
        sd_site_year   ~ Exponential(1)

# kb_model_describe renders the macro notation block

    Code
      kb_model_describe(weight_macro_fit)
    Output
      Weight allometry - Macrocystis pyrifera
      Response: wet weight (kg); predictor: frond count
      
      Likelihood
        weight_kg ~ Gamma(shape, shape / mu)
        mu = alpha * x^fronds_slope
        log(alpha) = intercept
                   + site_effect[site]
                   + year_effect[year]
                   + site_year_effect[site, year]
        x = fronds / f0,  f0 = 4.61  (geometric mean frond count)
      
      Random effects
        site_effect[site]            ~ Normal(0, sd_site)       site effect on log(alpha)
        year_effect[year]            ~ Normal(0, sd_year)       year effect on log(alpha)
        site_year_effect[site, year] ~ Normal(0, sd_site_year)  site:year effect on log(alpha)
      
      Priors
        intercept      ~ Normal(0, 2)
        fronds_slope   ~ Normal(1, 0.5)
        shape          ~ Exponential(0.1)
        sd_site        ~ Exponential(1)
        sd_year        ~ Exponential(1)
        sd_site_year   ~ Exponential(1)

# kb_model_describe renders a methods paragraph with prose = TRUE

    Code
      kb_model_describe(weight_nereo_fit, prose = TRUE)
    Output
      Wet weight was modelled on the log scale with a Normal likelihood as an
      allometric function of sub-bulb diameter. The expected log weight was
      log(mu), where mu followed a three-parameter power function (Packard 2023)
      of diameter relative to the geometric mean diameter (23.4), in which
      weight_floor is the weight as diameter approaches zero, alpha the weight
      above the floor at the reference diameter, and diameter_power the
      allometric exponent. The log of alpha varied by site, by year, and by
      site:year. Regularising priors were placed on all parameters (see the
      notation form for the hyperparameters).

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

# kb_model_describe renders the wet/dry model without random effects

    Code
      kb_model_describe(wetdry_nereo_fit)
    Output
      Wet/dry ratio - Nereocystis luetkeana
      Response: dry_mass_g / wet_mass_g, the dry:wet ratio of a sample
      
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
      The dry:wet ratio of each sample was modelled with a Beta likelihood
      parameterised by its mean, mu, and precision, both common to all samples.
      Samples were pooled over the months, sites, and tissues they came from.
      Regularising priors were placed on all parameters (see the notation form
      for the hyperparameters).

# kb_model_describe renders the carbon model

    Code
      kb_model_describe(carbon_nereo_fit)
    Output
      Carbon fraction - Nereocystis luetkeana
      Response: carbon_fraction, the carbon mass divided by the sample mass (carbon_mass_ug converted to mg, divided by sample_mass_mg)
      
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
      from. Regularising priors were placed on all parameters (see the notation
      form for the hyperparameters).

# kb_model_describe renders the cover calibration model with each species' priors

    Code
      kb_model_describe(cover_calibration_nereo_fit)
    Output
      Cover calibration - Nereocystis luetkeana
      Response: biomass_kg_m2, the mean wet biomass of an in situ survey (kg/m²), with SD biomass_sd_kg_m2 from plant weight
      
      Likelihood
        biomass_kg_m2 ~ Normal(mu, sigma) censored below at 0
        sigma = sqrt(sd_residual^2 + (cv_residual * mu)^2 + biomass_sd_kg_m2^2)
        mu = biomass_floor
           + cover_slope * exp(year_effect[year] + site_effect[site]) * cover
        cover = min(1, canopy_area_m2 / (1 - tide_height_slope * tide_height_m) / plot_area_m2), and 1 where canopy_area_m2 > 0 and tide_height_m >= 1 / tide_height_slope
      
      Random effects
        year_effect[year] ~ Normal(0, sd_year)  year effect on log(cover_slope)
        site_effect[site] ~ Normal(0, sd_site)  site effect on log(cover_slope)
      
      Priors
        cover_slope       ~ LogNormal(2, 1)
        biomass_floor     ~ Normal(0, 0.1) T[0, ]
        tide_height_slope ~ Normal(0.276, 0.04) T[0, 0.5]
        sd_residual       ~ Exponential(2)
        cv_residual       ~ Normal(0, 1) T[0, ]
        sd_year           ~ Exponential(1)
        sd_site           ~ Exponential(1)

---

    Code
      kb_model_describe(cover_calibration_macro_fit)
    Output
      Cover calibration - Macrocystis pyrifera
      Response: biomass_kg_m2, the mean wet biomass of an in situ survey (kg/m²), with SD biomass_sd_kg_m2 from plant weight
      
      Likelihood
        biomass_kg_m2 ~ Normal(mu, sigma) censored below at 0
        sigma = sqrt(sd_residual^2 + (cv_residual * mu)^2 + biomass_sd_kg_m2^2)
        mu = biomass_floor
           + cover_slope * exp(year_effect[year] + site_effect[site]) * cover
        cover = min(1, canopy_area_m2 / (1 - tide_height_slope * tide_height_m) / plot_area_m2), and 1 where canopy_area_m2 > 0 and tide_height_m >= 1 / tide_height_slope
      
      Random effects
        year_effect[year] ~ Normal(0, sd_year)  year effect on log(cover_slope)
        site_effect[site] ~ Normal(0, sd_site)  site effect on log(cover_slope)
      
      Priors
        cover_slope       ~ LogNormal(2, 1)
        biomass_floor     ~ Normal(0.4, 0.3) T[0, ]
        tide_height_slope ~ Normal(0.227, 0.03) T[0, 0.5]
        sd_residual       ~ Exponential(2)
        cv_residual       ~ Normal(0, 1) T[0, ]
        sd_year           ~ Exponential(1)
        sd_site           ~ Exponential(1)

---

    Code
      kb_model_describe(cover_calibration_macro_fit, prose = TRUE)
    Output
      The mean wet biomass of each in situ survey was modelled as a biomass
      floor, common to all sites and years, plus a term proportional to the
      tide-corrected canopy cover of the survey's plot, whose slope varied by
      site and year. Canopy area was divided by one minus an estimated share per
      metre of tide height, and cover was capped at 1; plots with canopy at or
      above the tide height where that share reaches 1 were fully covered. The
      likelihood was Normal, censored below at zero so that surveys with no
      plants counted contributed the probability of zero or less, with a standard
      deviation combining a constant, a part proportional to the mean, and the
      survey's standard deviation from plant weight. Regularising priors were
      placed on all parameters, with an informative prior on the tide correction
      (see the notation form for the hyperparameters).

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
                   + site_effect[site]
                   + year_effect[year]
                   + site_year_effect[site, year]
        x = diameter_mm / d0,  d0 = 23.4  (geometric mean diameter)
      
      Random effects
        site_effect[site]            ~ Normal(0, sd_site)       site effect on log(alpha)
        year_effect[year]            ~ Normal(0, sd_year)       year effect on log(alpha)
        site_year_effect[site, year] ~ Normal(0, sd_site_year)  site:year effect on log(alpha)
      
      Priors
        intercept      ~ Normal(0, 2)
        diameter_power ~ Normal(2, 1) T[0, ]
        sd_residual    ~ Exponential(1)
        sd_site        ~ Exponential(1)
        sd_year        ~ Exponential(1)
        sd_site_year   ~ Exponential(1)

---

    Code
      kb_model_describe(power, prose = TRUE)
    Output
      Wet weight was modelled on the log scale with a Normal likelihood as an
      allometric function of sub-bulb diameter. The expected log weight was
      log(mu), where mu followed a power law in diameter relative to the
      geometric mean diameter (23.4), in which alpha is the weight at the
      reference diameter and diameter_power the allometric exponent. The log of
      alpha varied by site, by year, and by site:year. Regularising priors were
      placed on all parameters (see the notation form for the hyperparameters).

