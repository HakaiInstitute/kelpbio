# a column in the wrong unit warns, naming it and the expected unit

    Code
      warn_implausible_units(data.frame(diameter_mm = c(2.5, 3.4, 4)), "`d`")
    Condition
      Warning:
      Column `diameter_mm` of `d` has median 3.4, which is unusually small for millimetres.
      i Check that diameter_mm is in millimetres.

---

    Code
      warn_implausible_units(data.frame(weight_kg = c(900, 1200)), "`d`")
    Condition
      Warning:
      Column `weight_kg` of `d` has median 1050, which is unusually large for kilograms.
      i Check that weight_kg is in kilograms.

---

    Code
      warn_implausible_units(data.frame(stipes_m2 = c(20000, 30000)), "`d`")
    Condition
      Warning:
      Column `stipes_m2` of `d` has median 25000, which is unusually large for stipes per m².
      i Check that stipes_m2 is in stipes per m².

