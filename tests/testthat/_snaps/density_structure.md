# notify_density reports an omitted term and unrecorded site-years

    Code
      notify_density(density_structure(density_data(NA)))
    Message
      i The density effect is omitted: fewer than two distinct site-year densities are recorded.

---

    Code
      notify_density(density_structure(density_data(c(2, NA, 4, 6, NA))))
    Message
      i Density is not recorded for 1 site-year; it takes the mean density.

