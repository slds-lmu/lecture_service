#' Render a chapter audit report
#'
#' Renders an HTML report auditing the script-figure-slide dependency chain
#' for a lecture. Uses the `chapter_audit.Rmd` template bundled with the
#' package.
#'
#' @param lecture_dir Character. Path to the lecture directory.
#'   Defaults to the current working directory.
#' @param chapters Character vector of chapter names to audit, or `NULL`
#'   (default) to audit all chapters.
#' @param pattern Regex pattern to filter script filenames.
#'   Default `"[.]R$"` matches all `.R` files.
#' @param timeout Numeric. Per-script timeout in seconds. Default 300.
#' @param run Logical. If `TRUE`, execute scripts and track produced figures.
#'   Default `FALSE`.
#' @param output_dir Character. Directory for the output HTML file.
#'   Defaults to `lecture_dir`.
#' @param ... Additional arguments passed to [rmarkdown::render()].
#'
#' @return The path to the rendered HTML file (invisibly), as returned by
#'   [rmarkdown::render()].
#'
#' @export
#' @examples
#' \dontrun{
#' # From within a lecture directory (e.g. lecture_i2ml/)
#' render_chapter_audit()
#'
#' # From lecture_service root
#' render_chapter_audit(lecture_dir = "lecture_i2ml")
#'
#' # Audit specific chapters with script execution
#' render_chapter_audit(
#'   chapters = c("cart", "evaluation"),
#'   run = TRUE
#' )
#' }
render_chapter_audit <- function(
  lecture_dir = ".",
  chapters = NULL,
  pattern = "[.]R$",
  timeout = 300,
  run = FALSE,
  output_dir = lecture_dir,
  ...
) {
  lecture_dir <- normalizePath(lecture_dir, mustWork = TRUE)
  output_dir <- normalizePath(output_dir, mustWork = TRUE)

  rmd_path <- system.file("chapter_audit.Rmd", package = "lese")
  if (rmd_path == "") {
    cli::cli_abort(
      "Could not find {.file chapter_audit.Rmd} in the {.pkg lese} package installation."
    )
  }

  cli::cli_alert_info(
    "Rendering chapter audit for {.path {basename(lecture_dir)}}"
  )

  rmarkdown::render(
    input = rmd_path,
    output_dir = output_dir,
    params = list(
      lecture_dir = lecture_dir,
      chapters = chapters,
      pattern = pattern,
      timeout = timeout,
      run = run
    ),
    envir = new.env(parent = globalenv()),
    ...
  )
}
