test_that(".fit_constructors reads the registered methods rather than a fixed list", {
  constructors <- .fit_constructors("kb_predict_weight")
  expect_setequal(
    constructors,
    c("kb_fit_weight_nereo", "kb_fit_weight_macro")
  )
  # Every name returned is an exported function that really has a method for the
  # generic, so adding a sub-model updates the hint without touching this code.
  for (constructor in constructors) {
    expect_true(constructor %in% getNamespaceExports(asNamespace("kelpbio")))
    expect_false(is.null(
      utils::getS3method("kb_predict_weight", constructor, optional = TRUE)
    ))
  }
})

test_that(".fit_constructors is empty for a generic that takes any fit", {
  # kb_fit is a parent class, not a constructor, so there is nothing to name.
  expect_length(.fit_constructors("kb_stancode"), 0)
  expect_length(.fit_constructors("samples"), 0)
})

test_that(".abort_no_method names the generic, the class, and the constructors", {
  fake <- structure(list(), class = c("kb_fit_weight_other", "kb_fit_weight"))
  expect_snapshot(
    error = TRUE,
    .abort_no_method("kb_predict_weight", fake)
  )
})

test_that(".abort_no_method falls back to the name pattern when no constructor applies", {
  expect_snapshot(
    error = TRUE,
    .abort_no_method("kb_stancode", structure(list(), class = "kb_fit_other"))
  )
})

test_that(".abort_no_method always aborts", {
  expect_error(.abort_no_method("kb_stancode", weight_fit))
})

test_that("a public verb on a fit with no methods aborts rather than returning", {
  fake <- structure(
    list(data = data.frame(weight = 1), meta = list()),
    class = c("kb_fit_other", "kb_fit")
  )
  expect_error(log_lik(fake), "no method for a <kb_fit_other>")
  expect_error(residuals(fake), "no method for a <kb_fit_other>")
  expect_error(fitted(fake), "no method for a <kb_fit_other>")
  expect_error(augment(fake), "no method for a <kb_fit_other>")
})

test_that("the internal-generic form names no generic, argument or constructor", {
  expect_snapshot(
    error = TRUE,
    .log_lik(structure(list(), class = c("kb_fit_other", "kb_fit")), 1)
  )
})

test_that("every internal generic has a default, and only display ones are total", {
  # Discovered from the registrations rather than listed by hand, so a generic
  # added without a default is caught on the day it is added. Both sets are
  # pinned, so a new generic cannot join either silently: it has to be classed
  # as one that aborts or one that is allowed a value.
  ns <- asNamespace("kelpbio")
  nms <- ls(ns, all.names = TRUE)
  generics <- sort(unique(sub(
    "\\.default$",
    "",
    grep("^\\..*\\.default$", nms, value = TRUE)
  )))

  # .fit_descriptor is the one deliberate total default: it supplies print()'s
  # header fields, so a missing method degrades a display rather than producing a
  # wrong number. Every generic that feeds a number aborts instead.
  total <- ".fit_descriptor"
  expect_setequal(intersect(generics, total), total)

  aborting <- setdiff(generics, total)
  expect_setequal(
    aborting,
    c(
      ".add_noise",
      ".chk_new_data",
      ".deviance",
      ".epred",
      ".linpred",
      ".log_lik"
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
    # dispatch through the generic, so this proves the default is what a fit with
    # no method actually reaches, not merely that it aborts when called directly
    call_args <- c(list(fake), rep(list(1), length(required) - 1L))
    expect_error(
      do.call(fun, call_args),
      "no method for a <kb_fit_other>",
      info = generic
    )
  }
})
