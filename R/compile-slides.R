#' Compile a single .tex file
#'
#' @inheritParams find_slide_tex
#' @param pre_clean,post_clean `[TRUE]`: Run [clean_slide()] before / after compilation, ensuring a clean slate.
#' @param margin `[TRUE]` By default renders slides with margin. Otherwise a 4:3 slide is
#'   rendered.
#' @param check_status `[TRUE]`: Wait for `latexmk` to finish and return the exit status. Not supported for `method = "tinytex"`.
#' @param verbose `[TRUE]`: Print additional output to the console.
#' @param log `[FALSE]`: Write stdout and stderr logs to `./logs/`. Not supported for `method = "tinytex"`.
#' @param method `["system"]`: `"system"` uses [latexmk_system()], "docker" uses [latexmk_docker()],
#'   and `"tinytex"` uses [latexmk_tinytex()].
#' @param ... For future extension. Currently passed to function invoked via `method`.
#' @return Invisibly: A list with entries
#'  - passed: TRUE indicates a successful compilation, FALSE a failure.
#'  - log: Absolute path to the log file in case of a non-zero exit status.
#' @export
#' @seealso [latexmk_docker()] and [latexmk_system()] for internal compilation methods.

#' @examples
#' \dontrun{
#' # The "normal" way: A .tex file name
#' compile_slide("slides-cart-computationalaspects.tex")
#'
#' # Also acceptable: A full path (absolute or relative), convenient for scripts
#' compile_slide("lecture_advml/slides/gaussian-processes/slides-gp-bayes-lm.tex")
#'
#' # Lazy way: No extension, just a name
#' compile_slide("slides-cart-predictions")
#' }
compile_slide <- function(
  slide_file,
  pre_clean = TRUE,
  post_clean = TRUE,
  margin = TRUE,
  check_status = TRUE,
  verbose = TRUE,
  log = FALSE,
  method = c("system", "docker", "tinytex"),
  ...
) {
  tmp <- find_slide_tex(slide_file = slide_file)
  method <- match.arg(method)

  if (pre_clean) clean_slide(slide_file, check_status = check_status)

  log_stderr <- NULL
  log_stdout <- NULL

  if (log) {
    # Unfortunately stderr does not contain useful information, as the *actual* reasons why latexmk
    # fails are often buried in the extremely verbose stdout output in my experience.
    if (!fs::dir_exists(here::here("logs"))) fs::dir_create(here::here("logs"))
    # log_stderr <- here::here("logs", paste0(tmp$lecture, "-", tmp$topic, "-", tmp$slide_name, "-stderr.log"))
    # Combine both log streams, keeping them separate is not informative in latexmk's case anyway
    log_stderr <- "2>&1"
    log_stdout <- here::here(
      "logs",
      paste0(tmp$lecture, "-", tmp$topic, "-", tmp$slide_name, "-stdout.log")
    )
  }

  set_margin_token_file(tmp$slides_dir, margin = margin)

  # Picking the latexmk to use, system or docker
  # When I made this a switch statement I assumed less redundancy than I actually built.
  p <- switch(
    method,
    system = latexmk_system(
      slide_file = slide_file,
      verbose = verbose,
      log_stdout = log_stdout,
      log_stderr = log_stderr,
      supervise = check_status,
      ...
    ),
    docker = latexmk_docker(
      slide_file = slide_file,
      verbose = verbose,
      log_stdout = log_stdout,
      log_stderr = log_stderr,
      supervise = check_status,
      ...
    ),
    tinytex = latexmk_tinytex(slide_file = slide_file, ...)
  )

  result <- list(passed = NA, log = log_stdout, note = "")

  # tinytex's result is just boolean, can't do any fancy checking
  if (check_status & method != "tinytex") {
    p$wait()

    if (p$get_exit_status() == 0) {
      cli::cli_alert_success("{tmp$slide_name} compiles")
      # Only keep error log if there's an actual error, file contains spurious error msg otherwise
      # if (log) {
      #   fs::file_delete(log_stdout)
      #   fs::file_delete(log_stderr)
      # }
      result$passed <- TRUE
    } else {
      cli::cli_alert_danger(
        "{tmp$slide_name} exited with status {p$get_exit_status()}"
      )
      result$passed <- FALSE
      result$note <- check_log(slide_file, before = 0, after = 2)
    }
  }

  if (post_clean)
    clean_slide(slide_file, keep_pdf = TRUE, check_status = check_status)

  invisible(result)
}
