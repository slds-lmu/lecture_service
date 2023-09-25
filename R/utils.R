#' Simple check for availibility of systemtool
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
#' @param lectures Character vector of lecture repo names, defaults to `unique(collect_lectures()[["lecture"]])`.
#'    E.g. `c("lecture_advml", "lecture_i2ml")`.
#'
#' @return A `data.frame` suitable for display via `kable` in RMarkdown.
#' @export
#' @examples
#' \dontrun{
#' lecture_status_local()
#' }
lecture_status_local <- function(lectures = unique(collect_lectures()[["lecture"]])) {
  do.call(rbind, lapply(lectures, \(lecture) {

    if (fs::dir_exists(fs::path(lecture, ".git"))) {
      # git2r::repository(lecture)

      lastcommit <- git2r::last_commit(lecture)
      # Get name of GitHub org, take remot url, select for github (rather than overleaf), and extract
      org <- git2r::remote_url(lecture) |>
        stringr::str_subset("github") |>
        stringr::str_extract("(https://github.com/|git@github.com:)(.*)/", group = 2)

      data.frame(
        # Using path_file like `basename`, to enable using other paths
        lecture = fs::path_file(lecture),
        org = org,
        branch = git2r::repository_head(lecture)[["name"]],
        last_commit_time = as.POSIXct(lastcommit$author$when, tz = "UTC"),
        last_commit_by = lastcommit$author$name,
        last_commit_summary = lastcommit$summary
      )
    } else {
      # This is for downloaded (not cloned) repos, e.g. on CI. We don't know the upstream repo so we assume defaults.
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
