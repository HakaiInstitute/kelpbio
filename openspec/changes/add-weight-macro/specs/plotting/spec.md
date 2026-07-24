## MODIFIED Requirements

### Requirement: Metadata-driven, overridable defaults

`kb_plot_predictions()` SHALL derive its defaults from the `kb_predictions`
object's metadata, and all defaults SHALL be overridable by the caller. The
x-axis default SHALL be the predictor carried in the predictions metadata:
diameter for a nereo fit, fronds for a macro fit, labelled accordingly. The
existing defaults (response on the y-axis, grouping aesthetic from `by`, the
`conf_level` band) are unchanged.

#### Scenario: Macro plot uses the fronds predictor on the x-axis
- **WHEN** `kb_plot_predictions()` is called on predictions from a macro fit
- **THEN** the x-axis maps and labels the `fronds` predictor, and the caller can
  override the label
