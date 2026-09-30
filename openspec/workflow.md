# How kelpbio uses OpenSpec

OpenSpec keeps a short, reviewable statement of what the package does
(`openspec/specs/`) and records each behaviour change as a proposal with a delta
against that statement. Upstream documentation:
<https://github.com/Fission-AI/OpenSpec>.

## What lives where

| Home | Holds |
|---|---|
| `openspec/specs/` (`fitting`, `predictions`, `summaries`) | What a user can rely on: arguments, returned values, validation, messages, errors |
| Code, tests, snapshots | The exact model (`tests/testthat/_snaps/kb_model_describe.md`), outputs, and parameter and prior lists |
| `CLAUDE.md` | Coding, testing, and documentation conventions; commands |
| `openspec/config.yaml` | Rules for writing change artifacts |
| `decisions/` | Rationale that outlives a change (engine choice, prediction engine, species as variants, architecture) |
| A change's `design.md` | Rationale for that change, archived with it |

## When to open a change

Open a change for new or changed behaviour a user can observe, including any change
to a model. Bug fixes that restore specified behaviour, refactors, tests, and
documentation do not need one; the PR description says `Spec impact: none`.

## A change

1. `openspec new change <name>` (or `/opsx:propose`).
2. `proposal.md`: why, what changes, non-goals.
3. Delta specs under `specs/<capability>/spec.md`: the requirements added, modified,
   or removed, in behaviour terms.
4. `design.md` only when there are decisions with alternatives worth recording.
5. `tasks.md`: the implementation steps.

Review the delta specs and the snapshot diffs; together they show what changes for
users.

## Done, in the same PR

- Code and tests pass in CI; reader docs (roxygen, README, vignette) are updated.
- Specs and reader docs are checked against the code.
- The change is archived: `openspec archive <name> --yes` merges the deltas into
  `openspec/specs/` and files the folder under `openspec/changes/archive/`.

Keep at most one open change per capability, so two deltas never rewrite the same
requirement.

## Writing specs

- State behaviour, not implementation: no Stan data fields, parameter or prior
  lists, `meta` fields, internal functions, or file layout.
- Where output is pinned by a snapshot or test, cite it instead of restating it.
- Prefer one general requirement (for example, an omitted effect is absent from
  every summary) over a copy per case.
