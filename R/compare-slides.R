#' Compare slide PDF against reference PDF
#'
#' A compiled .tex file such as `slides/gaussian-processes/slides-gp-bayes-lm.pdf` will be compared with
#' an assumed to be accepted / known good version at `slides-pdf/slides-gp-bayes-lm.pdf` if it exists.
#'
#' First uses `diff-pdf-visually` to check slides for differences based on the PSNR of rasterised versions
#' of the slides (adjustable with `thresh_psnr`), and then uses `diff-pdf` to create a PDF highlighting
#' the differences if `create_comparison_pdf` is `TRUE`.
#'
#' This only re-runs `diff-pdf` to create a comparison PDF file if the
#' output file under `./comparison/<slide-name>.pdf` is more recent than both of the input PDF files.
#' That way you can safely re-run this function repeatedly without worrying about computational overhead.
#'
#' @param slide_file `character(1)`: A single slide .tex file (see examples).
#' @param verbose `[TRUE]`: Print additional output to the console.
#' @param create_comparison_pdf `[FALSE]`: Use `diff-pdf` to create a comparison PDF at `./comparison/<slide-name>.pdf`
#' @param thresh_psnr `[40]`: PSNR threshold for difference detection in `diff-pdf-visually`.
#'   Higher is more sensitive.
#' @param dpi_check `[50]` Resolution for rasterised files used by both `diff-pdf-visually`.
#'   Lower is more coarse.
#' @param dpi_out `[100]` Resolution for output PDF produced by `diff-pdf`.
#'   Lower values will lead to very pixelated diff PDFs.
#' @param pixel_tol `[20]` Per-page pixel tolerance for comparison used by `diff-pdf`.
#' @param view `[FALSE] For interactive use: Opens window showing comparison diff.
#' @param overwrite `[FALSE]` Re-creates output diff PDF even if it already exists and appears up to date.
#' @return Invisibly: A list of results:
#'   - passed: TRUE indicates a successful comparison, FALSE a failure.
#'   - reason: Shorthand reason for a failing comparison.
#'   - pages: Vector of pages with differences.
#'   - output: Full output produced by diff-pdf-visually.
#' @export
#
#' @note Uses `diff-pdf-visually` and `diff-pdf` under the hood, you may need to adjust your $PATH.
#'
#' @examples
#' \dontrun{
#' # The "normal" way: A .tex file name
#' compare_slide("slides-cart-computationalaspects.tex")
#'
#' # Also acceptable: A full path (absolute or relative), convenient for scripts
#' compare_slide("lecture_advml/slides/gaussian-processes/slides-gp-bayes-lm.tex")
#'
#' # Lazy way: No extension, just a name
#' compare_slide("slides-cart-predictions")
#'
#' # Whoopsie supplied name of PDF instead no biggie I got u
#' compare_slide("slides-forests-proximities.pdf")
#'
#' compare_slide("slides-boosting-cwb-basics")
#' }
compare_slide <- function(slide_file, verbose = TRUE, create_comparison_pdf = FALSE,
                          thresh_psnr = 40, dpi_check = 50, dpi_out = 100,
                          pixel_tol = 20, view = FALSE, overwrite = FALSE) {

  tmp <- find_slide_tex(slide_file = slide_file)

  result <- list(passed = NA, reason = "", pages = "", signif = "", output = "")

  # Run check again rather than relying on tmp$pdf_exists just in case PDF was just compiled
  if (!(fs::file_exists(tmp$pdf))) {
    if (verbose) cli::cli_alert_warning("{tmp$slide_name}: No compiled PDF")
    result$passed <- FALSE
    result$reason <- "No compiled PDF"
    return(result)
  }

  if (!tmp$pdf_static_exists) {
    if (verbose) cli::cli_alert_warning("{tmp$slide_name}: No reference PDF to compare to")
    result$passed <- FALSE
    result$reason <- "No reference PDF"
    return(result)
  }

  if (!check_system_tool("diff-pdf-visually")) {
    return(result)
  }

  args <- c(
    #"-v",
    sprintf("--threshold=%s", thresh_psnr),
    sprintf("--dpi=%s", dpi_check),
    tmp[["pdf"]], tmp[["pdf_static"]]
  )
  # Might require $PATH adjustments to work
  p <- processx::process$new(
    command = "diff-pdf-visually", args = args,
    stdout = "|", stderr = "|"#,
    #echo_cmd = verbose
  )
  # This is the command that's actually executed in quick "print for debugging" format
  # paste0(c("diff-pdf-visually", args), collapse = " ")

  p$wait()

  # p$get_exit_status()
  # Catch error, usually happens when diff-pdf-visually dependencies are not in $PATH, most likely
  # the ImageMagick `compare` utility.
  error <- p$read_all_error_lines()
  if (length(error) > 0) {
    cli::cli_abort(error[length(error)])
  }

  output <- p$read_all_output_lines()
  keep <- which(!grepl("(^  Temporary directory)|(^  Converting each)|(same number of pages)", output))
  output <- output[keep]

  if (length(output) == 0) {
    # This happens e.g. when $PATH does not include diff-pdf-visually dependencies, but the tool itself
    # Symptom is that `output` contains the first two lines as normal but no actual check output
    cli::cli_abort("Could not parse diff-pdf-visually output correctly for {tmp$slide_name}")
  }

  result$output <- output

  if (grepl("PDFs are the same", output)) {
    if (verbose) cli::cli_alert_success(tmp$slide_name)

    result$passed <- TRUE
  }

  if (grepl("Different number of pages", output)) {
    if (verbose) cli::cli_alert_danger("{tmp$slide_name}: {output}")
    result$passed <- FALSE
    result$reason <- "Differing page count"
    result$pages <- stringr::str_extract(output, "\\d+ vs \\d+")
  }

  if (any(grepl("The most different pages are", x = output))) {
    pages_string <- unlist(stringr::str_extract_all(output, "(page \\d+) \\(sgf\\. (\\d+\\.?\\d+)\\)"))

    different_pages <- pages_string |>
      stringr::str_extract(" \\d+ ") |>
      stringr::str_trim() |>
      as.integer()

    pages_signif <- pages_string |>
      stringr::str_extract(" \\d+\\.\\d+") |>
      stringr::str_trim() |>
      as.numeric() |>
      round(1)

    if (verbose) cli::cli_alert_warning(
      "{tmp$slide_name}: Changes detected in pages: {different_pages} (signif.: {pages_signif})"
    )
    result$passed <- FALSE
    result$reason <- "Dissimilar pages"
    result$pages <- paste(sort(different_pages), collapse = ", ")
    result$signif <- pages_signif
  }

  if (create_comparison_pdf & !result$passed & check_system_tool("diff-pdf")) {

    if (!dir.exists(here::here("comparison"))) dir.create(here::here("comparison"))
    out_path <- fs::path_ext_set(here::here("comparison", tmp$slide_name), "pdf")

    # Check if there's already a comparison file, and update it only if
    # either of the input PDF is more recent
    age_check <- TRUE
    if (fs::file_exists(out_path)) {
      slide_age <- fs::file_info(tmp[["pdf"]])[["modification_time"]]
      slide_static_age <- fs::file_info(tmp[["pdf_static"]])[["modification_time"]]
      comparison_age <- fs::file_info(out_path)[["modification_time"]]

      # Unpleasant nested-if thing but oh well.
      if (comparison_age >= max(slide_age, slide_static_age)) {
        if (verbose) cli::cli_inform("Comparison PDF appears up to date already!")
        age_check <- FALSE
      }

      if (fs::file_size(out_path) == 0) {
        if (verbose) cli::cli_inform("Comparison PDF is empty, recreating...")
        age_check <- TRUE
      }
    }

    if (age_check | view | overwrite) {
      if (verbose & !view) cli::cli_inform("Creating diff PDF at {.file {fs::path_rel(out_path)}}")
      args <- c(
        # Red highlight on the left side to highlight small differences
        "--mark-differences",
        # Total number of pixels allowed to be different per page before specifying the page is different
        # Not sure what a useful value here would be
        paste0("--per-page-pixel-tolerance=", pixel_tol),
        paste0("--dpi=", dpi_out),
        # Maybe skip identical pages? Not sure if that makes it actually easier
        "--skip-identical",
        # Input and reference PDF paths
        tmp[["pdf"]], tmp[["pdf_static"]]
      )

      # If we want to view interactively, --output-diff must not be passed apparently.
      if (view) {
        args <- c("--view", args)
      } else {
        args <- c(paste0("--output-diff=", out_path), args)
      }

      p <- processx::process$new(
        command = "diff-pdf", args = args, stdout = "|", stderr = "|"#,
        #echo_cmd = verbose
      )

      p$get_exit_status()
      out <- p$read_all_output_lines()
      err <- p$read_all_error_lines()

      # Haven't found good way to check if this worked though
      # Got exit status == 1 even though resulting PDF looked fine
      # Sometimes output PDF is 0B for some reason, re-running fixes it. Don't know what happens there.
      if (!view) {
        p$wait()

        if (!fs::file_exists(out_path)) {
          cli::cli_alert_warning("{.file {fs::path_rel(out_path)}} was not created!")
        } else if (fs::file_size(out_path) == 0) {
          cli::cli_alert_warning("{.file {fs::path_rel(out_path)}} is empty!")
        }
      }
    }
  }

  invisible(result)
}
