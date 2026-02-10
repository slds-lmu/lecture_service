#' Render the slide status HTML report
#'
#' Renders the slide status overview site from the `slide_status.Rmd`
#' template bundled with the package. Requires the slide check cache
#' produced by [check_slides_many()] (see [slide_cache_path()]).
#'
#' @param output_dir Character. Directory for the output HTML and assets.
#'   Defaults to the current working directory.
#' @param quiet Logical. If `TRUE` (default), suppress rmarkdown progress.
#' @param ... Additional arguments passed to [rmarkdown::render()].
#'
#' @return The path to the rendered HTML file (invisibly), as returned by
#'   [rmarkdown::render()].
#'
#' @export
#' @examples
#' \dontrun{
#' # After running check_slides_many():
#' render_slide_status()
#' }
render_slide_status <- function(output_dir = ".", quiet = TRUE, ...) {
  output_dir <- normalizePath(output_dir, mustWork = TRUE)

  rmd_path <- system.file("slide_status.Rmd", package = "lese")
  if (rmd_path == "") {
    cli::cli_abort(
      "Could not find {.file slide_status.Rmd} in the {.pkg lese} package installation."
    )
  }

  cli::cli_alert_info("Rendering slide status report")

  rmarkdown::render(
    input = rmd_path,
    output_dir = output_dir,
    knit_root_dir = output_dir,
    envir = new.env(parent = globalenv()),
    quiet = quiet,
    ...
  )
}


#' Render the slide status PR markdown table
#'
#' Renders a simplified markdown version of the slide status for use in
#' pull request comments. Uses the `slide_status_pr.Rmd` template bundled
#' with the package. Requires the slide check cache produced by
#' [check_slides_many()] (see [slide_cache_path()]).
#'
#' @inheritParams render_slide_status
#'
#' @return The path to the rendered markdown file (invisibly).
#'
#' @export
#' @examples
#' \dontrun{
#' # After running check_slides_many():
#' render_slide_status_pr()
#' }
render_slide_status_pr <- function(output_dir = ".", quiet = TRUE, ...) {
  output_dir <- normalizePath(output_dir, mustWork = TRUE)

  rmd_path <- system.file("slide_status_pr.Rmd", package = "lese")
  if (rmd_path == "") {
    cli::cli_abort(
      "Could not find {.file slide_status_pr.Rmd} in the {.pkg lese} package installation."
    )
  }

  cli::cli_alert_info("Rendering slide status PR table")

  out <- rmarkdown::render(
    input = rmd_path,
    output_dir = output_dir,
    output_format = "github_document",
    output_file = "slide_status_pr.md",
    knit_root_dir = output_dir,
    envir = new.env(parent = globalenv()),
    quiet = quiet,
    ...
  )

  # rmarkdown also creates a spurious HTML file — clean it up
  html_file <- fs::path(output_dir, "slide_status_pr.html")
  if (fs::file_exists(html_file)) {
    fs::file_delete(html_file)
  }

  invisible(out)
}
