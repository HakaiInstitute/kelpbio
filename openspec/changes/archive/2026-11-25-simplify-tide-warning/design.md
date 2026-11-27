## Context

The archived `bound-tide-correction` change kept the Timmer et al. (2024) form, canopy divided by one minus `tide_height_slope` times tide height, and capped it where the denominator reaches zero.
It warned when a row was past that point on more than 5% of draws (predictions) or with more than 5% truncated-Normal prior probability (fits).
The cap is needed to keep predictions finite; the share-based warning and the "tide limit" wording around it are what make the docs hard to follow.

## Goals / Non-Goals

**Goals:**

- One rule users can apply before flying or fitting: imagery at 2 m or below.
- Reader docs that state the correction without the tide limit.

**Non-Goals:**

- Changing the correction, the cap, or the default priors.

## Decisions

### A fixed 2 m threshold, not a share of draws

The warning fires on `canopy_tide_height_m > 2` for rows with canopy.
With the default priors (means 0.276 and 0.227 per metre), the point where the correction has no finite value lies near 3.6 m (*Nereocystis*) and 4.4 m (*Macrocystis*), so below 2 m it is reached only with a slope prior far above the default.
At 2 m the correction already multiplies canopy by about 2.2 and 1.8, so the warning flags a large correction well before the cap applies.

Alternative: keep the share-based warning and only reword the docs.
Rejected: the warning still depends on the slope's draws or prior, so its trigger cannot be stated as a tide height.

Alternative: derive the threshold from the prior (e.g., where the prior mean multiplies canopy by 2).
Rejected: a number that moves with the prior is harder to state and to act on in the field; 2 m is also the survey-practice limit the analysis flights met.

### Warn, not error

Chart-datum tides in British Columbia reach about 5 m, and such imagery remains usable with a large correction; the earlier change rejected a hard 2 m input cap for this reason.

### Same call sites

The warning is raised where the tide-limit warning was (the fits, `kb_predict_cover_calibration()` with `new_data`, and `kb_predict_biomass_canopy()`), not in the data checks.
Moving it into the checks would also raise it from `kb_check_data_survey_in_situ()` and the canopy check, a wider behaviour change than this simplification needs.

### The cap past the limit stays, described only in code

The branch that returns full cover (or the classified area) once the denominator reaches zero stays as a guard keeping predictions finite.
Specs state the observable guarantee (finite, non-negative, capped) rather than the branch, and the Stan and R comments keep the exact rule for code readers.

### No upper bound on the tide slope

The slope keeps its lower bound of 0 (a negative slope would make canopy grow with the tide) and loses its upper bound of 0.5 per metre.
The slope is informed almost only by its prior, and with the default priors the bound holds essentially no prior mass, so it changes nothing.
Its only effect is on a user prior with mass above 0.5, which it truncates without telling the user.

Alternative: keep the bound, so that one over the bound (2 m) equals the warning threshold and every capped row is warned.
Rejected: it protects only users who chose an extreme prior, by silently fitting a different prior than theirs, and it costs a shared constant, a Stan data field, and a bounded-prior form in `kb_model_describe()`.

## Risks / Trade-offs

- [A user sets a slope prior with mass above 0.5 per metre, so the cap applies below 2 m without a warning] → Accepted: the result stays finite and capped, and follows from the prior the user chose. Such a prior means more than half the canopy lost per metre, about twice the default prior means.
- [Rows between 2 m and the cap get the same warning as rows past it] → Accepted: both are corrections large enough to warrant lower-tide imagery, and the totals stay finite and capped.
