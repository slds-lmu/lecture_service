#' Run dockerized latexmk
#'
#' This uses the docker image from <https://gitlab.com/islandoftex/images/texlive>.
#' The default uses tag `TL2025-historic` for TeXLive 2025.
#'
#' You will need to install docker or podman or some other compatible runtime on your system beforehand.
#'
#' The docker command run by this is equivalent to something like
#'
#' ```sh
#' cd path/to/lecture_i2ml/slides/ml-basics
#'
#' CWD=$(basename ${PWD})
#' LECTURE=$(dirname $(dirname ${PWD}))
#'
#' docker run -i --rm --user $(id -u) --name latex \
#'   -v "${LECTURE}":/usr/src/app:z \
#'   -w "/usr/src/app/slides/${CWD}" \
#'   registry.gitlab.com/islandoftex/images/texlive:TL2025-historic \
#'   latexmk -pdf -halt-on-error slides-basics-data.tex
#' ```
#'
#' @inheritParams find_slide_tex
#' @param verbose `[TRUE]`: Print output from `docker`/`latexmk` to console.
#' @param tag `["TL2025-historic"]`: Tag of `texlive` docker image to use.
#' @param log_stdout,log_stderr `[""]`: Path to write stdout/stderr log to.
#'   Discarded if `NULL` or inherited from main R process if `""`.
#'   `stderr` can be redirected to `stdout` with `"2>&1"`.
#' @param supervise `[TRUE]`: Passed to [processx::process()]'s `$new()`.
#' @return A [processx::process()] object.
#' @note This utility is usually invoked by [compile_slide()].
#' @examples
#' \dontrun{
#' latexmk_docker("slides-cart-treegrowing.tex")
#' }
latexmk_docker <- function(
  slide_file,
  verbose = TRUE,
  tag = "TL2025-historic",
  log_stdout = "",
  log_stderr = "",
  supervise = TRUE
) {
  tmp <- find_slide_tex(slide_file = slide_file)

  check_docker(strictness = "error")

  # Get absolute path up to "lecture_XYZ" bit for mounting into docker container
  lecture_dir <- fs::path_dir(tmp$slides_dir) |>
    fs::path_dir()
  # Get relative path to chapter directory, ust "advriskmin" for example, to set working directory within container
  chapter_dir_rel <- fs::path_file(tmp$slides_dir)

  # Need numeric user ID to start docker container
  # Otherwise created files are owned by root:root which is inconvenient
  uid <- system("id -u", intern = TRUE)
  if (!is.integer(as.integer(uid))) {
    cli::cli_abort("Could not determine user ID via {.code id -u}")
  }

  processx::process$new(
    command = "docker",
    args = c(
      "run",
      "-i",
      "--rm",
      "--user",
      uid,
      "--name",
      "slds-latex",
      "-v",
      glue::glue("{lecture_dir}:/usr/src/app:z"),
      "-w",
      glue::glue("/usr/src/app/slides/{chapter_dir_rel}"),
      glue::glue("registry.gitlab.com/islandoftex/images/texlive:{tag}"),
      "latexmk",
      "-pdf",
      "-halt-on-error",
      fs::path_file(tmp$tex)
    ),
    wd = tmp$slides_dir,
    stderr = log_stderr,
    stdout = log_stdout,
    echo_cmd = verbose,
    supervise = supervise
  )
}

#' Run latexmk
#'
#' `latexmk` needs to be in `$PATH` for this to work.
#'
#' @inheritParams latexmk_docker
#' @return A [processx::process()] object.
#' @note This utility is usually invoked by [compile_slide()].
#' @examples
#' \dontrun{
#' latexmk_system("slides-advriskmin-bias-variance-decomposition.tex")
#' }
latexmk_system <- function(
  slide_file,
  verbose = TRUE,
  log_stdout = "",
  log_stderr = "",
  supervise = TRUE
) {
  tmp <- find_slide_tex(slide_file = slide_file)

  check_system_tool("latexmk", strictness = "error")

  processx::process$new(
    command = "latexmk",
    args = c("-pdf", tmp$slide_name),
    # Need to change to directory of slide, could also use  "--cd" option for latexmk probably
    wd = tmp$slides_dir,
    stderr = log_stderr,
    stdout = log_stdout,
    echo_cmd = verbose,
    supervise = supervise
  )
}

#' Run TinyTex's latexmk
#'
#' A thin wrapper around [tinytex::latexmk()].
#'
#' TinyTex's [tinytex::latexmk()] automatically installs missing LaTeX packages,
#' making it very useful.
#' This is just a thin wrapper run the command with
#' a changed working directory, as relative paths used in `preamble.tex` etc. require.
#'
#' @inheritParams latexmk_docker
#' @inheritParams find_slide_tex
#' @param ... Arguments passed to [tinytex::latexmk()], excluding `clean`, which is always `FALSE` as this is handled by `[compile_slide()]`.
#' @return `TRUE` if the output PDF exists, `FALSE` otherwise.
#' @note This utility is usually invoked by [compile_slide()].
#' @examples
#' \dontrun{
#' latexmk_tinytex("slides-advriskmin-bias-variance-decomposition.tex")
#' }
latexmk_tinytex <- function(slide_file, ...) {
  tex <- find_slide_tex(slide_file = slide_file)[["tex"]]

  newwd <- fs::path_dir(tex)
  oldwd <- setwd(dir = newwd)
  on.exit(setwd(oldwd))

  res <- try(tinytex::latexmk(
    file = tex,
    emulation = TRUE,
    install_packages = TRUE,
    clean = FALSE, # cleaning is handled by compile_slide()
    ...
  ))

  fs::file_exists(res)
}
