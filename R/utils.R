#' Validate and resolve the lecture directory
#'
#' Checks that `lecture_dir` is a valid directory and warns if it appears
#' to be the `lecture_service` root rather than an individual lecture repo.
#'
#' @param lecture_dir Character. Path to the lecture directory.
#' @param lecture_dir_missing Logical. Whether the caller's `lecture_dir`
#'   argument was not explicitly supplied (i.e. `missing(lecture_dir)` in
#'   the calling function). Only warn about `lecture_service` context when
#'   the default was used implicitly.
#' @param call The calling environment for error reporting.
#'
#' @return The normalized `lecture_dir` path (invisibly).
#' @noRd
check_lecture_dir <- function(
  lecture_dir,
  lecture_dir_missing = FALSE,
  call = parent.frame()
) {
  lecture_dir <- normalizePath(lecture_dir, mustWork = FALSE)

  if (!fs::dir_exists(lecture_dir)) {
    cli::cli_abort(
      "Lecture directory {.path {lecture_dir}} does not exist.",
      call = call
    )
  }

  if (lecture_dir_missing && basename(lecture_dir) == "lecture_service") {
    cli::cli_abort(
      c(
        "It looks like you are in the {.path lecture_service} directory.",
        "i" = "Supply {.arg lecture_dir} explicitly, e.g. {.code lecture_dir = here::here(\"lecture_i2ml\")}",
        "i" = "Or run from within a lecture directory like {.path lecture_i2ml/}."
      ),
      call = call
    )
  }

  invisible(lecture_dir)
}


#' Check if packages are installed without loading them
#'
#' Unlike [requireNamespace()], this does not load the package namespace,
#' avoiding `.onLoad` side effects. This matters when conflicting packages
#' coexist (e.g. mlr3 vs mlr, paradox vs ParamHelpers) — loading one
#' namespace can trigger warnings about the other.
#'
#' @param pkgs Character vector of package names.
#' @return A logical vector the same length as `pkgs`.
#' @noRd
is_pkg_installed <- function(pkgs) {
  vapply(pkgs, function(pkg) nzchar(system.file(package = pkg)), logical(1))
}


#' Simple check for availability of system tools
#'
#' Can be used to verify if a tool (e.g. `convert`) is in `$PATH` and findable from within R.
#' Sometimes a tool is in `$PATH` in regular shell sessions but not within R.
#'
#' @param x Name of a binary, e.g. `convert` for ImageMagick or `brew` for Homebrew on macOS.
#' @param strictness `["warning"]` Wether to emit a warning, `"error"`, or nothing (`"none"`) if the tool is not found.
#'
#' @return Invisibly: `TRUE` if the tool is find, `FALSE` otherwise, and an error if `strict` and the tool is not found.
#' @export
#' @examples
#' check_system_tool("diff-pdf", strictness = "none")
check_system_tool <- function(x, strictness = c("warning", "error", "none")) {
  checkmate::assert_character(x, len = 1)
  strictness <- match.arg(strictness)
  which <- Sys.which(x)
  ret <- TRUE
  if (which == "") {
    msg <- "Could not find {x} in $PATH"
    if (strictness == "none") {
      cli::cli_alert_danger(msg)
    }
    if (strictness == "error") {
      cli::cli_abort(msg)
    }
    if (strictness == "warning") {
      cli::cli_alert_warning(msg)
    }
    ret <- FALSE
  }

  invisible(ret)
}

#' Check if docker can be used
#'
#' - `docker` needs to be in `$PATH`
#' - `docker` daemon (or compatible runtime) needs to be running
#'
#' @param strictness `["warning"]` Wether to emit a warning, `"error"`, or nothing (`"none"`) if docker can not be used.
#'
#' @return Invisibly: `TRUE` if the docker seems to be running, `FALSE` otherwise, and an error if `strict` and the tool is not found.
#' @export
#' @examples
#' check_docker(strictness = "none")
check_docker <- function(strictness = c("warning", "error", "none")) {
  strictness <- match.arg(strictness)

  has_docker <- check_system_tool("docker", strictness = strictness)

  if (!has_docker) {
    return(invisible(FALSE))
  }

  p <- processx::process$new(
    command = "docker",
    args = c("stats", "--no-stream")
  )

  p$wait()

  msg_not_running <- "Could not connect to docker runtime, is it running?"
  ret <- TRUE
  if (p$get_exit_status() == 1) {
    if (strictness == "none") {
      cli::cli_alert_danger(msg_not_running)
    }
    if (strictness == "warning") {
      cli::cli_warn(msg_not_running)
    }
    if (strictness == "error") {
      cli::cli_abort(msg_not_running)
    }
    ret <- FALSE
  }

  invisible(ret)
}

#' Manage the with/without margin dummy file
#'
#' See `style/lmu-lecture.sty` where depending on the presence of an empty `.tex` file with a
#' specific name certain layout options are set to compile slides either in 16:9 with margins or
#' in 4:3 without a margin for the speaker.
#'
#' @param wd Working directory (relative or absolute) where the file needs to be created.
#'   This is the directory were the `.tex` file to be compiled is located.
#' @param margin `[TRUE]` Whether to enable or disable the margin.
#' @param token_name `"nospeakermargin.tex"` If the name changes or needs to be flexible for testing
#'  it can be adjusted, but typically the name is set in stone via `lmu-lecture.sty`.
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
set_margin_token_file <- function(
  wd,
  margin = TRUE,
  token_name = "nospeakermargin.tex"
) {
  margin_token_file <- fs::path(wd, token_name)

  if (margin) {
    if (fs::file_exists(margin_token_file)) fs::file_delete(margin_token_file)
  } else {
    fs::file_touch(margin_token_file)
  }
}

#' Install the lecheck cli tool
#'
#' `path` should be in `$PATH` to make the tool usable in shell sessions.
#'
#' @param path `["~/.local/bin"]` Path to symlink the tool to. Must exist and be writable.
#' @param overwrite `[TRUE]` Overwrite any existing symlink.
#'
#' @return `FALSE` if a symlink already exists and is not overwritten.
#'   Otherwise: The path to the symlink is returned.
#' @export
#'
#' @examples
#' if (FALSE) {
#' install_lecheck()
#'
#' # Would only work if the R session is started under a user that can write to /usr/local/bin
#' install_lecheck("/usr/local/bin")
#' }
install_lecheck <- function(path = "~/.local/bin", overwrite = TRUE) {
  lecheck_script <- system.file("lecheck", package = "lese")
  checkmate::assert_file_exists(lecheck_script)

  path <- fs::path_expand(path)
  checkmate::assert_directory_exists(path, access = "w")

  lecheck_bin_path <- fs::path(path, "lecheck")

  if (!fs::link_exists(lecheck_bin_path)) {
    cli::cli_alert_info("Creating symlink at {.file {lecheck_bin_path}}...")
    fs::link_create(lecheck_script, lecheck_bin_path)
  }

  if (fs::link_exists(lecheck_bin_path)) {
    if (overwrite) {
      cli::cli_alert_info(
        "{.file {lecheck_bin_path}} already exists, overwriting..."
      )
      fs::link_delete(lecheck_bin_path)
    } else {
      cli::cli_alert_warning(
        "{.file {lecheck_bin_path}} already exists, doing nothing."
      )
      return(FALSE)
    }
  }
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
