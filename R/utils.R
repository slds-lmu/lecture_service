#' Simple check for availability of system tools
#'
#' Can be used to verify if a tool (e.g. `convert`) is in `$PATH` and findable from within R.
#' Sometimes a tool is in `$PATH` in regular shell sessions but not within R.
#'
#' @param x Name of a binary, e.g. `convert` for ImageMagick or `brew` for Homebrew on macOS.
#' @param strict `[FALSE]` Whether to `stop()` if the tool is not found or return `FALSE` with a warning.
#' @param warn `[TRUE]` Whether to show a warning if the tool is no found. Only has an effect if `!strict`.
#'
#' @return `TRUE` if the tool is find, `FALSE` otherwise, and an error if `strict == TRUE` and the tool is not found.
#' @export
check_system_tool <- function(x, strict = FALSE, warn = TRUE) {
  checkmate::assert_character(x, len = 1)
  which <- Sys.which(x)

  if (which == "") {
    msg <- "Could not find {x} in $PATH"
    if (strict) cli::cli_abort(msg)
    if (warn) cli::cli_alert_warning(msg)
    return(FALSE)
  }

  TRUE
}

#' Collect the git status of lectures
#'
#' @param lectures Character vector of lecture repo names, defaults to `lectures()`.
#'    E.g. `c("lecture_advml", "lecture_i2ml")`.
#'
#' @return A `data.frame` suitable for display via `kable` in RMarkdown.
#' @export
#' @examples
#' \dontrun{
#' lecture_status_local()
#' }
lecture_status_local <- function(lectures = lectures()) {
  do.call(rbind, lapply(lectures, \(lecture) {

    if (fs::dir_exists(fs::path(lecture, ".git"))) {
      # git2r::repository(lecture)

      lastcommit <- git2r::last_commit(lecture)
      # Get name of GitHub org, take remot url, select for github (rather than overleaf), and extract
      org <- git2r::remote_url(lecture) |>
        stringr::str_subset("github") |>
        # SSH vs HTTP clone URLs differ but basic idea is the same
        stringr::str_extract("(https://github.com/|git@github.com:)(.*)/", group = 2)

      branch <- git2r::repository_head(lecture)[["name"]] %||% "?"

      data.frame(
        # Using path_file like `basename`, to enable using other paths
        lecture = fs::path_file(lecture),
        org = org,
        branch = branch,
        last_commit_time = as.POSIXct(lastcommit$author$when, tz = "UTC"),
        last_commit_by = lastcommit$author$name,
        last_commit_summary = lastcommit$summary
      )
    } else {
      # This is for downloaded (not cloned) repos, e.g. on CI.
      # We don't know the upstream repo so we assume defaults.
      repo <- jsonlite::fromJSON(sprintf("https://api.github.com/repos/slds-lmu/%s", lecture))
      lastcommit <- jsonlite::fromJSON(sprintf("https://api.github.com/repos/slds-lmu/%s/commits/%s", lecture, repo$default_branch))

      data.frame(
        lecture = fs::path_file(lecture),
        org = "slds-lmu",
        branch = repo$default_branch,
        last_commit_time = as.POSIXct(lastcommit$commit$author$date, tz = "UTC", format = "%FT%T"),
        last_commit_by = lastcommit$commit$author$name,
        last_commit_summary = lastcommit$commit$message
      )
    }

  }))
}

#' lecture_status_local() but for this service repo
#'
#' @return A `data.frame` similar to `lecture_status_local()`.
#' @export
this_repo_status <- function() {
  ret <- lecture_status_local(".")
  ret[["lecture"]] <- "lecture_service"

  ret
}


#' Auto-set the with/without margin dummy file
#'
#' See `style/lmu-lecture.sty` where depending on the presence of an empty `.tex` file with a
#' specific name certain layout options are set to compile slides either in 16:9 with margins or
#' in 4:3 without a margin for the speaker.
#'
#' @param wd Working directory (relative or absolute) where the file needs to be created.
#'   This is the directory were the `.tex` file to be compiles is located.
#' @param margin `[TRUE]` Whether to enable (`TRUE`, default) or disable (`FALSE`) the margin.
#' @param token_name `"nospeakermargin.tex"` If the name changes or needs to be flexible for testing
#'  it can be adjusted, but typically the default is set in stone.
#'
#' @return Nothing
#' @export
#'
#' @examples
#' wd <- tempdir()
#'
#' set_margin_token_file(wd = wd, margin = FALSE)
#' stopifnot("file exists when no margin set" = file.exists(file.path(wd, "nospeakermargin.tex")))
#'
#' set_margin_token_file(wd = wd, margin = TRUE)
#' stopifnot("file is removed when margin set" = !file.exists(file.path(wd, "nospeakermargin.tex")))
set_margin_token_file <- function(wd, margin = TRUE, token_name = "nospeakermargin.tex") {
  margin_token_file <- fs::path(wd, token_name)

  if (margin) {
    if (fs::file_exists(margin_token_file)) fs::file_delete(margin_token_file)
  } else {
    fs::file_touch(margin_token_file)
  }
}


#' Install the lecheck cli tool
#'
#' `path` should be in the user's `$PATH` to make the tool usable in shell sessions.
#'
#' @param path `["~/bin"]` Path to symlink the tool to. Must exist and be writable.
#' @param overwrite `[TRUE]` Overwrite any existing symlink.
#'
#' @return `FALSE` if a symlink already exists and is not overwritten.
#'   Otherwise: The path to the symlink is returned.
#' @export
#'
#' @examples
#' if (FALSE) {
#' install_lecheck("~/bin")
#'
#' # Would only work if the R session is started under a user that can write to /usr/local/bin
#' install_lecheck("/usr/local/bin")
#' }
install_lecheck <- function(path = "~/bin", overwrite = TRUE) {
  lecheck_script <- system.file("lecheck", package = "lese")
  checkmate::assert_file_exists(lecheck_script)

  path <- fs::path_expand(path)
  checkmate::assert_directory_exists(path, access = "w")

  lecheck_bin_path <- fs::path(path, "lecheck")

  if (fs::link_exists(lecheck_bin_path)) {
    if (overwrite) {
      cli::cli_alert_info("{lecheck_bin_path} already exists, overwriting...")
      fs::link_delete(lecheck_bin_path)
    } else {
      cli::cli_alert_warning("{lecheck_bin_path} already exists, doing nothing.")
      return(FALSE)
    }
  }

  fs::link_create(lecheck_script, lecheck_bin_path)
}

#' Default value for `NULL`
#'
#' This infix function makes it easy to replace `NULL`s with a default
#' value. It's inspired by the way that Ruby's or operation (`||`)
#' works.
#'
#' @param x,y If `x` is NULL or length 0, will return `y`; otherwise returns `x`.
#' @rawNamespace if (getRversion() < "4.3.0") export(`%||%`)
#' @name op-null-default
#' @examples
#' 1 %||% 2
#' NULL %||% 2
#' character(0) %|0|% ""
#' list() %|0|% ""
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

#' @rdname op-null-default
#' @export
`%|0|%` <- function(x, y) {
  if (!length(x)) y else x
}

# Required in my case to find diff-pdf-visually and its dependencies if installed via homebrew on macOS
# if (Sys.info()[["sysname"]] == "Darwin") {
#   if (file.exists("/opt/homebrew/bin/brew")) {
#     brew_dir <- "/opt/homebrew/bin/"
#   }
#   if (check_system_tool("brew", warn = FALSE)) {
#     brew_dir <- fs::path_dir(Sys.which("brew"))
#     Sys.setenv(PATH = paste(Sys.getenv("PATH"), brew_dir, sep = ":"))
#   }
# }
