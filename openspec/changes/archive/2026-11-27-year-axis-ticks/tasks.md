## 1. Axis

- [x] 1.1 In `kb_plot_predictions()`, convert a `year` x-axis whose labels are all whole numbers to integers and draw it on a continuous scale with whole-number breaks
- [x] 1.2 Give every other non-numeric x-axis a discrete scale that drops overlapping tick labels

## 2. Tests

- [x] 2.1 Test that whole-number years give a continuous axis with whole-number breaks, and that a year named `"new"` keeps a discrete axis
- [x] 2.2 Add a `vdiffr` case of columns over many years, run `Rscript scripts/build.R`, and leave the snapshot diffs for review

## 3. Archive

- [x] 3.1 Run `jarl check .` and `openspec archive year-axis-ticks --yes`
