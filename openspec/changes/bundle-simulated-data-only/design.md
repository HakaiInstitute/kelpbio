## Context

Records why the real Hakai data and a heavy fit leave the public code package, and
why the existing pre-fit is renamed rather than rebuilt.

## Decisions

- **Code package ships fixtures, not client data.** Confidential client data and a
  large inference-grade fit (`log_lik`/`yrep` scale with n_obs) do not belong in the
  public code package. The standard split is a companion data package
  (`kelpbiodata`), mirroring the poissonconsulting package/data-package pattern.
  kelpbio therefore bundles only a small simulated dataset and a slim simulated fit
  for examples and tests.
- **Rename, do not refit.** The committed `fit_weight_hakai_nereo.rda` was already a
  fit to the simulated downsample (its own doc said so); only the name was
  misleading. It is re-saved as `fit_weight_sim_nereo` from the existing object, which
  preserves the maintainer-built draws and avoids an MCMC run and snapshot churn.
- **`kelpbiodata` is deferred.** This change only removes the real data/fit from
  kelpbio; the companion package is set up separately. The real data is recoverable
  from git history and the maintainer's source to seed it.

## Migration Plan

Additive/removal only; no code-path changes. Downstream that referenced
`fit_weight_hakai_nereo` / `data_weight_hakai_nereo` is repointed to the simulated
objects. Users who need the real fitted model will load it from `kelpbiodata`.
