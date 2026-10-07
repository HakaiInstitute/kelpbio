# announce_sampling nudges only when idle cores exist

    Code
      announce_sampling(4L, 1L)
    Message
      i Sampling 4 chains one at a time. Set `cores` (e.g. `cores = 4`) to run them in parallel and finish sooner.

# a reserved sampler argument errors in the fit function before sampling

    Code
      kb_fit_wetdry_nereo(data_wetdry_sim_nereo, iter = 10, progress = "none")
    Condition
      Error in `kb_fit_wetdry_nereo()`:
      ! `iter` cannot be passed to the sampler: kelpbio sets it itself.
      i Use `niters` instead.

