#' Get included lectures
#'
#' Uses central file `./include_lectures`, ignoring commented out lines.
#' Can be overridden with environment variable `$include_lectures`.
#' If neither the environment variable nor the file exists, it defaults to listing
#' all lectures.
#' @export
#' @return A character vector, e.g. `c("lecture_i2ml", "lecture_advml")`, depending on `./include_lectures`
#' @examples
#' lectures()
lectures <- function() {
  lectures <- Sys.getenv("include_lectures", unset = NA)

  if (is.na(lectures) & file.exists(here::here("include_lectures"))) {
    lectures <- grep(
      pattern = "^#",
      readLines(here::here("include_lectures")),
      value = TRUE,
      invert = TRUE
    )
  } else {
    lectures <- c(
      "lecture_i2ml",
      "lecture_advml",
      "lecture_sl",
      "lecture_iml",
      "lecture_optimization",
      "lecture_algods",
      "lecture_debug"
    )
  }

  lectures
}

#' Assemble table of lecture slides
#'
#' @param lectures_path Path containing lecture_* directories. Defaulting to `here::here()`.
#' @param filter_lectures [`character()`]: Vector of lecture repo names to filter table by, e.g. `"lecture_i2ml"`.
#'   Defaults to [lectures()] to respect `include_lectures`.
#' @param exclude_slide_subdirs Exclude slides/ subfolders, e.g. `c("attic", "rsrc", "all")`.
#' @param exclude_slide_names Exclude slides matching these names exactly, e.g. `"chapter-order"` (default).
#'
#' @return A `data.frame`` with one row per slide `.tex` file.
#' @export
#'
#' @examples
#' \dontrun{
#' collect_lectures()
#' }
collect_lectures <- function(
  lectures_path = here::here(),
  filter_lectures = lectures(),
  exclude_slide_subdirs = c(
    "attic",
    "rsrc",
    "all",
    "figure_man",
    "figures_tikz",
    "figure",
    "tex",
    "backup"
  ),
  exclude_slide_names = c(
    "chapter-order",
    "chapter-order-slides-all",
    "chapter-order-nutshell",
    "nospeakermargin"
  )
) {
  # Take ls with absolute file paths, directories only, and those matching lecture_asdf format
  # Must not use just "lecture_*" because regex or glob will match "lecture_service" as part of
  # absolute file path
  lecture_dirs <- fs::dir_ls(
    lectures_path,
    regexp = "/lecture_[a-z0-9]*$",
    type = "directory"
  )
  # Kick out spurious "lecture_service" match just in case it happens (shouldn't matter though)
  lecture_dirs <- lecture_dirs[which(
    !fs::path_file(lecture_dirs) == "lecture_service"
  )]

  if (length(lecture_dirs) == 0) {
    cli::cli_abort(
      "Found no {.code lecture_*} folders. Looked for {.val {lectures()}}"
    )
  }

  lectures_tbl <- do.call(
    rbind,
    lapply(lecture_dirs, \(lecture_dir) {
      lecture_slides <- fs::path(lecture_dir, "slides")
      if (!fs::dir_exists(lecture_slides)) {
        return(data.frame())
      }

      # It's hard to collect all the slide tex files because naming conventions
      # differ (standard is slide-*.tex, optimization and iml differ),
      # and we don't want stuff in attic/ or the chapter-order.tex file.
      # Not-smart but easy-ish method is to enumerate everything and than filter out
      # the useless stuff.
      topic_dirs <- fs::dir_ls(
        lecture_slides,
        recurse = FALSE,
        type = "directory"
      )
      # Exclude e.g. /slides/all
      topic_dirs <- topic_dirs[which(
        !(fs::path_file(topic_dirs) %in% exclude_slide_subdirs)
      )]
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
        pdf_static = fs::path_tidy(here::here(
          lecture_dir,
          "slides-pdf",
          fs::path_file(pdf_files)
        ))
      )
    })
  )

  if (!is.null(filter_lectures)) {
    #sapply(filter_lectures, checkmate::assert_directory_exists)
    lectures_tbl <- subset(lectures_tbl, lecture %in% filter_lectures)
  }

  # Exclude undesired slide/<folder> and <slide-name>.tex
  lectures_tbl <- subset(lectures_tbl, !(topic %in% exclude_slide_subdirs))
  lectures_tbl <- subset(lectures_tbl, !(slide_name %in% exclude_slide_names))

  # Manual excludeds for WIP and outdated slides
  lectures_tbl <- subset(lectures_tbl, !grepl("^OLD-", slide_name))
  lectures_tbl <- subset(lectures_tbl, !grepl("^TO-DO", slide_name))
  lectures_tbl <- subset(lectures_tbl, !grepl("^TODO", slide_name))

  lectures_tbl$pdf_exists <- fs::file_exists(lectures_tbl$pdf)
  lectures_tbl$pdf_static_exists <- fs::file_exists(lectures_tbl$pdf_static)

  # Normalize paths
  lectures_tbl$tex <- fs::path_norm(lectures_tbl$tex)
  lectures_tbl$tex_log <- fs::path_norm(lectures_tbl$tex_log)
  lectures_tbl$slides_dir <- fs::path_norm(lectures_tbl$slides_dir)
  lectures_tbl$pdf <- fs::path_norm(lectures_tbl$pdf)
  lectures_tbl$pdf_static <- fs::path_norm(lectures_tbl$pdf_static)

  # Rownames were absolute paths to tex files, not helpful
  rownames(lectures_tbl) <- NULL

  lectures_tbl[, c(
    "lecture",
    "topic",
    "slide_name",
    "tex",
    "tex_log",
    "slides_dir",
    "pdf",
    "pdf_exists",
    "pdf_static",
    "pdf_static_exists"
  )]
}

#' Find a slide set across all lectures
#'
#' Lectures need to be stored locally in the current directory with regular names like  `lecture_i2ml`.
#' It is strongly assumed that slide names such as `slides-cart-predictions.tex` are unique across all lectures.
#'
#' @param slide_file `[character(1)]` Name of a (single) slide, with or without `.tex` extension. See examples of [find_slide_tex()].
#' @param lectures_tbl Must contain `tex` column. Defaults to `collect_lectures()`.
#'
#' @export
#' @examplesIf fs::dir_exists(here::here("lecture_i2ml"))
#' # The "normal" way: A .tex file name
#' str(find_slide_tex(slide_file = "slides-cart-computationalaspects.tex"))
#'
#' # Also acceptable: A full path (absolute or relative), convenient for scripts
#' str(find_slide_tex(slide_file = "lecture_i2ml/slides/cart/slides-cart-predictions.tex"))
#'
#' # Lazy way: No extension, just a name
#' str(find_slide_tex(slide_file = "slides-cart-predictions"))
#'
#' # Can also ge tthe .tex file for a .pdf
#' str(find_slide_tex(slide_file = "slides-cart-predictions.pdf"))
find_slide_tex <- function(slide_file, lectures_tbl = collect_lectures()) {
  checkmate::assert_string(slide_file, na.ok = FALSE, min.chars = 1)

  # Allow both "slides-cart-predictions.tex" and lazy "slides-cart-predictions"
  # and "slides-cart-predictions.pdf" because why not.
  if (identical(fs::path_ext(slide_file), "")) {
    slide_file <- fs::path_ext_set(slide_file, "tex")
  }
  if (identical(fs::path_ext(slide_file), "pdf")) {
    slide_file <- fs::path_ext_set(slide_file, "tex")
  }

  if (slide_file %in% lectures_tbl$tex) {
    matching_slides <- lectures_tbl[lectures_tbl$tex == slide_file, ]
  } else if (slide_file %in% fs::path_rel(lectures_tbl$tex)) {
    matching_slides <- lectures_tbl[
      fs::path_rel(lectures_tbl$tex) == slide_file,
    ]
  }

  slide_file <- fs::path_file(slide_file)
  matching_slides <- lectures_tbl[
    fs::path_file(lectures_tbl$tex) == slide_file,
  ]

  if (nrow(matching_slides) == 0) {
    cli::cli_abort("No matching file for {.val {slide_file}}")
  }

  if (nrow(matching_slides) > 1) {
    cli::cli_alert_danger(
      "Found {nrow(matching_slides)} files matching {.val {slide_file}}:"
    )
    cli::cli_li(matching_slides$tex)
    cli::cli_alert_warning("Returning the most recently modified match only:")
    idx_newer <- which.max(fs::file_info(matching_slides$tex)$modification_time)
    matching_slides <- matching_slides[idx_newer, ]
    cli::cli_alert_info("{.val {matching_slides$tex}}")
  }

  matching_slides
}
