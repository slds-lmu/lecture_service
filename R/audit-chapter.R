#' Parse figure references from a LaTeX slide file
#'
#' Extracts figure paths referenced via `\\includegraphics`, `\\image`,
#' `\\imageC`, `\\imageL`, `\\imageR`, and `\\imageFixed` commands.
#'
#' Only returns references to `figure/` paths (skips `figure_man/`,
#' cross-chapter `../` references, and `../../slides-pdf/`).
#'
#' @param slide_tex_path Character. Path to a `.tex` file.
#'
#' @return A character vector of figure basenames (without extension),
#'   as referenced by the slide. Duplicates are removed.
#'
#' @export
#' @examplesIf fs::dir_exists(here::here("lecture_i2ml"))
#' parse_slide_figures("lecture_i2ml/slides/evaluation/slides-evaluation-train.tex")
parse_slide_figures <- function(slide_tex_path) {
  checkmate::assert_file_exists(slide_tex_path)

  lines <- readLines(slide_tex_path, warn = FALSE)
  # Remove comment lines and inline comments
  lines <- stringr::str_remove(lines, "%.*$")
  lines <- lines[!stringr::str_detect(lines, "^\\s*$")]
  text <- paste(lines, collapse = "\n")

  # Pattern for \includegraphics[...]{PATH}
  pat_includegraphics <- "\\\\includegraphics\\s*(?:\\[[^]]*\\])?\\s*\\{([^}]+)\\}"

  # Pattern for \image, \imageC, \imageL, \imageR with up to 2 optional [...] args
  pat_image <- "\\\\image[CLRF]?\\s*(?:\\[[^]]*\\])?\\s*(?:\\[[^]]*\\])?\\s*\\{([^}]+)\\}"

  # Pattern for \imageFixed{x}{y}[...][...]{PATH}
  pat_imagefixed <- "\\\\imageFixed\\s*\\{[^}]*\\}\\s*\\{[^}]*\\}\\s*(?:\\[[^]]*\\])?\\s*(?:\\[[^]]*\\])?\\s*\\{([^}]+)\\}"

  paths <- c(
    stringr::str_match_all(text, pat_includegraphics)[[1]][, 2],
    stringr::str_match_all(text, pat_image)[[1]][, 2],
    stringr::str_match_all(text, pat_imagefixed)[[1]][, 2]
  )

  if (length(paths) == 0) {
    return(character())
  }

  paths <- stringr::str_trim(paths)

  # Keep only figure/ references (not figure_man/, ../, etc.)
  paths <- paths[stringr::str_starts(paths, "figure/")]

  if (length(paths) == 0) {
    return(character())
  }

  # Strip "figure/" prefix and file extension to get basenames
  basenames <- stringr::str_remove(paths, "^figure/")
  basenames <- tools::file_path_sans_ext(basenames)

  unique(basenames)
}


#' Audit the script-figure-slide dependency chain for a chapter
#'
#' Performs a comprehensive audit of a lecture chapter:
#' 1. Discovers scripts in `rsrc/`, figures in `figure/`, and slide `.tex` files
#' 2. Parses slides to find which figures they reference
#' 3. Optionally runs all scripts and tracks which figures they produce
#' 4. Cross-references to identify orphaned figures, orphaned scripts,
#'    and missing figures
#'
#' @param lecture Character. Lecture directory name, e.g. `"lecture_i2ml"`.
#' @param chapter Character. Chapter directory name, e.g. `"evaluation"`.
#' @param pattern Regex pattern to filter scripts. Default `"[.]R$"`.
#' @param timeout Numeric. Per-script timeout in seconds. Default 300.
#' @param run Logical. If `TRUE` (default), execute scripts.
#'   If `FALSE`, only perform static analysis (figure existence + slide references).
#'
#' @return Invisibly: A list with components:
#' - `scripts`: data.frame of scripts. Includes `success`, `error_message`,
#'     `elapsed`, and `figures_produced` columns when `run = TRUE` (`NA` otherwise).
#' - `figures`: data.frame of figure files on disk
#' - `slide_refs`: named list mapping slide filenames to their figure references
#' - `orphaned_figures`: character vector of figure basenames not used by any slide
#' - `orphaned_scripts`: character vector of script filenames whose produced
#'     figures are not used by any slide (`NULL` if `run = FALSE`)
#' - `missing_figures`: data.frame with columns `figure` and `slide` for
#'     figures referenced by slides but not on disk
#' - `missing_pkgs`: character vector of R packages required by scripts
#'     but not currently installed
#'
#' @export
#' @examplesIf fs::dir_exists(here::here("lecture_i2ml"))
#' # Static audit only (no script execution)
#' result <- audit_chapter("lecture_i2ml", "evaluation", run = FALSE)
#' result$orphaned_figures
#' result$missing_figures
#'
#' \dontrun{
#' # Full audit with script execution
#' result <- audit_chapter("lecture_i2ml", "evaluation", run = TRUE)
#' }
audit_chapter <- function(
  lecture,
  chapter,
  pattern = "[.]R$",
  timeout = 300,
  run = TRUE
) {
  chapter_dir <- here::here(lecture, "slides", chapter)
  checkmate::assert_directory_exists(chapter_dir)

  # --- Discovery ---
  scripts_tbl <- get_chapter_scripts(lecture, chapter, pattern = pattern)
  figures_tbl <- get_chapter_figures(lecture, chapter)

  # Find slide .tex files in the chapter directory (not in subdirectories)
  slide_files <- as.character(
    fs::dir_ls(chapter_dir, type = "file", regexp = "slides-.*\\.tex$")
  )

  cli::cli_h1("Chapter: {chapter} ({lecture})")
  cli::cli_alert_info(
    "Found {nrow(scripts_tbl)} script{?s} in rsrc/, {nrow(figures_tbl)} figure{?s} in figure/, {length(slide_files)} slide{?s}"
  )

  # --- Parse slide figure references ---
  slide_refs <- stats::setNames(
    lapply(slide_files, parse_slide_figures),
    fs::path_file(slide_files)
  )
  all_referenced <- unique(unlist(slide_refs, use.names = FALSE))

  # --- Figure basenames on disk ---
  figures_on_disk <- figures_tbl$figure_base_name

  # --- Check script dependencies ---
  missing_pkgs <- character()
  if (nrow(scripts_tbl) > 0) {
    deps <- extract_script_deps(scripts_tbl$script_path)
    if (length(deps) > 0) {
      installed <- vapply(deps, requireNamespace, logical(1), quietly = TRUE)
      missing_pkgs <- deps[!installed]
      if (length(missing_pkgs) > 0) {
        cli::cli_alert_warning(
          "{length(missing_pkgs)} missing package{?s}: {.pkg {missing_pkgs}}"
        )
        cli::cli_alert_info(
          "Install with: {.code check_script_deps(\"{lecture}\", \"{chapter}\")}"
        )
      }
    }
  }

  # --- Run scripts (optional) ---
  if (run && nrow(scripts_tbl) > 0) {
    cli::cli_h2("Script Execution")
    run_results <- run_chapter_scripts(
      lecture,
      chapter,
      pattern = pattern,
      timeout = timeout
    )
    scripts_tbl <- dplyr::left_join(
      scripts_tbl,
      run_results,
      by = c("script_path", "script_file")
    )
  } else {
    scripts_tbl$success <- NA
    scripts_tbl$error_message <- NA_character_
    scripts_tbl$elapsed <- NA_real_
    scripts_tbl$figures_produced <- list(character())
    if (run && nrow(scripts_tbl) == 0) {
      cli::cli_alert_info("No scripts to run.")
    }
  }

  # --- Cross-reference analysis ---
  cli::cli_h2("Dependency Analysis")

  # Orphaned figures: on disk but not referenced by any slide
  orphaned_figures <- setdiff(figures_on_disk, all_referenced)

  # Missing figures: referenced by slides but not on disk
  missing_figs <- setdiff(all_referenced, figures_on_disk)
  missing_figures_df <- tibble::tibble(
    figure = character(),
    slide = character()
  )
  if (length(missing_figs) > 0) {
    rows <- lapply(missing_figs, function(fig) {
      slides_using <- names(slide_refs)[vapply(
        slide_refs,
        function(refs) fig %in% refs,
        logical(1)
      )]
      tibble::tibble(figure = fig, slide = slides_using)
    })
    missing_figures_df <- do.call(rbind, rows)
  }

  # Orphaned scripts: produced no figure used by any slide
  orphaned_scripts <- NULL
  if (run && nrow(scripts_tbl) > 0) {
    orphaned_scripts <- character()
    for (i in seq_len(nrow(scripts_tbl))) {
      produced <- scripts_tbl$figures_produced[[i]]
      produced_basenames <- tools::file_path_sans_ext(produced)
      if (
        length(produced_basenames) == 0 ||
          !any(produced_basenames %in% all_referenced)
      ) {
        orphaned_scripts <- c(orphaned_scripts, scripts_tbl$script_file[i])
      }
    }
  }

  # --- CLI summary ---
  if (run && nrow(scripts_tbl) > 0) {
    failed <- scripts_tbl[!scripts_tbl$success, , drop = FALSE]
    if (nrow(failed) > 0) {
      cli::cli_alert_danger("Found {.val {nrow(failed)}} script{?s} failing:")

      for (i in seq_len(nrow(failed))) {
        cli::cli_bullets(c(
          "{failed$script_file[i]}: {failed$error_message[i]}"
        ))
      }
    }
  }

  cli::cli_h3("Orphaned figures")
  if (length(orphaned_figures) > 0) {
    cli::cli_alert_warning(
      "Found {.val {length(orphaned_figures)}} orphaned figure{?s} (in figure/ but not used by any slide)"
    )

    cli::cli_bullets(stats::setNames(
      paste0("figure/", orphaned_figures),
      rep("!", length(orphaned_figures))
    ))
  } else {
    cli::cli_alert_success("No orphaned figures.")
  }

  cli::cli_h3("Orphaned scripts")
  if (!is.null(orphaned_scripts) && length(orphaned_scripts) > 0) {
    cli::cli_alert_warning(
      "Found {.val {length(orphaned_scripts)}} orphaned script{?s} (produced no figure used by a slide)"
    )

    cli::cli_bullets(stats::setNames(
      orphaned_scripts,
      rep("!", length(orphaned_scripts))
    ))
  } else if (run) {
    cli::cli_alert_success("No orphaned scripts.")
  }

  cli::cli_h3("Missing figures")
  if (nrow(missing_figures_df) > 0) {
    cli::cli_alert_danger(
      "Found {.val {length(missing_figs)}} missing figure{?s} (referenced by slides but not in figure/)"
    )
    for (fig in unique(missing_figures_df$figure)) {
      slides_using <- missing_figures_df$slide[missing_figures_df$figure == fig]
      cli::cli_bullets(c(
        "x" = "figure/{fig} referenced by {.file {slides_using}}"
      ))
    }
  } else {
    cli::cli_alert_success("No missing figures.")
  }

  invisible(list(
    scripts = scripts_tbl,
    figures = figures_tbl,
    slide_refs = slide_refs,
    orphaned_figures = orphaned_figures,
    orphaned_scripts = orphaned_scripts,
    missing_figures = missing_figures_df,
    missing_pkgs = missing_pkgs
  ))
}
