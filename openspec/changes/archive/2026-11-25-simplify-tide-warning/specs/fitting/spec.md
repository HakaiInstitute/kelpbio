## REMOVED Requirements

### Requirement: Surveys past the tide limit are flagged
**Reason**: The tide limit (one over the tide slope) and its 5% prior-probability warning are replaced by a fixed 2 m warning; what happens past the limit is no longer specified beyond finite results.
**Migration**: See "Surveys at high tides are flagged".

## ADDED Requirements

### Requirement: Surveys at high tides are flagged

The cover calibration fits SHALL warn when a survey with positive canopy has `canopy_tide_height_m` above 2 m, giving the number of such surveys and advising imagery at lower tides, since above 2 m the tide correction is large. The warning SHALL NOT stop the fit. The fit's log-likelihood SHALL be finite at any finite tide height, and a survey with no canopy SHALL keep zero cover. The message is pinned by `tests/testthat/_snaps/warn.md`.

#### Scenario: A survey flown at 3.5 m warns
- **WHEN** a *Nereocystis* cover calibration is fitted and one survey with canopy has `canopy_tide_height_m` of 3.5
- **THEN** a warning gives one survey, and the fit proceeds

#### Scenario: Surveys at ordinary tides raise no tide warning
- **WHEN** every survey has `canopy_tide_height_m` at or below 2, including negative tide heights, or a survey above 2 m has no canopy
- **THEN** no tide warning is issued

#### Scenario: The log-likelihood is finite at any tide
- **WHEN** the log-likelihood of a cover calibration fit is computed at a survey with canopy at tide heights of 2, 3.5, and 5 m
- **THEN** every draw's value is finite
