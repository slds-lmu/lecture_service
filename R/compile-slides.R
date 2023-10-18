#' Run `make` in a slide directory
#'
#' @param topic `character(1)`> Topic sub-directory to run `make` in, e.g. `slides-cart-predictions`
#' @param lectures_tbl Must contain `tex` column. Defaults to `collect_lectures()`.
#' @param make_arg `["most"]`: Likely not wise to change.
#'   `make all` also copies slides to `slides-pdf`, which may not be intended.
#' @param pre_clean `[TRUE]`: Run `make clean` beforehand, ensuring a clean slate.
#' @param check_status `[TRUE]`: Wait for `make` to finish and return the exit status.
#' @param verbose `[TRUE]`: Print additional output to the console.
#' @param log `[FALSE]`: Write stdout and stderr logs to `./logs/`.

#' @return Invisibly: A list with entries
#'  - passed: TRUE indicates a successful comparison, FALSE a failure.
#'  - log: Absolute path to the log file in case of a non-zero exit status.
#' @export
#'
#' @examples
#' \dontrun{
#' # Default: Run make and output status
#' make_slides("cart")
#' make_slides("regularization", check_status = TRUE)
#'
#' # Runs in background, but doesn't capture exit code
#' make_slides("cart", check_status = FALSE)
#' }
make_slides <- function(topic, lectures_tbl = collect_lectures(), make_arg = "most",
                        pre_clean = TRUE, check_status = TRUE, verbose = TRUE, log = FALSE) {
  tmp <- lectures_tbl[lectures_tbl$topic == topic, ]

  make_arg <- match.arg(make_arg, c("most", "all", "most-normargin", "all-nomargin"))

  stopifnot("No matching topic" = nrow(tmp) != 0)
  stopifnot("Multiple lectures matching topic" = length(unique(tmp$lecture)) == 1)

  slides_dir <- unique(tmp$slides_dir)

  # Clean up beforehand just in case
  if (pre_clean) {
    pc <- processx::process$new(command = "make", args = "clean", wd = slides_dir)
    pc$wait()
    # I don't see how this should fail, so if it does you dun goof'd
    stopifnot("make clean failed for some unholy reason" = pc$get_exit_status() == 0)
  }

  if (log) {
    # Log stderr output
    # Ensuring log dir exists
    if (!(dir.exists("logs"))) dir.create(here::here("logs"))
    log_file <- here::here("logs", paste0(topic, "-make", ".log"))
  } else {
    log_file <- NULL
  }

  # Start process and keep track of it
  p <- processx::process$new(command = "make", args = make_arg, wd = slides_dir, stderr = log_file)
  #p$get_status()

  result <- list(passed = NA, log = log_file)
  if (check_status) {

    p$wait()
    if (p$get_exit_status() == 0) {
      if (verbose) cli::cli_alert_success(topic)

      # Only keep error log if there's an actual error, file contains spurious(?) error msg otherwise
      if (log) fs::file_delete(log_file)
      result$passed <- TRUE
    } else {
      if (verbose) cli::cli_alert_danger("{topic}: make exited with code {p$get_exit_status()}")
      result$passed <- FALSE
    }
  }

  invisible(result)
}



#' Compile a single .tex file
#'
#' @param slide_file `character(1)`: A single slide .tex file (see examples).
#' @param pre_clean `[TRUE]`: Run `make clean` beforehand, ensuring a clean slate.
#' @param margin `[TRUE]` By default renders slides with margin. Otherwise a 4:3 slide is
#'   rendered.
#' @param check_status `[TRUE]`: Wait for `make` to finish and return the exit status.
#' @param verbose `[TRUE]`: Print additional output to the console.
#' @param log `[FALSE]`: Write stdout and stderr logs to `./logs/`.
#'
#' @return Invisibly: A list with entries
#'  - passed: TRUE indicates a successful compilation, FALSE a failure.
#'  - log: Absolute path to the log file in case of a non-zero exit status.
#' @export
#'
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
compile_slide <- function(slide_file, pre_clean = TRUE, margin = TRUE,
                          check_status = TRUE, verbose = TRUE, log = FALSE) {

  tmp <- find_slide_tex(slide_file = slide_file)

  if (pre_clean) {
    pc <- processx::process$new(
      command = "latexmk", args = c("-C", tmp$slide_name),
      wd = tmp$slides_dir, echo_cmd = FALSE)
    pc$wait()
    # I don't see how this should fail, so if it does you dun goof'd
    stopifnot("latexmk -C failed for some unholy reason" = pc$get_exit_status() == 0)
  }

  log_stderr <- NULL
  log_stdout <- NULL

  if (log) {
    # Unfortunately stderr does not contain useful information, as the *actual* reasons why latexmk
    # fails are often buried in the extremely verbose stdout output in my experience.
    if (!fs::dir_exists(here::here("logs"))) fs::dir_create(here::here("logs"))
    # log_stderr <- here::here("logs", paste0(tmp$lecture, "-", tmp$topic, "-", tmp$slide_name, "-stderr.log"))
    # Combine both log streams, keeping them separate is not informative in latexmk's case anyway
    log_stderr <- "2>&1"
    log_stdout <- here::here("logs", paste0(tmp$lecture, "-", tmp$topic, "-",
                                            tmp$slide_name, "-stdout.log"))
  }

  set_margin_token_file(tmp$slides_dir, margin = margin)

  p <- processx::process$new(
    command = "latexmk", args = c("-pdf", tmp$slide_name),
    wd = tmp$slides_dir,
    stderr = log_stderr,
    stdout = log_stdout,
    echo_cmd = FALSE,
    supervise = TRUE
  )

  result <- list(passed = NA, log = log_stdout, note = "")

  if (check_status) {
    p$wait()

    if (p$get_exit_status() == 0) {
      if (verbose) cli::cli_alert_success("{tmp$slide_name} compiles")
      # Only keep error log if there's an actual error, file contains spurious error msg otherwise
      # if (log) {
      #   fs::file_delete(log_stdout)
      #   fs::file_delete(log_stderr)
      # }
      result$passed <- TRUE
    } else {
      if (verbose) cli::cli_alert_danger("{tmp$slide_name} exited with status {p$get_exit_status()}")
      result$passed <- FALSE
      result$note <- check_log(slide_file, before = 0, after = 2)
    }
  }

  invisible(result)
}

#' Compile a .tex file using TinyTex's latexmk emulation
#'
#' Automatically installs missing LaTeX packages. Neat.
#' This is just a thin wrapper run the command with
#' a changed working directory, as relative paths used in `preamble.tex` etc. require.
#'
#' @param tex `character(1)` Full path to a `.tex` file to render.
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
compile_slide_tinytex <- function(tex, margin, ...) {

  tex <- find_slide_tex(slide_file = tex)[["tex"]]

  newwd <- fs::path_dir(tex)
  oldwd <- setwd(dir = newwd)
  on.exit(setwd(oldwd))

  set_margin_token_file(newwd, margin = margin)

  res <- try(tinytex::latexmk(file = tex, emulation = TRUE, install_packages = TRUE, ...))

  file.exists(res)
}
