#' Run dockerized latexmk
#'
#' This uses the docker image from <https://gitlab.com/islandoftex/images/texlive>.
#' The defautl uses tag `TL2023-historic` for TeXLive 2023.
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
#'   registry.gitlab.com/islandoftex/images/texlive:TL2023-historic \
#'   latexmk -pdf -halt-on-error slides-basics-data.tex
#' ```
#'
#' @inheritParams find_slide_tex
#' @param verbose `[TRUE]`: Print output from `docker`/`latexmk` to console.
#' @param tag `["TL2023-historic"]`: Tag of `texlive` docker image to use.
#' @param log_stdout,log_stderr `[""]`: Path to write stdout/stderr log to. Discared if `NULL` or inherited from main R process if `""`. `stderr` can be redirected to `stdout` with `"2>&1"`.
#' @param supervise `[TRUE]`: Passed to [processx::process()]'s `$new()`.
#' @return A [processx::process()] object.
#' @seealso [latexmk_system()] [compile_slide()]
#' @examples
#' \dontrun{
#' latexmk_docker("slides-advriskmin-bias-variance-decomposition.tex")
#' }
latexmk_docker <- function(
  slide_file,
  verbose = TRUE,
  tag = "TL2023-historic",
  log_stdout = "",
  log_stderr = "",
  supervise = TRUE
) {
  tmp <- find_slide_tex(slide_file = slide_file)

  check_system_tool("docker", strictness = "error")

  # Get absolute path up to "lecture_XYZ" bit for mounting into docker container
  lecture_dir <- fs::path_dir(tmp$slides_dir) |>
    fs::path_dir()
  # Get relative path to topic directory, ust "advriskmin" for example, to set working directory within container
  topic_dir_rel <- fs::path_file(tmp$slides_dir)

  # Need numeric user ID to start docker container
  # Otherwise created files are owned by root:root which is inconvenient
  uid <- system("id -u", intern = TRUE)

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
      glue::glue("/usr/src/app/slides/{topic_dir_rel}"),
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
#' This utility is usaully invoked by [compile_slide()].
#'
#' `latexmk` needs to be in `$PATH` for this to work.
#'
#' @inheritParams latexmk_docker
#' @seealso [latexmk_docker()] [compile_slide()]
#' @return A [processx::process()] object.
## @examples
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
