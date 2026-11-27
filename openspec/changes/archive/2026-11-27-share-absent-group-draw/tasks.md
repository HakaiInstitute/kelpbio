## 1. Group resolution

- [x] 1.1 In the random-effect resolvers, group new-level labels with a missing label as one level, and remove the branches that give each missing-label row its own draw
- [x] 1.2 Key the site:year draw on site and year so rows of one site without a `year` column share one draw, and rows of different sites do not
- [x] 1.3 Check that `representative_site` and the support columns still treat an absent column as before

## 2. Validation message

- [x] 2.1 Make the missing-value hint for `site` and `year` suggest a name such as `"new"` or leaving out the column, and update its snapshot

## 3. Tests

- [x] 3.1 Add resolver tests that rows with a missing label share one draw, that a missing label does not share with a level named `"NA"`, and that rows of different sites without a year draw separate site:year effects
- [x] 3.2 Add a `posterior_epred()` test that a weight curve with no `year` column equals the same rows with `year = "new"` under one seed
- [x] 3.3 Add a `kb_predict_mean_weight()` test that sites of a grid without a `year` column share one new year under `"sample"`
- [x] 3.4 Run `Rscript scripts/build.R` and report any snapshot diffs under `"sample"`, leaving the `.new` files for review

## 4. Reader docs

- [x] 4.1 State in the `new_levels` documentation in `R/params.R` (both versions) that rows without a `site` or `year` column share one new site or year, and that separately named new levels are independent
- [x] 4.2 Check the `kb_new_data()` details, the Advanced and Methods articles, and the specs against the new rule

## 5. Archive

- [x] 5.1 Run `jarl check .` and `openspec archive share-absent-group-draw --yes` before review of the pull request into `main`
