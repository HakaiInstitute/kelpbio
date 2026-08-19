#' Stan Source for a Model Fit
#'
#' The Stan source code of the fitted model, with comments stripped for a clean
#' read. The raw source (comments included) is stored on the fit in
#' `fit$meta$stancode`.
#'
#' @param fit A `kb_fit` object.
#' @param ... Unused.
#'
#' @return A `kb_stancode` object: the comment-stripped Stan source string, which
#'   prints as readable code. Use [as.character()] for the plain string.
#' @family generics
#' @export
#'
#' @examples
#' kb_stancode(fit_weight_sim_nereo)
kb_stancode <- function(fit, ...) {
  UseMethod("kb_stancode")
}

#' @export
kb_stancode.default <- function(fit, ...) {
  .chk_kb_fit(fit, call = rlang::current_env())
  .abort_no_method("kb_stancode", fit, call = rlang::current_env())
}

#' @rdname kb_stancode
#' @export
kb_stancode.kb_fit <- function(fit, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
  # as.character() drops the model_name attribute rstan::get_stancode() carries.
  code <- .strip_stan_comments(as.character(fit$meta$stancode))
  structure(code, class = "kb_stancode")
}

# Strip Stan comments (`//` line and `/* */` block) for display: comment-only
# lines are dropped and runs of blank lines collapsed. String-literal contents
# are not special-cased (the bundled models contain none).
.strip_stan_comments <- function(code) {
  code <- gsub("(?s)/\\*.*?\\*/", "", code, perl = TRUE)
  lines <- strsplit(code, "\n", fixed = TRUE)[[1]]
  stripped <- sub("[[:space:]]+$", "", sub("//.*$", "", lines))
  # drop lines that held only a comment (non-blank before, blank after)
  comment_only <- nzchar(trimws(lines)) & !nzchar(trimws(stripped))
  stripped <- stripped[!comment_only]
  # collapse consecutive blank lines into one
  blank <- !nzchar(stripped)
  stripped <- stripped[!(blank & c(FALSE, blank[-length(blank)]))]
  # trim leading and trailing blank lines
  nonblank <- which(nzchar(stripped))
  if (length(nonblank)) {
    stripped <- stripped[seq(min(nonblank), max(nonblank))]
  }
  paste(stripped, collapse = "\n")
}
