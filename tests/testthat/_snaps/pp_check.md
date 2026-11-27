# pp_check validates its arguments

    Code
      pp_check(weight_nereo_fit, ndraws = 2.5)
    Condition
      Error in `pp_check()`:
      ! `ndraws` must be a whole number (non-missing integer scalar or double equivalent).

---

    Code
      pp_check(weight_nereo_fit, ndraws = posterior::ndraws(weight_nereo_fit$draws) +
        1)
    Condition
      Error in `pp_check()`:
      ! `ndraws` must be between 1 and 600, not 601.

---

    Code
      pp_check(weight_nereo_fit, "bars")
    Condition
      Error in `pp_check()`:
      ! `type` must be one of "response" or "residual", not "bars".

---

    Code
      pp_check(weight_nereo_fit, ndraw = 5)
    Condition
      Error in `pp_check()`:
      ! `...` must be empty.
      x Problematic argument:
      * ndraw = 5

