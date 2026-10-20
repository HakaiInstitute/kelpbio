# Planned vignettes

Vignettes and vignette sections to add in the README/vignette pass. Each entry
gives the reader question it answers and the points it must cover. Wording here
is notes, not reader-facing text; follow `STYLE.md` when writing the vignette.

## Surface surveys from a boat or kayak (*Nereocystis*)

Reader question: can the size and survey biomass functions be used with
data collected from the surface rather than by divers, and what do the results
mean?

The models fit these data without change. The vignette is guidance on survey
design and interpretation.

Survey design:

- Quadrats are placed randomly or systematically within a defined survey area,
  not opportunistically over visible canopy. Record what that area is, since it
  is the area the counts apply to.
- Use a fixed rule for bulbs on the quadrat edge (e.g. count bulbs touching two
  adjacent sides, not the other two).
- Sum counts and areas over each cluster of quadrats (along a line or in a
  group) to one survey row (`plants`, `survey_area_m2` in
  `kb_check_data_survey()`), giving each cluster its own `plot_id`.
  Independently placed quadrats are one row each.
- Survey at low slack tide, so the fewest bulbs are submerged.
- Size: measure every plant in each quadrat (or a random subset), using the
  maximum sub-bulb diameter, the weight model's predictor. Do not select plants
  by size or reachability.

Interpretation:

- Counts and sizes are of surface-reaching plants only, so survey biomass is
  surface biomass: a lower bound on true standing biomass. The gap is largest
  early in the season and under strong current.
- Results are not directly comparable with diver-based estimates as the same
  quantity.
- Without harvest data, the weight model is borrowed from another programme, so
  biomass assumes that programme's allometry applies, and the intervals do not
  include variation in the allometry between programmes.
