#' Stan code of a fit
#'
#' The Stan source code of the fitted model, without comments.
#'
#'
#' @inheritParams params
#' @returns A `kb_stancode` object, which prints as formatted code. Use
#'   [as.character()] for the plain string.
#' @family fit methods
#' @export
#'
#' @examples
#' kb_stancode(fit_weight_sim_nereo)
kb_stancode <- function(fit, ...) {
  rlang::check_dots_empty()
  .chk_kb_fit(fit)
  # as.character() drops the model_name attribute rstan::get_stancode() carries.
  code <- .strip_stan_comments(as.character(fit$meta$stancode))
  structure(code, class = "kb_stancode")
}

# String literals are not special-cased (the bundled models contain none).
.strip_stan_comments <- function(code) {
  code <- gsub("(?s)/\\*.*?\\*/", "", code, perl = TRUE)
  lines <- strsplit(code, "\n", fixed = TRUE)[[1]]
  stripped <- sub("[[:space:]]+$", "", sub("//.*$", "", lines))
  # drop comment-only lines
  comment_only <- nzchar(trimws(lines)) & !nzchar(trimws(stripped))
  stripped <- stripped[!comment_only]
  blank <- !nzchar(stripped)
  stripped <- stripped[!(blank & c(FALSE, blank[-length(blank)]))]
  nonblank <- which(nzchar(stripped))
  if (length(nonblank)) {
    stripped <- stripped[seq(min(nonblank), max(nonblank))]
  }
  paste(stripped, collapse = "\n")
}
