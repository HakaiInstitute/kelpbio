## Decisions

### Filter when reading, not when storing

Omitted effects are filtered out when draws and diagnostics are read, through two
helpers keyed on the fit's recorded terms, rather than dropped from the stored
draws at fit time. Existing fits, including the bundled pre-fits and fits in a
companion data package, then behave correctly without being refitted.
