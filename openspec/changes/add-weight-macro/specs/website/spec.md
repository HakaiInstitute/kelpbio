## MODIFIED Requirements

### Requirement: The reference index is organized into thematic sections

The `_pkgdown.yml` reference index SHALL list topics explicitly (not via
`matches()`) and SHALL include the *Macrocystis* weight topics alongside the
*Nereocystis* ones: `kb_fit_weight_macro`, `kb_priors_weight_macro`,
`kb_check_data_weight_macro`, `data_weight_sim_macro`, and
`fit_weight_sim_macro`.

#### Scenario: Macro topics appear in the reference index
- **WHEN** the pkgdown site is built
- **THEN** the reference index includes `kb_fit_weight_macro`,
  `kb_priors_weight_macro`, `kb_check_data_weight_macro`,
  `data_weight_sim_macro`, and `fit_weight_sim_macro`, each resolving to a
  documented topic
