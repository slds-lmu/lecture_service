#' List figure files in a chapter's figure/ directory
#' @param lecture Character. Lecture directory name, e.g. "lecture_i2ml".
#' @param chapter Character. Chapter directory name, e.g. "evaluation".
#' @return A data.frame with columns: `figure_path`, `figure_file`,
#'   `figure_extension`, `figure_base_name`.
#' @noRd
get_chapter_figures <- function(lecture, chapter) {
  figure_dir <- here::here(lecture, "slides", chapter, "figure")

  if (!fs::dir_exists(figure_dir)) {
    return(tibble::tibble(
      figure_path = character(),
      figure_file = character(),
      figure_extension = character(),
      figure_base_name = character()
    ))
  }

  paths <- fs::dir_ls(figure_dir, type = "file")

  tibble::tibble(
    figure_path = as.character(paths),
    figure_file = fs::path_file(paths),
    figure_extension = fs::path_ext(figure_file),
    figure_base_name = as.character(fs::path_ext_remove(figure_file))
  )
}

#' List R scripts in a chapter's rsrc/ directory
#' @param lecture Character. Lecture directory name.
#' @param chapter Character. Chapter directory name.
#' @param pattern Regex pattern to filter script filenames. Default `"[.]R$"`
#'   matches all `.R` files. Use `"^fig.*[.]R$"` for only `fig*.R` scripts.
#' @return A data.frame with columns: `script_path`, `script_file`,
#'   `script_extension`, `script_base_name`.
#' @noRd
get_chapter_scripts <- function(lecture, chapter, pattern = "[.]R$") {
  rsrc_dir <- here::here(lecture, "slides", chapter, "rsrc")

  if (!fs::dir_exists(rsrc_dir)) {
    return(tibble::tibble(
      script_path = character(),
      script_file = character(),
      script_extension = character(),
      script_base_name = character()
    ))
  }

  paths <- fs::dir_ls(rsrc_dir, type = "file", regexp = pattern)

  tibble::tibble(
    script_path = as.character(paths),
    script_file = fs::path_file(paths),
    script_extension = fs::path_ext(script_file),
    script_base_name = as.character(fs::path_ext_remove(script_file))
  )
}
