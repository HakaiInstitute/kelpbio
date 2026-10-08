# kb_influence refuses fits with no likelihood

    Code
      kb_influence(prior_only)
    Condition
      Error in `kb_influence()`:
      ! A prior-only fit has no likelihood, so it cannot be cross-validated.

---

    Code
      kb_influence(empty)
    Condition
      Error in `kb_influence()`:
      ! A zero-observation fit has no likelihood, so it cannot be cross-validated.

# kb_influence validates its arguments

    Code
      kb_influence(1)
    Condition
      Error in `kb_influence()`:
      ! `fit` must be a <kb_fit> object.
      i Supported fits are created by the `kb_fit_*()` functions.

---

    Code
      kb_influence(wetdry_nereo_fit, threshold = 0)
    Condition
      Error in `kb_influence()`:
      ! `threshold` must be greater than 0, not 0.

---

    Code
      kb_influence(wetdry_nereo_fit, 0.7)
    Condition
      Error in `kb_influence()`:
      ! `...` must be empty.
      x Problematic argument:
      * ..1 = 0.7
      i Did you forget to name an argument?

