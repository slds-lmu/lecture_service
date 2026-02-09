#' Extract package dependencies from R scripts
#'
#' Parses R scripts for `library()`, `require()`, and `pkg::fn` calls to
#' determine which packages are needed. Scans one or more script files.
#'
#' @param script_paths Character vector of paths to R scripts.
#'
#' @return A character vector of unique package names, sorted alphabetically.
#'
#' @export
#' @examplesIf fs::dir_exists(here::here("lecture_i2ml"))
#' scripts <- get_chapter_scripts(here::here("lecture_i2ml"), "evaluation")
#' extract_script_deps(scripts$script_path)
extract_script_deps <- function(script_paths) {
  checkmate::assert_character(script_paths, min.len = 1)

  pat_lib <- "(?:library|require)\\s*\\(\\s*[\"']?([a-zA-Z][a-zA-Z0-9.]*)"
  pat_ns <- "([a-zA-Z][a-zA-Z0-9.]*):{2,3}"

  all_pkgs <- character()

  for (path in script_paths) {
    if (!fs::file_exists(path)) {
      next
    }
    text <- paste(readLines(path, warn = FALSE), collapse = "\n")

    # library(pkg) and require(pkg) — with or without quotes
    lib_pkgs <- stringr::str_match_all(text, pat_lib)[[1]][, 2]

    # pkg::fn or pkg:::fn
    ns_pkgs <- stringr::str_match_all(text, pat_ns)[[1]][, 2]

    all_pkgs <- c(all_pkgs, lib_pkgs, ns_pkgs)
  }

  sort(unique(all_pkgs))
}


#' Check and install missing dependencies for chapter scripts
#'
#' Extracts package dependencies from all R scripts in a chapter's `rsrc/`
#' directory, checks which are not installed, and offers to install them
#' via [pak::pak()].
#'
#' @param chapter Character. Chapter directory name, e.g. `"evaluation"`.
#' @param lecture_dir Character. Path to the lecture directory.
#'   Defaults to `here::here()`.
#' @param lecture Character. Lecture name for display purposes.
#'   Defaults to `basename(lecture_dir)`.
#' @param pattern Regex pattern to filter scripts. Default `"[.]R$"`.
#' @param install Logical. If `TRUE` (default in interactive sessions),
#'   prompt to install missing packages. If `FALSE`, only report.
#'
#' @return Invisibly: A list with `all` (all detected packages) and
#'   `missing` (packages not currently installed).
#'
#' @export
#' @examplesIf fs::dir_exists(here::here("lecture_i2ml"))
#' check_script_deps("evaluation",
#'   lecture_dir = here::here("lecture_i2ml"),
#'   install = FALSE
#' )
check_script_deps <- function(
  chapter,
  lecture_dir = here::here(),
  lecture = basename(lecture_dir),
  pattern = "[.]R$",
  install = interactive()
) {
  check_lecture_dir(lecture_dir, lecture_dir_missing = missing(lecture_dir))
  scripts <- get_chapter_scripts(lecture_dir, chapter, pattern = pattern)

  if (nrow(scripts) == 0) {
    cli::cli_alert_warning(
      "No scripts found in {.path {lecture}/slides/{chapter}/rsrc/}"
    )
    return(invisible(list(all = character(), missing = character())))
  }

  deps <- extract_script_deps(scripts$script_path)

  if (length(deps) == 0) {
    cli::cli_alert_success(
      "No package dependencies detected in {nrow(scripts)} script{?s}."
    )
    return(invisible(list(all = character(), missing = character())))
  }

  installed <- vapply(deps, requireNamespace, logical(1), quietly = TRUE)
  missing <- deps[!installed]

  cli::cli_alert_info(
    "Found {length(deps)} package dependenc{?y/ies} across {nrow(scripts)} script{?s}."
  )

  if (length(missing) == 0) {
    cli::cli_alert_success("All packages are installed.")
    return(invisible(list(all = deps, missing = character())))
  }

  cli::cli_alert_warning(
    "{length(missing)} package{?s} not installed: {.pkg {missing}}"
  )

  if (install) {
    if (!requireNamespace("pak", quietly = TRUE)) {
      cli::cli_abort(
        "{.pkg pak} is required to install packages. Install it with {.code install.packages('pak')}"
      )
    }
    answer <- utils::menu(
      choices = c("Yes", "No"),
      title = paste0(
        "Install ",
        length(missing),
        " missing package(s) via pak?"
      )
    )
    if (answer == 1L) {
      pak::pak(missing)
    }
  }

  invisible(list(all = deps, missing = missing))
}
