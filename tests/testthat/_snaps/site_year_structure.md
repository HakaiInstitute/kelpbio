# notify_site_year warns on an aliased design, naming the main effects

    Code
      notify_site_year(list(on = TRUE, aliased = "site"))
    Condition
      Warning:
      The site:year effect is not separately identifiable from the site effect: no site was sampled in more than one year.
      i The term is retained and predictions are unaffected, but do not interpret the site:year contribution separately from the site effect.

---

    Code
      notify_site_year(list(on = TRUE, aliased = c("site", "year")))
    Condition
      Warning:
      The site:year effect is not separately identifiable from the site and year effects: no site was sampled in more than one year and no year had more than one site sampled.
      i The term is retained and predictions are unaffected, but do not interpret the site:year contribution separately from the site and year effects.

