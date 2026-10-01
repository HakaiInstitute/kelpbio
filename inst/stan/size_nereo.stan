// Nereocystis size distribution (site-year resolution): maximum sub-bulb
// diameter follows a Weibull distribution parameterised by its mean.
//   diameter ~ weibull(bShape, mu / tgamma(1 + 1 / bShape))
//   log(mu)  = bDiameter + bSite[site] + bYear[year] + bSiteYear[site, year]
// The shape is a single scalar, common to every plant. A group-varying shape
// inside tgamma(1 + 1 / shape) can reach a shape near zero at initialisation,
// where tgamma overflows and the chain freezes; with a scalar the worst initial
// value is large but finite.
// Random effects: site, year, and site:year, all on log(mu). Priors are passed
// as data; the prior family is fixed at compile time. The mean is a local in the
// model block so it is not saved with the draws. The pointwise log-likelihood
// and posterior-predictive replicates are computed in R from the stored draws,
// so there are no generated quantities.
data {
  int<lower=0> nObs;                      // 0 allowed: supports prior-only / empty fits
  int<lower=1> nSite;
  int<lower=1> nYear;
  array[nObs] int<lower=1, upper=nSite> site;
  array[nObs] int<lower=1, upper=nYear> year;
  vector<lower=0>[nObs] diameter;

  // priors (hyperparameters passed as data)
  real prior_intercept_mu;
  real<lower=0> prior_intercept_sd;
  real<lower=0> prior_shape_rate;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;
  real<lower=0> prior_sd_site_year_rate;

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
  int<lower=0, upper=1> site_year_on;     // 0 = drop the site:year term
}
transformed data {
  // column-major linear index into to_vector(bSiteYear): (site, year) ->
  // site + (year - 1) * nSite. Lets the site:year term be one vectorised gather.
  array[nObs] int sy_idx;
  for (i in 1:nObs) {
    sy_idx[i] = site[i] + (year[i] - 1) * nSite;
  }
}
parameters {
  real bDiameter;                         // log mean diameter at a typical site and year
  real<lower=0> bShape;                   // Weibull shape
  real<lower=0> sSite;                    // site SD
  real<lower=0> sYear;                    // year SD
  real<lower=0> sSiteYear;                // site:year SD
  vector[nSite] z_bSite;                  // non-centered site effects
  vector[nYear] z_bYear;                  // non-centered year effects
  matrix[nSite, nYear] z_bSiteYear;       // non-centered site:year effects
}
transformed parameters {
  vector[nSite] bSite = z_bSite * sSite;
  vector[nYear] bYear = z_bYear * sYear;
  matrix[nSite, nYear] bSiteYear = z_bSiteYear * sSiteYear;
}
model {
  bDiameter ~ normal(prior_intercept_mu, prior_intercept_sd);
  bShape ~ exponential(prior_shape_rate);
  sSite ~ exponential(prior_sd_site_rate);
  sYear ~ exponential(prior_sd_year_rate);
  sSiteYear ~ exponential(prior_sd_site_year_rate);
  z_bSite ~ std_normal();
  z_bYear ~ std_normal();
  to_vector(z_bSiteYear) ~ std_normal();
  if (prior_only == 0) {
    // A local, not a transformed parameter: rstan saves transformed parameters,
    // and nObs columns per draw is the largest thing in a stored fit.
    vector[nObs] log_mu = bDiameter + bSite[site] + bYear[year]
      + site_year_on * to_vector(bSiteYear)[sy_idx];
    diameter ~ weibull(bShape, exp(log_mu) / tgamma(1 + 1 / bShape));
  }
}
