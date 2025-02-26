#' Check latexmk logs for common errors
#'
#' @param slide_file Name of a slide file, e.g. `"slides-gp-basic-3"`, with optional file extension.
#' @param before,after `[integer(1)]` Number of log lines to display before and after the line found via regex.
#'   Defaults to 0 lines before, 1 line after.
#'
#' @return A `character` with one element per match, with individual lines separated by `\\n` within each element.
#' @export
#'
#' @examples
#' \dontrun{
#' check_log("slides-gp-basic-3")
#' # "976: ! Undefined control sequence.\n976: l.9 \\newcommandiscrete\n"
#' }
check_log <- function(slide_file, before = 0, after = 1) {
  tmp <- find_slide_tex(slide_file = slide_file)

  log_file <- fs::path_ext_set(tmp$tex, "log")
  checkmate::assert_file_exists(log_file)

  loglines <- readLines(log_file, warn = FALSE)
  loglines <- stringr::str_squish(loglines)

  # Trim out empty lines (^$) and comments (^%)
  loglines <- loglines[which(stringr::str_detect(
    loglines,
    "(^%)|(^$)",
    negate = TRUE
  ))]

  error_anchors <- c(
    # Happens when a \command is used but not defined, e.g. missing preamble or package
    "^! Undefined control sequence",
    # Misspecified filename, file not committed to git, or `slides/<topic>/figure/` path instead of `figure/`
    # The latter happens via overleaf autocompletion, should be checked in .tex files via regex explicitly.
    "not found",
    # Missing $ delimiter for math
    "^! Missing \\$ inserted",
    # Generic error
    "! LaTeX Error:"
  )

  # Not sure how to output this yet. A single string with \n can be useful, but for cli and HTML contexts
  # there'd need to be some post-processing.
  ret <- unlist(sapply(
    error_anchors,
    \(e) extract_log_match(loglines, e, before = before, after = after)
  ))
  unname(ret[which(lengths(ret) > 0)])
}

extract_log_match <- function(text, pattern, before = 0, after = 1) {
  matchnum <- which(stringr::str_detect(text, pattern))

  if (length(matchnum) == 0) return(NULL)

  vapply(
    matchnum,
    \(x) {
      matchlines <- text[seq(x - before, x + after)]
      matchlines <- paste0(x, ": ", matchlines)
      matchlines <- paste0(matchlines, collapse = "\n")
      paste0(matchlines, "\n")
    },
    FUN.VALUE = character(1),
    USE.NAMES = FALSE
  )
}
