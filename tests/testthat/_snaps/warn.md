# warn_carbon_fraction counts samples outside 0.10 to 0.50 and keeps them

    Code
      out <- warn_carbon_fraction(odd, "`d`")
    Condition
      Warning:
      2 samples in `d` have carbon fractions outside 0.10 to 0.50, the plausible range for kelp tissue.
      i Check that carbon_mass_ug is in micrograms and sample_mass_mg in milligrams.

# warn_nitrogen_fraction counts samples outside 0.002 to 0.05 and keeps them

    Code
      out <- warn_nitrogen_fraction(odd, "`d`")
    Condition
      Warning:
      2 samples in `d` have nitrogen fractions outside 0.002 to 0.05, the plausible range for kelp tissue.
      i Check that nitrogen_mass_ug is in micrograms and sample_mass_mg in milligrams.

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

# a pool_by group holding one site-year twice warns

    Code
      warn_overlapping_canopy(grid, c(1L, 1L))
    Condition
      Warning:
      Some `pool_by` groups hold more than one row for a site-year, so their totals overlap.
      i Each row is a map of the site-year's bed, so the sum counts it once per map.
      i Repeated: "a:2020".

# rows past the tide limit on more than 5% of draws warn

    Code
      warn_tide_cap(c(0.2, 0.01, 0.5), "`d`", rows = "row", cap = "the classified area",
      basis = "on more than 5% of draws")
    Condition
      Warning:
      2 rows in `d` are past the tide limit (canopy_tide_height_m at least 1 / tide_height_slope) on more than 5% of draws.
      i There the corrected canopy is the classified area, not the canopy measured. Fly at lower tides where possible.

# warn_presence_separation warns only when no empty survey overlaps the occupied in cover

    Code
      warn_presence_separation(data, "`data`")
    Condition
      Warning:
      Every survey in `data` with no plants has a percent canopy cover at or below every survey with plants.
      i presence_cover_slope then follows its prior. Consider a tighter one, such as `kb_prior_normal(mean = 0, sd = 5)`.

