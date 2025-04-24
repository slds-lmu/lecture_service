#' Compile and compare a slide chunk
#'
#' Use [check_slides_many()] to check many slides.
#'
#' @inheritParams find_slide_tex
#' @param pre_clean `[FALSE]`: Passed to [compile_slide()].
#' @param compare_slides `[FALSE]` If `TRUE`, run [compare_slide()] on the slide iff the compile check passed.
#' @param create_comparison_pdf,thresh_psnr,dpi_check,dpi_out,pixel_tol,overwrite Passed to [compare_slide()].
#'
#' @export
#' @return A `data.frame` with columns
#' - `tex`: Same as `slide_file` argument.
#' - `compile_check`: `logical` indicating whether [compile_slide()] passed
#' - `compare_check`: `logical` indicating whether [compare_slide()] passed ( `NA` if `compare_slides = FALSE` or [compile_slide()] did not pass)
#' - `compare_check_note`: Note from [compare_slide()] indicating number and nature of differences.
#' - `compare_check_raw`: More verbose form of `compare_check_note`.
#' - `compile_note`: If there are compilation errors, the error messages from [compile_slide()] are included (see also [check_log()]).
#'
#' @examples
#' \dontrun{
#' check_slides_single(slide_file = "slides-basics-whatisml", pre_clean = TRUE, compare_slides = TRUE)
#' }
check_slides_single <- function(
  slide_file,
  pre_clean = FALSE,
  compare_slides = FALSE,
  create_comparison_pdf = FALSE,
  thresh_psnr = 40,
  dpi_check = 50,
  dpi_out = 100,
  pixel_tol = 20,
  overwrite = FALSE
) {
  tmp <- find_slide_tex(slide_file = slide_file)

  result <- data.frame(
    tex = tmp$tex,
    compile_check = NA,
    compare_check = NA,
    compare_check_note = "",
    compare_check_raw = ""
  )

  compile_status <- compile_slide(
    tmp$tex,
    pre_clean = pre_clean,
    verbose = FALSE
  )

  result$compile_check <- compile_status$passed
  result$compile_note <- paste0(compile_status$note, collapse = "\n")

  if (compile_status$passed & compare_slides) {
    compare_status <- compare_slide(
      slide_file,
      verbose = FALSE,
      create_comparison_pdf = create_comparison_pdf,
      thresh_psnr = thresh_psnr,
      dpi_check = dpi_check,
      dpi_out = dpi_out,
      pixel_tol = pixel_tol,
      overwrite = overwrite
    )

    result$compare_check <- compare_status$passed
    result$compare_check_raw <- compare_status$output

    if (isFALSE(compare_status$passed)) {
      if (compare_status$pages == "") {
        result$compare_check_note <- compare_status$reason
      } else {
        result$compare_check_note <- sprintf(
          "%s: %s",
          compare_status$reason,
          compare_status$pages
        )
      }
    }
  }

  result
}


#' Compile and compare many slides
#'
#' Wrapper for [check_slides_single()].
#'
#' @param lectures_tbl Must contain `tex` column. Defaults to [collect_lectures()].
#' @inheritParams check_slides_single
#' @param parallel `[TRUE]` Whether to parallelize.
#'   Uses [future.apply::future_lapply] with `future::plan("multisession")`.
#' @export
#' @return Invisibly: An expanded `lectures_tbl` with check results
#' Also saves output at `slide_check_cache.rds`.
check_slides_many <- function(
  lectures_tbl = collect_lectures(),
  pre_clean = FALSE,
  compare_slides = FALSE,
  create_comparison_pdf = FALSE,
  parallel = TRUE,
  thresh_psnr = 40,
  dpi_check = 50,
  dpi_out = 100,
  pixel_tol = 20,
  overwrite = FALSE
) {
  tictoc::tic()

  cores_available <- as.integer(try(future::availableCores())) - 1 %||% 1
  if (cores_available <= 2) {
    parallel <- FALSE
    cli::cli_alert_warning(
      "Only found {.val {cores_available}} cores. Disabling parallelization."
    )
  }

  if (parallel) {
    workers <- cores_available - 1
    cli::cli_alert_info("Parallelizing using {.val {workers}} cores.")

    future::plan("multisession", workers = workers)
    check_out <- future.apply::future_lapply(
      lectures_tbl$tex,
      check_slides_single,
      future.seed = NULL
    )
    # future.seed silences future warning about RNG stuff not relevant in this context
  } else {
    check_out <- lapply(lectures_tbl$tex, check_slides_single)
  }

  check_out <- do.call(rbind, check_out)

  # Merge with main slide table
  check_table_result <- dplyr::left_join(
    lectures_tbl,
    check_out,
    by = "tex"
  )

  took <- tictoc::toc()

  cli::cli_alert_info(
    "{took$callback_msg}. Saving results to {.file slide_check_cache.rds}."
  )
  saveRDS(check_table_result, file = "slide_check_cache.rds")
  invisible(check_table_result)
}
