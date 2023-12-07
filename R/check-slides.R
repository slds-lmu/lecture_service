#' Compile and compare all the slides
#'
#' @param lectures_tbl Must contain `tex` column. Defaults to `collect_lectures()`.
#' @param pre_clean `[FALSE]`: Passed to `[compile_slide()]`.
#' @param parallel `[TRUE]` Whether to parallelize.
#'   Uses `future.apply::future_lapply` with `future::plan("multisession")`.
#' @param create_comparison_pdf,thresh_psnr,dpi_check,dpi_out,pixel_tol,overwrite Passed to `[compare_slide()]`.
#' @return Invisibly: An expanded `lectures_tbl` with check results
#' Also saves output at `slide_check_cache.rds`.
#'
#' @export
check_all_slides <- function(
    lectures_tbl = collect_lectures(), pre_clean = FALSE,
    create_comparison_pdf = TRUE, parallel = TRUE,
    thresh_psnr = 40, dpi_check = 50, dpi_out = 100,
    pixel_tol = 20, overwrite = FALSE
) {

  check_tex <- function(tex) {

    result <- data.frame(
      tex = tex,
      compile_check = NA,
      compare_check = NA,
      compare_check_note = "",
      compare_check_raw = ""
    )

    compile_status <- compile_slide(tex, pre_clean = pre_clean, verbose = FALSE)

    result$compile_check <- compile_status$passed
    result$compile_note <- paste0(compile_status$note, collapse = "\n")

    if (compile_status$passed) {
      compare_status <- compare_slide(
        tex, verbose = FALSE, create_comparison_pdf = create_comparison_pdf,
        thresh_psnr = thresh_psnr, dpi_check = dpi_check, dpi_out = dpi_out,
        pixel_tol = pixel_tol, overwrite = overwrite
      )

      result$compare_check <- isTRUE(compare_status$passed)
      result$compare_check_raw <- compare_status$output

      if (!compare_status$passed) {
        if (compare_status$pages == "") {
          result$compare_check_note <- compare_status$reason
        } else {
          result$compare_check_note <- sprintf("%s: %s", compare_status$reason, compare_status$pages)
        }
      }
    }
    result
  }

  tictoc::tic()
  if (parallel) {
    future::plan("multisession")
    check_out <- future.apply::future_lapply(lectures_tbl$tex, check_tex, future.seed = NULL)
    # future.seed silences future warning about RNG stuff not relevant in this context
  } else {
    check_out <- lapply(lectures_tbl$tex, check_tex)
  }

  check_out <- do.call(rbind, check_out)

  # Merge with main slide table
  check_table_result <- merge(lectures_tbl, check_out, by = "tex")

  took <- tictoc::toc()

  cli::cli_alert_info("{took$callback_msg}. Saving results to \"slide_check_cache.rds\".")
  saveRDS(check_table_result, file = "slide_check_cache.rds")
  invisible(check_table_result)
}
