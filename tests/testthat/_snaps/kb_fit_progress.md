# kb_fit_progress validates progress_dir

    Code
      kb_fit_progress(1)
    Condition
      Error in `kb_fit_progress()`:
      ! `progress_dir` must be a string (non-missing character scalar).

---

    Code
      kb_fit_progress(c("a", "b"))
    Condition
      Error in `kb_fit_progress()`:
      ! `progress_dir` must be a string (non-missing character scalar).

