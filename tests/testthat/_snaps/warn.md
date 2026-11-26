# warn_carbon_fraction counts samples outside 0.10 to 0.50 and keeps them

    Code
      out <- warn_tissue_ratio(odd, "carbon", "`d`")
    Condition
      Warning:
      2 samples in `d` have carbon fractions outside 0.10 to 0.50, the plausible range for kelp tissue.
      i Check that carbon_mass_ug is in micrograms and sample_mass_mg in milligrams.

# warn_nitrogen_fraction counts samples outside 0.002 to 0.05 and keeps them

    Code
      out <- warn_tissue_ratio(odd, "nitrogen", "`d`")
    Condition
      Warning:
      2 samples in `d` have nitrogen fractions outside 0.002 to 0.05, the plausible range for kelp tissue.
      i Check that nitrogen_mass_ug is in micrograms and sample_mass_mg in milligrams.

# warn_dry_wet_ratio counts samples outside 0.02 to 0.5 and keeps them

    Code
      out <- warn_tissue_ratio(odd, "dry_wet", "`d`")
    Condition
      Warning:
      2 samples in `d` have dry:wet mass ratios outside 0.02 to 0.50, the plausible range for kelp tissue.
      i Check the wet and dry masses for transcription or weighing errors.

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
      warn_implausible_units(data.frame(survey_area_m2 = c(4e+05, 2e+05)), "`d`")
    Condition
      Warning:
      Column `survey_area_m2` of `d` has median 3e+05, which is unusually large for square metres.
      i Check that survey_area_m2 is in square metres.

---

    Code
      warn_implausible_units(data.frame(wet_mass_g = c(4000, 5000)), "`d`")
    Condition
      Warning:
      Column `wet_mass_g` of `d` has median 4500, which is unusually large for grams.
      i Check that wet_mass_g is in grams.

---

    Code
      warn_implausible_units(data.frame(canopy_tide_height_m = c(50, 120)), "`d`")
    Condition
      Warning:
      Column `canopy_tide_height_m` of `d` has median 85, which is unusually large for metres.
      i Check that canopy_tide_height_m is in metres.

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

# a surveyed area above the plot area warns

    Code
      warn_survey_area(d, "`d`")
    Condition
      Warning:
      1 survey in `d` has survey_area_m2 > plot_area_m2.
      i Check that the two columns are not swapped.

# maps of a site-year covering different areas warn

    Code
      warn_partial_maps(d, "`d`")
    Condition
      Warning:
      Some site-years in `d` have maps whose classified_area_m2 differ by more than half.
      i Each map should cover the whole site; combine maps of parts of a site into one row.
      i Site-years: "a:2020".

# rows with canopy above 2 m tide warn

    Code
      warn_high_tide(d, "`d`", rows = "row")
    Condition
      Warning:
      2 rows in `d` have canopy imaged at a canopy_tide_height_m above 2 m.
      i The tide correction is large in this case. It is recommended to fly at tides of 2 m or below where possible.

---

    Code
      warn_high_tide(d[1, ], "`d`", rows = "survey")
    Condition
      Warning:
      1 survey in `d` has canopy imaged at a canopy_tide_height_m above 2 m.
      i The tide correction is large in this case. It is recommended to fly at tides of 2 m or below where possible.

# warn_presence_separation warns only when no empty survey overlaps the occupied in cover

    Code
      warn_presence_separation(data, "`data`")
    Condition
      Warning:
      Every survey in `data` with no plants has a percent canopy cover at or below every survey with plants.
      i presence_cover_slope then follows its prior. Consider a tighter one, such as `kb_prior_normal(mean = 0, sd = 5)`.

