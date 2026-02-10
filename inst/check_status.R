#!/usr/bin/env Rscript

library(lese)

check_rds <- slide_cache_path()

check_tbl <- readRDS(check_rds)
check_results <- check_tbl[["compile_check"]]

# All TRUE -> all good, so if not all TRUE then exist status should translate to 1
res <- !all(check_results)

if (res) {
  # Some slides failed to compile - provide detailed error message
  failed_indices <- which(!check_results)
  num_failed <- length(failed_indices)
  num_total <- length(check_results)

  cli::cli_alert_danger("LaTeX slide compilation failed!")
  cli::cli_alert_warning(
    "{num_failed} out of {num_total} slide(s) failed to compile"
  )

  if ("file" %in% names(check_tbl)) {
    failed_files <- check_tbl[["file"]][failed_indices]
    cli::cli_h2("Failed slides:")
    for (i in seq_along(failed_files)) {
      cli::cli_li(failed_files[i])
    }
  }

  # Determine the lecture name and construct the slide check URL
  lecture_dir <- basename(here::here())
  slide_check_url <- paste0("https://slds-lmu.github.io/", lecture_dir, "/")

  cli::cli_h2("For more details:")
  cli::cli_li("View detailed error logs in the workflow output above")
  cli::cli_li("Check the slide status site: {.url {slide_check_url}}")

  cli::cli_alert_info(
    "This action exits with error status because slide compilation failed"
  )
}

quit(save = "no", status = as.integer(res))
