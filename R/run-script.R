#' Run an R script in an isolated subprocess
#'
#' Executes `script_path` in a fresh R session via [callr::r()], with the
#' working directory set to the script's parent directory (typically the
#' `rsrc/` folder).
#'
#' @param script_path Character. Absolute path to the R script.
#' @param timeout Numeric. Timeout in seconds. Default 300 (5 minutes).
#'
#' @return A single-row `data.frame` with columns:
#' - `script_path`: The input path.
#' - `success`: Logical, `TRUE` if script completed without error.
#' - `error_message`: Character, empty string on success, error message on failure.
#' - `elapsed`: Numeric, wall-clock seconds.
#'
#' @export
#' @examples
#' \dontrun{
#' run_script("lecture_i2ml/slides/evaluation/rsrc/fig-eval_mape.R")
#' }
run_script <- function(script_path, timeout = 300) {
  checkmate::assert_file_exists(script_path, extension = "R")

  script_dir <- fs::path_dir(script_path)
  script_file <- fs::path_file(script_path)
  start <- proc.time()[["elapsed"]]

  result <- tryCatch(
    {
      callr::r(
        function(path) source(path, local = TRUE),
        args = list(path = script_file),
        wd = script_dir,
        timeout = timeout,
        show = FALSE
      )
      list(success = TRUE, error_message = "")
    },
    error = function(e) {
      list(success = FALSE, error_message = conditionMessage(e))
    }
  )

  elapsed <- proc.time()[["elapsed"]] - start

  tibble::tibble(
    script_path = script_path,
    success = result$success,
    error_message = result$error_message,
    elapsed = round(elapsed, 1)
  )
}


#' Run all scripts in a chapter and track produced figures
#'
#' Runs each R script in `<lecture>/slides/<chapter>/rsrc/` sequentially in
#' isolated subprocesses. For each script, snapshots the `figure/` directory
#' before and after execution to determine which figure files were
#' created or modified.
#'
#' Scripts are run sequentially because the before/after figure directory
#' diffing requires that only one script modifies `figure/` at a time.
#'
#' @param lecture Character. Lecture directory name, e.g. `"lecture_i2ml"`.
#' @param chapter Character. Chapter directory name, e.g. `"evaluation"`.
#' @param pattern Regex pattern to filter script filenames. Default `"[.]R$"`.
#' @param timeout Numeric. Per-script timeout in seconds. Default 300.
#'
#' @return A `data.frame` with columns:
#' - `script_file`: Script filename.
#' - `script_path`: Absolute path.
#' - `success`: Logical.
#' - `error_message`: Character.
#' - `elapsed`: Numeric seconds.
#' - `figures_produced`: List column of character vectors (filenames created/modified).
#'
#' @export
#' @examples
#' \dontrun{
#' run_chapter_scripts("lecture_i2ml", "evaluation")
#'
#' # Only fig*.R scripts
#' run_chapter_scripts("lecture_i2ml", "evaluation", pattern = "^fig.*[.]R$")
#' }
run_chapter_scripts <- function(
  lecture,
  chapter,
  pattern = "[.]R$",
  timeout = 300
) {
  scripts <- get_chapter_scripts(lecture, chapter, pattern = pattern)

  if (nrow(scripts) == 0) {
    cli::cli_alert_warning("No scripts found in {.path {lecture}/slides/{chapter}/rsrc/}")
    return(tibble::tibble(
      script_file = character(),
      script_path = character(),
      success = logical(),
      error_message = character(),
      elapsed = numeric(),
      figures_produced = list()
    ))
  }

  figure_dir <- here::here(lecture, "slides", chapter, "figure")
  has_figure_dir <- fs::dir_exists(figure_dir)

  cli::cli_alert_info(
    "Running {nrow(scripts)} script{?s} in {.path {lecture}/slides/{chapter}/rsrc/}"
  )

  results <- vector("list", nrow(scripts))

  for (i in seq_len(nrow(scripts))) {
    script_path <- scripts$script_path[i]
    script_file <- scripts$script_file[i]

    # Snapshot figure/ before
    before <- snapshot_figure_dir(figure_dir, has_figure_dir)

    # Run script
    res <- run_script(script_path, timeout = timeout)

    # Snapshot figure/ after and diff
    after <- snapshot_figure_dir(figure_dir, has_figure_dir)
    produced <- diff_figure_snapshots(before, after)

    if (res$success) {
      if (length(produced) > 0) {
        cli::cli_alert_success(
          "{script_file} ({res$elapsed}s, produced: {.file {produced}})"
        )
      } else {
        cli::cli_alert_success("{script_file} ({res$elapsed}s, no figures produced)")
      }
    } else {
      cli::cli_alert_danger("{script_file} ({res$elapsed}s)")
      cli::cli_text("
{res$error_message}")
    }

    res$script_file <- script_file
    res$figures_produced <- list(produced)
    results[[i]] <- res
  }

  out <- do.call(rbind, results)
  out[, c("script_file", "script_path", "success", "error_message", "elapsed", "figures_produced")]
}


#' Snapshot a figure directory (file paths + modification times)
#' @noRd
snapshot_figure_dir <- function(figure_dir, exists = fs::dir_exists(figure_dir)) {
  if (!exists) {
    return(tibble::tibble(
      path = character(),
      file = character(),
      mtime = as.POSIXct(character()),
      size = numeric()
    ))
  }

  paths <- fs::dir_ls(figure_dir, type = "file")
  if (length(paths) == 0) {
    return(tibble::tibble(
      path = character(),
      file = character(),
      mtime = as.POSIXct(character()),
      size = numeric()
    ))
  }

  info <- fs::file_info(paths)
  tibble::tibble(
    path = as.character(paths),
    file = fs::path_file(paths),
    mtime = info$modification_time,
    size = as.numeric(info$size)
  )
}


#' Diff two figure directory snapshots
#' @return Character vector of filenames that are new or modified.
#' @noRd
diff_figure_snapshots <- function(before, after) {
  if (nrow(after) == 0) return(character())

  # New files: in after but not in before
  new_files <- setdiff(after$file, before$file)

  # Modified files: same name but different mtime or size
  common <- intersect(before$file, after$file)
  modified <- character()
  if (length(common) > 0) {
    b <- before[match(common, before$file), , drop = FALSE]
    a <- after[match(common, after$file), , drop = FALSE]
    changed <- (a$mtime != b$mtime) | (a$size != b$size)
    modified <- a$file[changed]
  }

  sort(unique(c(new_files, modified)))
}
