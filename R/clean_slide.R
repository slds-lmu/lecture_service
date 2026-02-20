#' Clean output for a single .tex file
#'
#' Uses `latexmk -C <slide_file>`, also removing the PDF file.
#' Uses `latexmk -c <slide_file>` to keep the PDF file.
#'
#' @inheritParams find_slide_tex
#' @param keep_pdf `[FALSE]`: Keep the PDF file.
#' @param verbose `[FALSE]`: Print additional output to the console.
#' @inheritParams compile_slide
#'
#' @return Invisibly:
#' - If `check_status`, `TRUE` if the exit code is 0, `FALSE` otherwise.
#' - If `check_status` is `FALSE`, `NULL` is returned.
#' @export
#' @examples
#' \dontrun{
#' # Create the PDF
#' compile_slide("slides-cart-computationalaspects.tex")
#'
#'# Remove the PDF and other output
#' clean_slide("slides-cart-computationalaspects.tex")
#' }
clean_slide <- function(
  slide_file,
  keep_pdf = FALSE,
  verbose = FALSE,
  check_status = TRUE
) {
  tmp <- find_slide_tex(slide_file = slide_file)
  res <- NULL

  # .nav ,.snm, ... are not covered by latexmk -C
  check = sapply(c("nav", "snm", "bbl"), \(ext) {
    detritus <- fs::path_ext_set(tmp$tex, ext)
    if (fs::file_exists(detritus)) {
      # if (verbose) cli::cli_alert("Deleting {detritus}")
      fs::file_delete(detritus)
    }
  })

  clean_arg <- if (keep_pdf) "-c" else "-C"

  pc <- processx::process$new(
    command = "latexmk",
    args = c(clean_arg, tmp$slide_name),
    wd = tmp$slides_dir,
    echo_cmd = verbose,
    supervise = check_status
  )

  if (check_status) {
    pc$wait()
    exit <- pc$get_exit_status()
    # I don't see how this should fail, so if it does you dun goof'd
    if (exit != 0) {
      cli::cli_alert_danger(
        "latexmk -C failed for some unholy reason for {slide_file}"
      )
    }

    res <- exit == 0
  }

  invisible(res)
}
