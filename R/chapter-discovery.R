#' List figure files in a chapter's figure directory
#' @param lecture_dir Character. Path to the lecture directory.
#' @param chapter Character. Chapter directory name, e.g. "evaluation".
#' @param subdir Character. Subdirectory name, default `"figure"`.
#'   Use `"figure_man"` for manually created figures.
#' @return A data.frame with columns: `figure_path`, `figure_file`,
#'   `figure_extension`, `figure_base_name`.
#' @noRd
get_chapter_figures <- function(lecture_dir, chapter, subdir = "figure") {
  figure_dir <- fs::path(lecture_dir, "slides", chapter, subdir)

  if (!fs::dir_exists(figure_dir)) {
    return(tibble::tibble(
      figure_path = character(),
      figure_file = character(),
      figure_extension = character(),
      figure_base_name = character()
    ))
  }

  paths <- fs::dir_ls(figure_dir, type = "file", recurse = TRUE)
  # Paths relative to figure_dir, preserving subdirectory structure
  # e.g. "cwb-anim/fig-iter-0038.png" for figure/cwb-anim/fig-iter-0038.png
  rel_paths <- fs::path_rel(paths, figure_dir)

  tibble::tibble(
    figure_path = as.character(paths),
    figure_file = as.character(rel_paths),
    figure_extension = fs::path_ext(rel_paths),
    figure_base_name = as.character(fs::path_ext_remove(rel_paths))
  )
}

#' List R scripts in a chapter's rsrc/ directory
#' @param lecture_dir Character. Path to the lecture directory.
#' @param chapter Character. Chapter directory name.
#' @param pattern Regex pattern to filter script filenames. Default `"[.]R$"`
#'   matches all `.R` files. Use `"^fig.*[.]R$"` for only `fig*.R` scripts.
#' @return A data.frame with columns: `script_path`, `script_file`,
#'   `script_extension`, `script_base_name`.
#' @noRd
get_chapter_scripts <- function(lecture_dir, chapter, pattern = "[.]R$") {
  rsrc_dir <- fs::path(lecture_dir, "slides", chapter, "rsrc")

  if (!fs::dir_exists(rsrc_dir)) {
    return(tibble::tibble(
      script_path = character(),
      script_file = character(),
      script_extension = character(),
      script_base_name = character()
    ))
  }

  paths <- fs::dir_ls(rsrc_dir, type = "file", regexp = pattern)
  files <- fs::path_file(paths)

  tibble::tibble(
    script_path = as.character(paths),
    script_file = as.character(files),
    script_extension = fs::path_ext(files),
    script_base_name = as.character(fs::path_ext_remove(files))
  )
}
