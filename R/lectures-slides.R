#' Assemble table of lecture slides
#'
#' @param lectures_path Path containing lecture_* directories. Defaulting to `here::here()`.
#' @param filter_lectures `[NULL]`: Vector of lecture repo names to filter table by, e.g. `"lecture_i2ml"`.
#'   Can be set to [`lectures()`] to respect `include_lectures`.
#' @param exclude_slide_subdirs Exclude slides/ subfolders, e.g. `c("attic", "rsrc", "all")`.
#' @param exclude_slide_names Exclude slides matching these names exactly, e.g. `"chapter-order"` (default).
#'
#' @return A data.frame with one row per slide .tex file.
#' @export
#'
#' @examples
#' \dontrun{
#' collect_lectures()
#' }
collect_lectures <- function(
    lectures_path = here::here(),
    filter_lectures = NULL,
    exclude_slide_subdirs = c("attic", "rsrc", "all", "figure_man", "figures_tikz",
                              "figure", "tex", "backup"),
    exclude_slide_names = c("chapter-order", "chapter-order-nutshell")
) {

  # Take ls with absolute file paths, directories only, and those matching lecture_asdf format
  # Must not use just "lecture_*" because regex or glob will match "lecture_service" as part of
  # absolute file path
  lecture_dirs <- fs::dir_ls(lectures_path, regexp = "/lecture_[a-z0-9]*$", type = "directory")
  # Kick out spurious "lecture_service" match just in case it happens (shouldn't matter though)
  lecture_dirs <- lecture_dirs[which(!fs::path_file(lecture_dirs) == "lecture_service")]

  stopifnot("Found no lecture_* folders" = length(lecture_dirs) > 0)

  lectures_tbl <- do.call(rbind, lapply(lecture_dirs, \(lecture_dir) {
    lecture_slides <- fs::path(lecture_dir, "slides")
    if (!fs::dir_exists(lecture_slides)) return(data.frame())

    # It's hard to collect all the slide tex files because naming conventions
    # differ (standard is slide-*.tex, optimization and iml differ),
    # and we don't want stuff in attic/ or the chapter-order.tex file.
    # Not-smart but easy-ish method is to enumerate everything and than filter out
    # the useless stuff.
    topic_dirs <- fs::dir_ls(lecture_slides, recurse = FALSE, type = "directory")
    # Exclude e.g. /slides/all
    topic_dirs <- topic_dirs[which(!(fs::path_file(topic_dirs) %in% exclude_slide_subdirs))]
    # Non-recursively list tex files now, so we avoid
    # e.g. lecture_i2ml/slides/tuning/attic/ files
    tex_files <- fs::dir_ls(topic_dirs, recurse = FALSE, glob = "*.tex")
    slides_dir <- fs::path_tidy(fs::path_dir(tex_files))
    pdf_files <- fs::path_ext_set(tex_files, "pdf")

    data.frame(
      lecture = fs::path_file(lecture_dir),
      tex = tex_files,
      # latexmk-generated log file for later grep'ing for common errors. Might not exist but path is known.
      tex_log = fs::path_ext_set(tex_files, ext = "log"),
      slides_dir = slides_dir,
      topic = fs::path_file(slides_dir),
      slide_name = fs::path_file(fs::path_ext_remove(tex_files)),
      pdf = pdf_files,
      pdf_static = fs::path_tidy(here::here(lecture_dir, "slides-pdf", fs::path_file(pdf_files)))
    )
  }))

  if (!is.null(filter_lectures)) {
    sapply(filter_lectures, checkmate::assert_directory_exists)
    lectures_tbl <- subset(lectures_tbl, lecture %in% filter_lectures)
  }

  # Exclude undesired slide/<folder> and <slide-name>.tex
  lectures_tbl <- subset(lectures_tbl, !(topic %in% exclude_slide_subdirs))
  lectures_tbl <- subset(lectures_tbl, !(slide_name %in% exclude_slide_names))
  lectures_tbl <- subset(lectures_tbl, !grepl("^OLD-", slide_name))


  lectures_tbl$pdf_exists <- fs::file_exists(lectures_tbl$pdf)
  lectures_tbl$pdf_static_exists <- fs::file_exists(lectures_tbl$pdf_static)

  # Rownames where absolute paths to tex files, not helpful
  rownames(lectures_tbl) <- NULL

  lectures_tbl[, c("lecture", "topic", "slide_name", "tex", "tex_log", "slides_dir", "pdf", "pdf_exists",
                   "pdf_static", "pdf_static_exists")]
}

#' Read included lectures from one central file, ignoring commented out lines
#'
#' Can be overridden with environment variable `$include_lectures`.
#' @export
#' @return A character vector, e.g. `c("lecture_i2ml", "lecture_advml")`, depending on `./include_lectures`
#' @examples
#' \dontrun{
#' lectures()
#' }
lectures <- function() {
  lectures <- Sys.getenv("include_lectures", unset = NA)

  if (is.na(lectures)) {
    checkmate::assert_file_exists("include_lectures")
    lectures <- grep(pattern = "^#", readLines("include_lectures"), value = TRUE, invert = TRUE)
  }

  lectures
}

#' Find a slide set across all lectures
#'
#' Lectures need to be stored locally in the current directory with regular names like  `lecture_i2ml`.
#' It is strongly assumed that slide names such as `slides-cart-predictions.tex` are unique across all lectures.
#'
#' @param lectures_tbl Must contain `tex` column. Defaults to `collect_lectures()`.
#' @param slide_file  Name of a (single) slide, with or without `.tex` extension. See examples.
#'
#' @export
#' @examples
#' \dontrun{
#' # The "normal" way: A .tex file name
#' find_slide_tex("slides-cart-computationalaspects.tex")
#'
#' # Also acceptable: A full path (absolute or relative), convenient for scripts
#' find_slide_tex("lecture_advml/slides/gaussian-processes/slides-gp-bayes-lm.tex")
#'
#' # Lazy way: No extension, just a name
#' find_slide_tex("slides-cart-predictions")
#' }
find_slide_tex <- function(lectures_tbl = collect_lectures(), slide_file) {
  # Allow both "slides-cart-predictions.tex" and lazy "slides-cart-predictions"
  # and "slides-cart-predictions.pdf" because why not.
  if (identical(fs::path_ext(slide_file), "")) slide_file <- fs::path_ext_set(slide_file, "tex")
  if (identical(fs::path_ext(slide_file), "pdf")) slide_file <- fs::path_ext_set(slide_file, "tex")

  if (slide_file %in% lectures_tbl$tex) {
    tmp <- lectures_tbl[lectures_tbl$tex == slide_file, ]
  } else if (slide_file %in% fs::path_rel(lectures_tbl$tex)) {
    tmp <- lectures_tbl[fs::path_rel(lectures_tbl$tex) == slide_file, ]
  }

  slide_file <- fs::path_file(slide_file)
  tmp <- lectures_tbl[fs::path_file(lectures_tbl$tex) == slide_file, ]

  if (nrow(tmp) == 0) {
    stop(sprintf("No matching file for %s", slide_file))
  }
  if (nrow(tmp) > 1) {
    stop(sprintf("Multiple files matching name %s, got %i matches", slide_file, nrow(tmp)))
  }

  tmp
}
