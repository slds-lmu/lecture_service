#' Parse figure references from a LaTeX slide file
#'
#' Extracts figure paths referenced via `\\includegraphics`, `\\image`,
#' `\\imageC`, `\\imageL`, `\\imageR`, and `\\imageFixed` commands.
#'
#' By default, returns references to `figure/` paths (skipping cross-chapter
#' `../` references, `../../slides-pdf/`, etc.). Set `prefix` to extract
#' references for other directories, e.g. `"figure_man"`.
#'
#' Note: This uses regex on `.tex` source and cannot resolve dynamic
#' paths (e.g. `\\foreach` loops). For more robust detection after
#' compilation, use [audit_chapter()] with `method = "fls"`.
#'
#' @param slide_tex_path Character. Path to a `.tex` file.
#' @param prefix Character. Directory prefix to filter for, e.g. `"figure"`
#'   (default) or `"figure_man"`.
#'
#' @return A character vector of figure basenames (without extension),
#'   as referenced by the slide. Duplicates are removed.
#'
#' @export
#' @examplesIf fs::dir_exists(here::here("lecture_i2ml"))
#' parse_slide_figures("lecture_i2ml/slides/evaluation/slides-evaluation-train.tex")
parse_slide_figures <- function(slide_tex_path, prefix = "figure") {
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

  paths <- paths[startsWith(paths, paste0(prefix, "/"))]

  if (length(paths) == 0) {
    return(character())
  }

  # Strip prefix directory and file extension to get basenames
  unique(fs::path_ext_remove(fs::path_rel(paths, prefix)))
}


#' Parse figure references from `.fls` recorder files
#'
#' Extracts figure paths from LaTeX `.fls` files produced by
#' `latexmk -recorder`. More robust than regex-based parsing of `.tex`
#' source because it captures dynamically constructed paths (e.g. from
#' `\\foreach` loops).
#'
#' @param fls_path Character. Path to a single `.fls` file.
#' @param prefix Character. Directory prefix to filter for, e.g. `"figure"`
#'   (default) or `"figure_man"`.
#'
#' @return A character vector of unique figure basenames (without extension).
#' @noRd
parse_fls_figures <- function(fls_path, prefix = "figure") {
  checkmate::assert_file_exists(fls_path)

  lines <- readLines(fls_path, warn = FALSE)
  # Keep only INPUT lines
  lines <- lines[startsWith(lines, "INPUT ")]
  paths <- sub("^INPUT ", "", lines)
  # Normalize: strip leading ./
  paths <- sub("^\\./", "", paths)
  # Keep only paths matching the requested prefix
  paths <- paths[startsWith(paths, paste0(prefix, "/"))]

  if (length(paths) == 0) {
    return(character())
  }

  # Strip prefix directory and extension, deduplicate
  unique(fs::path_ext_remove(fs::path_rel(paths, prefix)))
}


#' Build a data.frame of missing figures (referenced by slides but not on disk)
#' @param referenced Character vector of figure basenames referenced by slides.
#' @param on_disk Character vector of figure basenames present on disk.
#' @param slide_refs Named list mapping slide filenames to their figure references.
#' @return A data.frame with columns `figure` and `slide` (zero rows if none missing).
#' @noRd
build_missing_figures_df <- function(referenced, on_disk, slide_refs) {
  missing_figs <- setdiff(referenced, on_disk)
  if (length(missing_figs) == 0) {
    return(tibble::tibble(figure = character(), slide = character()))
  }
  rows <- lapply(missing_figs, function(fig) {
    slides_using <- names(slide_refs)[vapply(
      slide_refs,
      function(refs) fig %in% refs,
      logical(1)
    )]
    tibble::tibble(figure = fig, slide = slides_using)
  })
  do.call(rbind, rows)
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
#' @param chapter Character. Chapter directory name, e.g. `"evaluation"`.
#' @param lecture_dir Character. Path to the lecture directory.
#'   Defaults to `here::here()`, i.e. the project root.
#' @param lecture Character. Lecture name for display purposes.
#'   Defaults to `basename(lecture_dir)`.
#' @param pattern Regex pattern to filter scripts. Default `"[.]R$"`.
#' @param timeout Numeric. Per-script timeout in seconds. Default 300.
#' @param run Logical. If `TRUE` (default), execute scripts.
#'   If `FALSE`, only perform static analysis (figure existence + slide references).
#' @param method Character. How to detect which figures slides reference:
#'   - `"auto"` (default): Use `.fls` files if they exist for all slides,
#'     otherwise fall back to regex. Best for use after `make slides`.
#'   - `"regex"`: Parse `.tex` source with regex. Fast but can miss
#'     dynamically constructed paths (e.g. `\\foreach` loops).
#'   - `"fls"`: Parse `.fls` recorder files from `latexmk`. More robust
#'     but requires prior compilation (`make slides`). Errors if `.fls`
#'     files are missing.
#'
#' @return Invisibly: A list with components:
#' - `scripts`: data.frame of scripts. Includes `success`, `error_message`,
#'     `elapsed`, and `figures_produced` columns when `run = TRUE` (`NA` otherwise).
#' - `figures`: data.frame of figure files on disk (from `figure/`)
#' - `figures_man`: data.frame of manually created figure files (from `figure_man/`)
#' - `slide_refs`: named list mapping slide filenames to their `figure/` references
#' - `slide_refs_man`: named list mapping slide filenames to their `figure_man/` references
#' - `orphaned_figures`: character vector of `figure/` filenames (with extension)
#'     not used by any slide (excludes `attic/` subdirectory)
#' - `orphaned_figures_man`: character vector of `figure_man/` filenames (with
#'     extension) not used by any slide (excludes `attic/` subdirectory)
#' - `attic_figures`: character vector of filenames in `figure/attic/`
#' - `attic_figures_man`: character vector of filenames in `figure_man/attic/`
#' - `orphaned_scripts`: character vector of script filenames whose produced
#'     figures are not used by any slide (`NULL` if `run = FALSE`)
#' - `missing_figures`: data.frame with columns `figure` and `slide` for
#'     `figure/` files referenced by slides but not on disk
#' - `missing_figures_man`: data.frame with columns `figure` and `slide` for
#'     `figure_man/` files referenced by slides but not on disk
#' - `missing_pkgs`: character vector of R packages required by scripts
#'     but not currently installed
#'
#' @export
#' @examplesIf fs::dir_exists(here::here("lecture_i2ml"))
#' # Static audit only (no script execution)
#' result <- audit_chapter("evaluation",
#'   lecture_dir = here::here("lecture_i2ml"),
#'   run = FALSE
#' )
#' result$orphaned_figures
#' result$missing_figures
#'
#' \dontrun{
#' # Full audit with script execution
#' result <- audit_chapter("evaluation",
#'   lecture_dir = here::here("lecture_i2ml")
#' )
#' }
audit_chapter <- function(
  chapter,
  lecture_dir = here::here(),
  lecture = basename(lecture_dir),
  pattern = "[.]R$",
  timeout = 300,
  run = TRUE,
  method = c("auto", "regex", "fls")
) {
  method <- match.arg(method)
  check_lecture_dir(lecture_dir, lecture_dir_missing = missing(lecture_dir))

  chapter_dir <- fs::path(lecture_dir, "slides", chapter)
  checkmate::assert_directory_exists(chapter_dir)

  # --- Discovery ---
  scripts_tbl <- get_chapter_scripts(lecture_dir, chapter, pattern = pattern)
  figures_tbl <- get_chapter_figures(lecture_dir, chapter)
  figures_man_tbl <- get_chapter_figures(
    lecture_dir,
    chapter,
    subdir = "figure_man"
  )

  # Find slide .tex files in the chapter directory (not in subdirectories)
  slide_files <- as.character(
    fs::dir_ls(chapter_dir, type = "file", regexp = "slides-.*\\.tex$")
  )

  n_fig <- nrow(figures_tbl)
  n_fig_man <- nrow(figures_man_tbl)
  cli::cli_h1("Chapter: {chapter} ({lecture})")
  cli::cli_alert_info(
    "Found {nrow(scripts_tbl)} script{?s}, {n_fig} figure/{?/s}, {n_fig_man} figure_man/{?/s}, {length(slide_files)} slide{?s}"
  )

  # --- Parse slide figure references ---
  fls_paths <- sub("\\.tex$", ".fls", slide_files)
  use_fls <- FALSE

  if (method == "fls") {
    missing_fls <- fls_paths[!fs::file_exists(fls_paths)]
    if (length(missing_fls) > 0) {
      cli::cli_abort(c(
        "{length(missing_fls)} .fls file{?s} not found.",
        "i" = "Run {.code make slides} first to generate .fls files.",
        "i" = "Or use {.code method = \"regex\"} for static analysis."
      ))
    }
    use_fls <- TRUE
  } else if (method == "auto") {
    use_fls <- length(fls_paths) > 0 && all(fs::file_exists(fls_paths))
    if (use_fls) {
      cli::cli_alert_info("Using .fls files for figure detection (more robust)")
    }
  }

  slide_names <- fs::path_file(slide_files)

  if (use_fls) {
    slide_refs <- stats::setNames(
      lapply(fls_paths, parse_fls_figures),
      slide_names
    )
    slide_refs_man <- stats::setNames(
      lapply(fls_paths, parse_fls_figures, prefix = "figure_man"),
      slide_names
    )
  } else {
    slide_refs <- stats::setNames(
      lapply(slide_files, parse_slide_figures),
      slide_names
    )
    slide_refs_man <- stats::setNames(
      lapply(slide_files, parse_slide_figures, prefix = "figure_man"),
      slide_names
    )
  }
  all_referenced <- unique(unlist(slide_refs, use.names = FALSE))
  all_referenced_man <- unique(unlist(slide_refs_man, use.names = FALSE))

  # --- Figure basenames on disk ---
  figures_on_disk <- figures_tbl$figure_base_name
  figures_man_on_disk <- figures_man_tbl$figure_base_name

  # --- Check script dependencies ---
  missing_pkgs <- character()
  if (nrow(scripts_tbl) > 0) {
    deps <- extract_script_deps(scripts_tbl$script_path)
    if (length(deps) > 0) {
      installed <- is_pkg_installed(deps)
      missing_pkgs <- deps[!installed]
      if (length(missing_pkgs) > 0) {
        cli::cli_alert_warning(
          "{length(missing_pkgs)} missing package{?s}: {.pkg {missing_pkgs}}"
        )
        cli::cli_alert_info(
          "Install with: {.code check_script_deps(\"{chapter}\")}"
        )
      }
    }
  }

  # --- Run scripts (optional) ---
  if (run && nrow(scripts_tbl) > 0) {
    cli::cli_h2("Script Execution")
    run_results <- run_chapter_scripts(
      chapter,
      lecture_dir = lecture_dir,
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

  # Orphaned figures: on disk but basename not referenced by any slide.
  # Report as full filenames (with extension) for actionable user output.
  # Figures in attic/ subdirectories are separated out -- they are intentionally
  # parked and not expected to be referenced, but listed for cleanup awareness.
  orphaned_mask <- !(figures_on_disk %in% all_referenced)
  orphaned_all <- as.character(figures_tbl$figure_file[orphaned_mask])
  is_attic <- startsWith(orphaned_all, "attic/")
  orphaned_figures <- orphaned_all[!is_attic]
  attic_figures <- orphaned_all[is_attic]

  orphaned_mask_man <- !(figures_man_on_disk %in% all_referenced_man)
  orphaned_all_man <- as.character(figures_man_tbl$figure_file[
    orphaned_mask_man
  ])
  is_attic_man <- startsWith(orphaned_all_man, "attic/")
  orphaned_figures_man <- orphaned_all_man[!is_attic_man]
  attic_figures_man <- orphaned_all_man[is_attic_man]

  # Missing figures: referenced by slides but not on disk
  missing_figures_df <- build_missing_figures_df(
    all_referenced,
    figures_on_disk,
    slide_refs
  )
  missing_figures_man_df <- build_missing_figures_df(
    all_referenced_man,
    figures_man_on_disk,
    slide_refs_man
  )

  # Orphaned scripts: produced no figure used by any slide
  orphaned_scripts <- NULL
  if (run && nrow(scripts_tbl) > 0) {
    orphaned_scripts <- character()
    for (i in seq_len(nrow(scripts_tbl))) {
      produced <- scripts_tbl$figures_produced[[i]]
      produced_basenames <- fs::path_ext_remove(produced)
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

  cli::cli_h3("Orphaned figures (figure/)")
  if (length(orphaned_figures) > 0) {
    cli::cli_alert_warning(
      "Found {.val {length(orphaned_figures)}} orphaned figure{?s} in figure/"
    )
    cli::cli_bullets(stats::setNames(
      paste0("figure/", orphaned_figures),
      rep("!", length(orphaned_figures))
    ))
  } else {
    cli::cli_alert_success("No orphaned figures in figure/.")
  }

  if (length(attic_figures) > 0) {
    cli::cli_alert_info(
      "{.val {length(attic_figures)}} figure{?s} in figure/attic/ (parked, not expected to be referenced)"
    )
  }

  cli::cli_h3("Orphaned figures (figure_man/)")
  if (length(orphaned_figures_man) > 0) {
    cli::cli_alert_warning(
      "Found {.val {length(orphaned_figures_man)}} orphaned figure{?s} in figure_man/"
    )
    cli::cli_bullets(stats::setNames(
      paste0("figure_man/", orphaned_figures_man),
      rep("!", length(orphaned_figures_man))
    ))
  } else if (nrow(figures_man_tbl) > 0) {
    cli::cli_alert_success("No orphaned figures in figure_man/.")
  }

  if (length(attic_figures_man) > 0) {
    cli::cli_alert_info(
      "{.val {length(attic_figures_man)}} figure{?s} in figure_man/attic/ (parked)"
    )
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

  cli::cli_h3("Missing figures (figure/)")
  if (nrow(missing_figures_df) > 0) {
    cli::cli_alert_danger(
      "Found {.val {nrow(missing_figures_df)}} missing reference{?s} to figure/"
    )
    for (fig in unique(missing_figures_df$figure)) {
      slides_using <- missing_figures_df$slide[missing_figures_df$figure == fig]
      cli::cli_bullets(c(
        "x" = "figure/{fig} referenced by {.file {slides_using}}"
      ))
    }
  } else {
    cli::cli_alert_success("No missing figures in figure/.")
  }

  cli::cli_h3("Missing figures (figure_man/)")
  if (nrow(missing_figures_man_df) > 0) {
    cli::cli_alert_danger(
      "Found {.val {nrow(missing_figures_man_df)}} missing reference{?s} to figure_man/"
    )
    for (fig in unique(missing_figures_man_df$figure)) {
      slides_using <- missing_figures_man_df$slide[
        missing_figures_man_df$figure == fig
      ]
      cli::cli_bullets(c(
        "x" = "figure_man/{fig} referenced by {.file {slides_using}}"
      ))
    }
  } else if (nrow(figures_man_tbl) > 0 || length(all_referenced_man) > 0) {
    cli::cli_alert_success("No missing figures in figure_man/.")
  }

  invisible(list(
    scripts = scripts_tbl,
    figures = figures_tbl,
    figures_man = figures_man_tbl,
    slide_refs = slide_refs,
    slide_refs_man = slide_refs_man,
    orphaned_figures = orphaned_figures,
    orphaned_figures_man = orphaned_figures_man,
    attic_figures = attic_figures,
    attic_figures_man = attic_figures_man,
    orphaned_scripts = orphaned_scripts,
    missing_figures = missing_figures_df,
    missing_figures_man = missing_figures_man_df,
    missing_pkgs = missing_pkgs
  ))
}
