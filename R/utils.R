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

#' @export
lecture_status_local <- function(lectures = unique(collect_lectures()[["lecture"]])) {
  do.call(rbind, lapply(lectures, \(lecture) {

    if (fs::dir_exists(fs::path(lecture, ".git"))) {
      git2r::remote_url(lecture, "origin")

      lastcommit <- git2r::last_commit(lecture)

      data.frame(
        lecture = lecture,
        branch = git2r::branches(lecture)[[1]][["name"]],
        last_commit_time = as.POSIXct(lastcommit$author$when, tz = "UTC"),
        last_commit_by = lastcommit$author$name,
        last_commit_summary = lastcommit$summary
      )
    } else {

      repo <- jsonlite::fromJSON(sprintf("https://api.github.com/repos/slds-lmu/%s", lecture))
      lastcommit <- jsonlite::fromJSON(sprintf("https://api.github.com/repos/slds-lmu/%s/commits/%s", lecture, repo$default_branch))

      data.frame(
        lecture = lecture,
        branch = repo$default_branch,
        last_commit_time = as.POSIXct(lastcommit$commit$author$date, tz = "UTC", format = "%FT%T"),
        last_commit_by = lastcommit$commit$author$name,
        last_commit_summary = lastcommit$commit$message
      )
    }

  }))
}

#' @export
this_repo_status <- function() {
  lecture_status_local(".")[, -1]
}


# Required in my case to find diff-pdf-visually and its dependencies if installed via homebrew on macOS
if (Sys.info()[["sysname"]] == "Darwin") {
  if (file.exists("/opt/homebrew/bin/brew")) {
    brew_dir <- "/opt/homebrew/bin/"
  }
  if (check_system_tool("brew", warn = FALSE)) {
    brew_dir <- fs::path_dir(Sys.which("brew"))
    Sys.setenv(PATH = paste(Sys.getenv("PATH"), brew_dir, sep = ":"))
  }
}
