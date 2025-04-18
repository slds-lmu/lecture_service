#' Clean output for a single .tex file
#'
#' Uses `latexmk -C <slide_file>`, also removing the PDF file.
#' Uses `latexmk -c <slide_file>` to keep the PDF file.
#'
#' @inheritParams find_slide_tex
#' @param keep_pdf `[FALSE]`: Keep the PDF file.
#' @param verbose `[TRUE]`: Print additional output to the console.
#'
#' @return Invisibly: A list with entries
#'  - passed: TRUE indicates a successful compilation, FALSE a failure.
#'  - log: Absolute path to the log file in case of a non-zero exit status.
#' @export
#' @examples
#' \dontrun{
#' # Create the PDF
#' compile_slide("slides-cart-computationalaspects.tex")
#'
#'# Remove the PDF and other output
#' clean_slide("slides-cart-computationalaspects.tex")
#' }
clean_slide <- function(slide_file, keep_pdf = FALSE, verbose = FALSE) {
  tmp <- find_slide_tex(slide_file = slide_file)

  # .nav ,.snm, ... are not covered by latexmk -C
  check = sapply(c("nav", "snm", "bbl"), \(ext) {
    detritus <- fs::path_ext_set(tmp$tex, ext)
    if (fs::file_exists(detritus)) {
      # if (verbose) cli::cli_alert("Deleting {detritus}")
      fs::file_delete(detritus)
    }
  })

  clean_arg <- if (keep_pdf) "-c" else "-C"

  pc <- processx::process$new(
    command = "latexmk",
    args = c(clean_arg, tmp$slide_name),
    wd = tmp$slides_dir,
    echo_cmd = verbose
  )
  pc$wait()
  exit <- pc$get_exit_status()
  # I don't see how this should fail, so if it does you dun goof'd
  if (exit != 0) {
    cli::cli_alert_danger(
      "latexmk -C failed for some unholy reason for {slide_file}"
    )
  }

  exit == 0
}

#' Compile a single .tex file
#'
#' @inheritParams find_slide_tex
#' @param pre_clean,post_clean `[TRUE]`: Run [clean_slide()] before / after compilation, ensuring a clean slate.
#' @param margin `[TRUE]` By default renders slides with margin. Otherwise a 4:3 slide is
#'   rendered.
#' @param check_status `[TRUE]`: Wait for `latexmk` to finish and return the exit status.
#' @param verbose `[TRUE]`: Print additional output to the console.
#' @param log `[FALSE]`: Write stdout and stderr logs to `./logs/`.
#' @param method `["system"]`: Either "system" or "docker". Of the latter, uses [latexmk_docker()] for rendering.
#' @param ... For future extension. Currently passed to [latexmk_docker()] or [latexmk_system()].
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
  method = c("system", "docker"),
  ...
) {
  tmp <- find_slide_tex(slide_file = slide_file)
  method <- match.arg(method)

  if (pre_clean) clean_slide(slide_file)

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
    )
  )

  result <- list(passed = NA, log = log_stdout, note = "")

  if (check_status) {
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

  if (post_clean) clean_slide(slide_file, keep_pdf = TRUE)

  invisible(result)
}

#' Compile a .tex file using TinyTex's latexmk emulation
#'
#' TinyTex's [tinytex::latexmk()] automatically installs missing LaTeX packages,
#' making it very useful.
#' This is just a thin wrapper run the command with
#' a changed working directory, as relative paths used in `preamble.tex` etc. require.
#'
#' @inheritParams find_slide_tex
#' @inheritParams compile_slide
#' @param ... Arguments passed to [`tinytex::latexmk()`].
#'
#' @return `TRUE` if an output PDF file exists, `FALSE` otherwise.
#' @export
#'
#' @examples
#' \dontrun{
#' compile_slide_tinytex("lecture_advml/slides/gaussian-processes/slides-gp-basic-3.tex")
#' }
compile_slide_tinytex <- function(slide_file, margin, ...) {
  tex <- find_slide_tex(slide_file = slide_file)[["tex"]]

  newwd <- fs::path_dir(tex)
  oldwd <- setwd(dir = newwd)
  on.exit(setwd(oldwd))

  set_margin_token_file(newwd, margin = margin)

  res <- try(tinytex::latexmk(
    file = tex,
    emulation = TRUE,
    install_packages = TRUE,
    ...
  ))

  fs::file_exists(res)
}
