# warn_carbon_fraction counts samples outside 0.10 to 0.50 and keeps them

    Code
      out <- warn_carbon_fraction(odd, "`d`")
    Condition
      Warning:
      2 samples in `d` have carbon fractions outside 0.10 to 0.50, the plausible range for kelp tissue.
      i Check that carbon_mass_ug is in micrograms and sample_mass_mg in milligrams.

# warn_dry_wet_ratio counts samples outside 0.02 to 0.5 and keeps them

    Code
      out <- warn_dry_wet_ratio(odd, "`d`")
    Condition
      Warning:
      2 samples in `d` have dry:wet mass ratios outside 0.02 to 0.5, the plausible range for kelp tissue.
      i Check the wet and dry masses for transcription or weighing errors.

# a site or year with a comma or bracket warns, naming the values

    Code
      warn_group_names(data.frame(site = c("North Reef, inner", "b",
        "North Reef, inner"), year = "2020"), "`d`")
    Condition
      Warning:
      Column `site` of `d` has value "North Reef, inner" containing a comma or square bracket.
      i Parameter names such as `site_year_effect[<site>,<year>]` built from such values cannot be split back into their levels by tools that parse them.

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

---

    Code
      warn_implausible_units(data.frame(area_m2 = c(4e+05, 2e+05)), "`d`")
    Condition
      Warning:
      Column `area_m2` of `d` has median 3e+05, which is unusually large for square metres.
      i Check that area_m2 is in square metres.

---

    Code
      warn_implausible_units(data.frame(wet_mass_g = c(4000, 5000)), "`d`")
    Condition
      Warning:
      Column `wet_mass_g` of `d` has median 4500, which is unusually large for grams.
      i Check that wet_mass_g is in grams.

---

    Code
      warn_implausible_units(data.frame(tide_height_m = c(50, 120)), "`d`")
    Condition
      Warning:
      Column `tide_height_m` of `d` has median 85, which is unusually large for metres.
      i Check that tide_height_m is in metres.

# values beyond half the minimum or twice the maximum warn

    Code
      warn_outside_range(fit, c(3, 30, 150), "diameter_mm")
    Condition
      Warning:
      2 values of diameter_mm lie far outside the fitted range (10 to 50).
      i Check that the values are in millimetres.

# a column without a unit gets no unit hint

    Code
      warn_outside_range(fit_with(fronds = c(1, 20)), 100, "fronds")
    Condition
      Warning:
      1 value of fronds lies far outside the fitted range (1 to 20).

