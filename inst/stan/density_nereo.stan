// Nereocystis stipe density (site-year resolution): the number of stipes on a
// transect follows a zero-inflated negative binomial, with the transect area as
// an offset.
//   stipes ~ ZINB(area * exp(log_density), 1 / bDispersion, zi)
//   log_density = bStipes + bSite[site] + bYear[year] + bSiteYear[site, year]
//   zi = inv_logit(bZeroInflation)
// zi is the probability that a transect holds no stipes, one value for all
// transects; exp(log_density) is the density (stipes per m^2) on transects that
// hold stipes, so the expected count is (1 - zi) * area * exp(log_density).
// Random effects: site, year, and site:year, all on log_density. Priors are
// passed as data; the prior family is fixed at compile time. The mean is a local
// in the model block so it is not saved with the draws. The pointwise
// log-likelihood and posterior-predictive replicates are computed in R from the
// stored draws, so there are no generated quantities.
functions {
  int count_zeros(array[] int y) {
    int n = 0;
    for (i in 1:size(y)) {
      n += (y[i] == 0);
    }
    return n;
  }
}
data {
  int<lower=0> nObs;                      // 0 allowed: supports prior-only / empty fits
  int<lower=1> nSite;
  int<lower=1> nYear;
  array[nObs] int<lower=1, upper=nSite> site;
  array[nObs] int<lower=1, upper=nYear> year;
  array[nObs] int<lower=0> stipes;
  vector<lower=0>[nObs] area;             // area surveyed (m^2)

  // priors (hyperparameters passed as data)
  real prior_intercept_mu;
  real<lower=0> prior_intercept_sd;
  real prior_zero_inflation_mu;
  real<lower=0> prior_zero_inflation_sd;
  real<lower=0> prior_dispersion_rate;
  real<lower=0> prior_sd_site_rate;
  real<lower=0> prior_sd_year_rate;
  real<lower=0> prior_sd_site_year_rate;

  int<lower=0, upper=1> prior_only;       // 1 = skip likelihood, sample from priors
  int<lower=0, upper=1> site_year_on;     // 0 = drop the site:year term
}
transformed data {
  vector[nObs] log_area = log(area);
  // column-major linear index into to_vector(bSiteYear): (site, year) ->
  // site + (year - 1) * nSite. Lets the site:year term be one vectorised gather.
  array[nObs] int sy_idx;
  // Zero and non-zero counts take different likelihood terms, so their indices
  // are split once here and each term is vectorised.
  int nZero = count_zeros(stipes);
  array[nZero] int idx_zero;
  array[nObs - nZero] int idx_pos;
  {
    int iz = 1;
    int ip = 1;
    for (i in 1:nObs) {
      sy_idx[i] = site[i] + (year[i] - 1) * nSite;
      if (stipes[i] == 0) {
        idx_zero[iz] = i;
        iz += 1;
      } else {
        idx_pos[ip] = i;
        ip += 1;
      }
    }
  }
}
parameters {
  real bStipes;                           // log stipes per m^2 at a typical site and year
  real bZeroInflation;                    // logit probability a transect holds no stipes
  real<lower=0> bDispersion;              // overdispersion; phi = 1 / bDispersion
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
  bStipes ~ normal(prior_intercept_mu, prior_intercept_sd);
  bZeroInflation ~ normal(prior_zero_inflation_mu, prior_zero_inflation_sd);
  bDispersion ~ exponential(prior_dispersion_rate);
  sSite ~ exponential(prior_sd_site_rate);
  sYear ~ exponential(prior_sd_year_rate);
  sSiteYear ~ exponential(prior_sd_site_year_rate);
  z_bSite ~ std_normal();
  z_bYear ~ std_normal();
  to_vector(z_bSiteYear) ~ std_normal();
  if (prior_only == 0) {
    // A local, not a transformed parameter: rstan saves transformed parameters,
    // and nObs columns per draw is the largest thing in a stored fit.
    real phi = 1 / bDispersion;
    real log_zi = log_inv_logit(bZeroInflation);
    real log1m_zi = log1m_inv_logit(bZeroInflation);
    vector[nObs] log_mu = log_area + bStipes + bSite[site] + bYear[year]
      + site_year_on * to_vector(bSiteYear)[sy_idx];
    // A zero is structural or a negative binomial zero:
    // log(zi + (1 - zi) * P0) = log(zi) + log1p(exp(log(1 - zi) + log(P0) - log(zi))),
    // with log P0 = -phi * log(1 + mu / phi) written on the log scale for stability.
    vector[nZero] log_p0 = -phi * log1p_exp(log_mu[idx_zero] - log(phi));
    target += nZero * log_zi + sum(log1p_exp(log1m_zi + log_p0 - log_zi));
    target += (nObs - nZero) * log1m_zi
      + neg_binomial_2_log_lpmf(stipes[idx_pos] | log_mu[idx_pos], phi);
  }
}
