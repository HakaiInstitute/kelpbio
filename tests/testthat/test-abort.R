test_that("a public verb on a fit with no methods aborts rather than returning", {
  fake <- structure(
    list(data = data.frame(weight_kg = 1), meta = list()),
    class = c("kb_fit_other", "kb_fit")
  )
  expect_error(log_lik(fake), "no method for a <kb_fit_other>")
  expect_error(residuals(fake), "no method for a <kb_fit_other>")
  expect_error(fitted(fake), "no method for a <kb_fit_other>")
  expect_error(augment(fake), "no method for a <kb_fit_other>")
})

test_that(".abort_no_method names the unsupported class", {
  expect_snapshot(
    error = TRUE,
    .obs_family(structure(list(), class = c("kb_fit_other", "kb_fit")), 1)
  )
})

test_that("every internal generic has a default, and only display ones are total", {
  # Discovered from the registrations, so a new generic must be classed here.
  ns <- asNamespace("kelpbio")
  nms <- ls(ns, all.names = TRUE)
  generics <- sort(unique(sub(
    "\\.default$",
    "",
    grep("^\\..*\\.default$", nms, value = TRUE)
  )))

  total <- ".fit_descriptor"
  expect_setequal(intersect(generics, total), total)

  aborting <- setdiff(generics, total)
  expect_setequal(
    aborting,
    c(
      ".chk_new_data",
      ".epred",
      ".grid_columns",
      ".linpred",
      ".log_prior_density",
      ".model_spec",
      ".obs_family",
      ".plant_sizes"
    )
  )

  fake <- structure(list(), class = c("kb_fit_other", "kb_fit"))
  for (generic in aborting) {
    fun <- get(generic, envir = ns)
    args <- formals(fun)
    required <- names(args)[vapply(
      args,
      function(a) identical(a, quote(expr = )),
      logical(1)
    )]
    # Through the generic, so the default is what a fit with no method reaches.
    call_args <- c(list(fake), rep(list(1), length(required) - 1L))
    # .log_prior_density() dispatches on priors and has its own message.
    expect_error(
      do.call(fun, call_args),
      "no (method|log density) for a <kb_fit_other>",
      info = generic
    )
  }
})

test_that(".with_call re-attributes an error to the given call", {
  f <- function(x) .with_call(chk::chk_number(x), rlang::current_env())
  err <- rlang::catch_cnd(f("a"), "error")
  expect_identical(err$call, quote(f("a")))
  expect_identical(.with_call(1 + 1, quote(f())), 2)
})
