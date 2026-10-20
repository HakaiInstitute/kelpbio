#' Completed fraction of a running task
#'
#' The proportion completed by a fit, [kb_predict_mean_weight()], or
#' [kb_predict_biomass_survey()] writing to `progress_dir`, as a number from 0
#' to 1.
#'
#' @details
#' Pass the same directory given as `progress_dir` to a `kb_fit_*` function,
#' `kb_predict_mean_weight()`, or `kb_predict_biomass_survey()`. This reads
#' progress from another R process: for
#' example, a Shiny app can run the task in the background and poll
#' `kb_progress()` from the main session to drive a progress indicator. It
#' returns `0` before the task has written anything and `1` once it has finished.
#' Use a separate directory for each task.
#'
#' @param progress_dir A string giving the directory passed as `progress_dir` to
#'   the task.
#' @returns A number between 0 and 1.
#' @family fit functions
#' @export
#' @examples
#' progress_dir <- tempfile()
#' dir.create(progress_dir)
#' # Before a task has written anything, progress is 0.
#' kb_progress(progress_dir)
kb_progress <- function(progress_dir) {
  chk::chk_string(progress_dir)
  read_prediction_progress(progress_dir) %||% read_progress_fraction(progress_dir)
}
