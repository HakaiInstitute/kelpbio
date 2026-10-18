# notify_site_year warns on an aliased design, naming the main effects

    Code
      notify_site_year("site")
    Condition
      Warning:
      The site:year effect cannot be separated from the site effect: no site was sampled in more than one year.
      i Estimates for the sampled site-years are unaffected, but the site effects, and predictions for other site-years or new sites and years, rest on the `sd_site_year` prior.
      i Check the sensitivity to that prior with `kb_sensitivity()`, and narrow it through `priors` if little site:year variation is expected.

---

    Code
      notify_site_year(c("site", "year"))
    Condition
      Warning:
      The site:year effect cannot be separated from the site and year effects: no site was sampled in more than one year and no year had more than one site sampled.
      i Estimates for the sampled site-years are unaffected, but the site and year effects, and predictions for other site-years or new sites and years, rest on the `sd_site_year` prior.
      i Check the sensitivity to that prior with `kb_sensitivity()`, and narrow it through `priors` if little site:year variation is expected.

