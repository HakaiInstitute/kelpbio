# Probe the full kelpbio public API: every exported function and the main
# argument combinations. Run block by block after devtools::load_all() (or
# library(kelpbio)).

library(kelpbio)
library(ggplot2)
library(dplyr)
library(bayesplot)

# --- bundled data + pre-fit ---------------------------------------------------
str(data_weight_hakai_nereo)
str(data_weight_sim_nereo)
fit_weight_hakai_nereo

# --- kb_check_data_weight_nereo() ---------------------------------------------
kb_check_data_weight_nereo(data_weight_hakai_nereo)

bad <- data_weight_hakai_nereo
names(bad)[names(bad) == "diameter"] <- "diam"
try(kb_check_data_weight_nereo(bad))                 # missing column

bad <- data_weight_hakai_nereo
bad$weight[1] <- -1
try(kb_check_data_weight_nereo(bad))                 # not > 0

bad <- data_weight_hakai_nereo
bad$diameter[1] <- NA_real_
try(kb_check_data_weight_nereo(bad))                 # missing value

# --- priors -------------------------------------------------------------------
kb_priors_weight_nereo()
kb_prior_normal(mean = 0, sd = 2)
kb_prior_exponential(rate = 1)

priors <- kb_priors_weight_nereo()
priors$diameter <- kb_prior_normal(mean = 1.5, sd = 0.05)
priors$sd_site <- kb_prior_exponential(rate = 3)
priors

# --- kb_fit_weight_nereo() ----------------------------------------------------
fit <- kb_fit_weight_nereo(data_weight_hakai_nereo, chains = 2, niters = 500)
fit

fit_prior <- kb_fit_weight_nereo(
  data_weight_hakai_nereo,
  prior_only = TRUE, chains = 2, niters = 500, quiet = TRUE
)
fit_custom <- kb_fit_weight_nereo(data_weight_hakai_nereo, priors = priors, quiet = TRUE)
fit_ctrl <- kb_fit_weight_nereo(
  data_weight_hakai_nereo,
  chains = 1, niters = 200, quiet = TRUE,
  control = list(adapt_delta = 0.99, max_treedepth = 12)
)

# custom priors move the slope away from the default-prior posterior
bind_rows(
  mutate(coef(fit), priors = "default"),
  mutate(coef(fit_custom), priors = "custom")
) |>
  filter(term == "bDiameter")

# --- fit accessors: broom + universals + diagnostics --------------------------
print(fit)
tidy(fit)
tidy(fit, include_random_effects = TRUE)
tidy(fit, conf_level = 0.8, sig_fig = 4)
coef(fit)
glance(fit)
converged(fit)
summary(fit)
print(summary(fit))

nobs(fit)
niters(fit)
nchains(fit)
npars(fit)
nterms(fit)
pars(fit)
rhat(fit)
esr(fit)
estimates(fit)

samples(fit)
prior_summary(fit)
prior_summary(fit_prior)
cat(kb_stancode(fit))
dim(log_lik(fit))

# --- fitted / residuals / augment (observed-data diagnostics) -----------------
head(fitted(fit))
head(residuals(fit))
augment(fit)

augment(fit) |>
  ggplot(aes(fitted, residual)) +
  geom_hline(yintercept = 0, linetype = 2) +
  geom_point(alpha = 0.3)

# --- raw posterior draws (rstantools generics) --------------------------------
nd <- data.frame(diameter = c(20, 40, 60))
dim(posterior_epred(fit))
dim(posterior_epred(fit, newdata = nd))
dim(posterior_linpred(fit))
dim(posterior_linpred(fit, transform = TRUE))
dim(posterior_predict(fit))
dim(posterior_predict(fit, newdata = nd))

ppc_dens_overlay(fit$data$weight, posterior_predict(fit)[1:50, , drop = FALSE]) +
  scale_x_log10()
ppc_dens_overlay(fit_prior$data$weight, posterior_predict(fit_prior)[1:50, , drop = FALSE]) +
  scale_x_log10() # prior predictive

# --- kb_predict_weight() (new-data verb) + predict() wrapper ------------------
sites <- levels(fit$data$site)

kb_predict_weight(fit)
kb_predict_weight(fit, new_data = nd)
kb_predict_weight(fit, new_data = tibble(diameter = 40, site = sites[1]))
kb_predict_weight(fit, new_data = tibble(diameter = 40, site = "new_reef"), new_levels = "sample")
kb_predict_weight(fit, new_data = tibble(diameter = 40, site = "new_reef"), representative_site = sites[1])
kb_predict_weight(fit, new_data = nd, conf_level = 0.8, estimate = mean, sig_fig = 4)
try(kb_predict_weight(fit, new_data = tibble(diameter = 40, site = "new_reef"), representative_site = "nope"))

predict(fit)
predict(fit, new_data = nd, new_levels = "average")

# --- kb_predict_weight_by() (curve verb) --------------------------------------
kb_predict_weight_by(fit)
kb_predict_weight_by(fit, new_levels = "average")
kb_predict_weight_by(fit, by = "site")
kb_predict_weight_by(fit, by = c("site", "year"))
kb_predict_weight_by(fit, diameter = seq(10, 80, by = 5))
try(kb_predict_weight_by(fit, by = "year"))          # no year main effect

# --- kb_plot_predictions() / autoplot() ---------------------------------------
pop <- kb_predict_weight_by(fit, new_levels = "sample")
kb_plot_predictions(pop)
kb_plot_predictions(pop, observed = data_weight_hakai_nereo)
autoplot(pop)

kb_predict_weight_by(fit, by = "site") |> kb_plot_predictions()
kb_predict_weight(fit, new_data = nd) |> kb_plot_predictions()
