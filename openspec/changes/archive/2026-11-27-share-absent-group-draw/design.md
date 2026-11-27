## Context

Group resolution reads each grouping column of the prediction rows as a level index and a label.
An absent column is recorded as a missing label on every row, and the two random-effect resolvers each give every such row a draw of its own.
Rows that name a new level already share one draw through their label.

## Goals / Non-Goals

**Goals:**

- An absent `site` or `year` column behaves exactly as one named new level on every row.
- One rule for new levels in the code, spec, and docs.

**Non-Goals:**

- Accepting missing values in `site` or `year` as new levels.
- Changing `kb_new_data()` to always return both grouping columns.

## Decisions

### Group a missing label as one level

The resolvers already share one draw among rows with the same new-level label.
They now group labels with `NA` treated as a value of its own, so the rows of an absent column form one new level, and a missing year keeps each site's rows apart for the site:year effect.
The branches that gave each missing-label row its own draw are removed.
A missing label can only come from an absent column, because a missing value in `new_data` errors, so it cannot be confused with a user's level.

Alternatives:

- Give an absent column a placeholder label where the grid is read.
  Rejected: the label must be chosen so that no user value can equal it, which a missing label already guarantees.
- Keep the per-row branches and patch each resolver to put missing labels in one group, keying a missing year (or site) with a placeholder for the site:year effect.
  Rejected: it adds code to two places and keeps a special case each future resolver must remember.

### Missing values stay an error

Accepting `NA` as a new level would let a blank cell from a spreadsheet or a failed join pass silently, widening intervals under `"sample"` or replacing a real year with the typical one under `"average"`.
A name also states which rows share a level (`"new"` on five rows) and which are independent (`"new_a"`, `"new_b"`), which `NA` cannot.
The error hint is made concrete by suggesting `"new"`.

## Risks / Trade-offs

- Users who relied on independent per-row draws for an absent column get shared draws.
  Pre-release, so no deprecation; naming levels separately gives the old behaviour.
- Fewer random numbers are drawn, so outputs under `"sample"` with an absent column change for a given seed.
  Snapshots affected are reviewed with the change.
