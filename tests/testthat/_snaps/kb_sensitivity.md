# kb_sensitivity refuses fits with no likelihood

    Code
      kb_sensitivity(prior_only)
    Condition
      Error in `kb_sensitivity()`:
      ! A prior-only fit has no likelihood, so its prior sensitivity cannot be assessed.

---

    Code
      kb_sensitivity(empty)
    Condition
      Error in `kb_sensitivity()`:
      ! A zero-observation fit has no likelihood, so its prior sensitivity cannot be assessed.

# kb_sensitivity validates its arguments

    Code
      kb_sensitivity(1)
    Condition
      Error in `kb_sensitivity()`:
      ! `fit` must be a <kb_fit> object.
      i Supported fits are created by the `kb_fit_*()` functions.

---

    Code
      kb_sensitivity(wetdry_nereo_fit, prior_threshold = 0)
    Condition
      Error in `kb_sensitivity()`:
      ! `prior_threshold` must be greater than 0, not 0.

---

    Code
      kb_sensitivity(wetdry_nereo_fit, likelihood_threshold = "a")
    Condition
      Error in `kb_sensitivity()`:
      ! `likelihood_threshold` must be a number (non-missing numeric scalar).

---

    Code
      kb_sensitivity(wetdry_nereo_fit, 0.1)
    Condition
      Error in `kb_sensitivity()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = 0.1
      i Did you forget to name an argument?

