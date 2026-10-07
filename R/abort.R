# Abort for a generic reached with a fit it has no method for (e.g. a sub-model
# added without its methods). Names no generic, since one internal generic serves
# several public verbs the user may have called.
.abort_no_method <- function(x, call = rlang::caller_env()) {
  cli::cli_abort(
    c(
      "kelpbio has no method for a {.cls {class(x)[1]}} object.",
      i = "Supported fits are created by the {.code kb_fit_*()} functions."
    ),
    call = call
  )
}

# Evaluate `expr`, re-attributing any error to `call` (an environment or a call)
# so an error from a shared check bundle names the user's function, not the helper.
.with_call <- function(expr, call) {
  rlang::try_fetch(expr, error = function(cnd) {
    cnd$call <- if (is.environment(call)) rlang::frame_call(call) else call
    stop(cnd)
  })
}
