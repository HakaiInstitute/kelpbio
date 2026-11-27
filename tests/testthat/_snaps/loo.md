# loo refuses a fit without a likelihood

    Code
      loo::loo(prior_only)
    Condition
      Error in `loo::loo()`:
      ! A prior-only fit has no likelihood, so it cannot be cross-validated.

---

    Code
      loo::loo(no_data)
    Condition
      Error in `loo::loo()`:
      ! A zero-observation fit has no likelihood, so it cannot be cross-validated.

