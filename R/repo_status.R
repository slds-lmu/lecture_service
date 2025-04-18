#' Lecture repo status
#'
#' Show latest changes to locally available lectures.
#'
#' @param lecture Character vector of lecture repo names, defaults to `lectures()`.
#'    E.g. `c("lecture_advml", "lecture_i2ml")`.
#'
#' @return A `data.frame` suitable for display via `kable` in RMarkdown.
#'
#' @importFrom stringi stri_escape_unicode
#' @export
#'
#' @examples
#' if (FALSE) repo_status()
repo_status <- function(lecture = lectures()) {
  do.call(
    rbind,
    lapply(lecture, \(this_lecture) {
      if (fs::dir_exists(fs::path(this_lecture, ".git"))) {
        lastcommit <- git2r::last_commit(this_lecture)
        # Get name of GitHub org, take remot url, select for github (rather than overleaf), and extract
        org <- git2r::remote_url(this_lecture) |>
          stringr::str_subset("github") |>
          # SSH vs HTTP clone URLs differ but basic idea is the same
          stringr::str_extract(
            "(https://github.com/|git@github.com:)(.*)/",
            group = 2
          )

        branch <- git2r::repository_head(this_lecture)[["name"]]
        if (is.null(branch)) branch <- "?"

        data.frame(
          # Using path_file like `basename`, to enable using other paths
          lecture = fs::path_file(this_lecture),
          org = org,
          branch = branch,
          last_commit_time = as.POSIXct(lastcommit$author$when, tz = "UTC"),
          last_commit_by = lastcommit$author$name,
          last_commit_summary = stringi::stri_escape_unicode(lastcommit$summary)
        )
      } else {
        # This is for downloaded (not cloned) repos, e.g. on CI.
        # We don't know the upstream repo so we assume defaults.
        repo <- jsonlite::fromJSON(sprintf(
          "https://api.github.com/repos/slds-lmu/%s",
          lecture
        ))
        lastcommit <- jsonlite::fromJSON(sprintf(
          "https://api.github.com/repos/slds-lmu/%s/commits/%s",
          lecture,
          repo$default_branch
        ))

        data.frame(
          lecture = fs::path_file(lecture),
          org = "slds-lmu",
          branch = repo$default_branch,
          last_commit_time = as.POSIXct(
            lastcommit$commit$author$date,
            tz = "UTC",
            format = "%FT%T"
          ),
          last_commit_by = lastcommit$commit$author$name,
          last_commit_summary = stringi::stri_escape_unicode(
            lastcommit$commit$message
          )
        )
      }
    })
  )
}

#' Service repo checkout status
#'
#' Same as `repo_status()` but for this service repo
#'
#' @export
#' @examples
#' if (FALSE) this_repo_status()
this_repo_status <- function() {
  ret <- repo_status(".")
  ret[["lecture"]] <- "lecture_service"

  ret
}
