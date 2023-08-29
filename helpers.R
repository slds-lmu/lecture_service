#' Assemble table of lecture slides
#'
#' @param lectures_path Path containing lecture_* directories. Defaulting to `here::here()`.
#' @param filter_lectures `[NULL]`: Vector of lecture repo names to filter table by, e.g. `"lecture_i2ml"`.
#' @param exclude_slide_subdirs Exclude slides/ subfolders, e.g. `c("attic", "rsrc", "all")`.
#' @param exclude_slide_names Exclude slides matching these names exactly, e.g. `"chapter-order"` (default).
#'
#' @return A data.frame with one row per slide .tex file.
# @export
#'
#' @examples
#' collect_lectures()
collect_lectures <- function(lectures_path = here::here(),
                             filter_lectures = NULL,
                             exclude_slide_subdirs = c("attic", "rsrc", "all", "figure_man", "figures_tikz",
                                                       "figure", "tex", "backup"),
                             exclude_slide_names = "chapter-order") {

  lecture_dirs <- fs::dir_ls(lectures_path, regexp = "/lecture_")
  # Kick out spurious "lecture_service" match just in case it happens (shouldn't matter though)
  lecture_dirs <- lecture_dirs[which(!fs::path_file(lecture_dirs) == "lecture_service")]

  stopifnot("Found no lecture_* folders" = length(lecture_dirs) > 0)

  lectures_tbl <- do.call(rbind, lapply(lecture_dirs, \(lecture_dir) {
    lecture_slides <- fs::path(lecture_dir, "slides")
    if (!fs::dir_exists(lecture_slides)) return(data.frame())

    # It's hard to collect all the slide tex files because naming conventions
    # differ (standard is slide-*.tex, optimization and iml differ),
    # and we don't want stuff in attic/ or the chapter-order.tex file.
    # Not-smart but easy-ish method is to enumerate everything and than filter out
    # the useless stuff.
    topic_dirs <- fs::dir_ls(lecture_slides, recurse = FALSE, type = "directory")
    # Exclude e.g. /slides/all
    topic_dirs <- topic_dirs[which(!(fs::path_file(topic_dirs) %in% exclude_slide_subdirs))]
    # Non-recursively list tex files now, so we avoid
    # e.g. lecture_i2ml/slides/tuning/attic/ files
    tex_files <- fs::dir_ls(topic_dirs, recurse = FALSE, glob = "*.tex")
    slides_dir <- fs::path_tidy(fs::path_dir(tex_files))
    pdf_files <- fs::path_ext_set(tex_files, "pdf")

    data.frame(
      lecture = fs::path_file(lecture_dir),
      tex = tex_files,
      slides_dir = slides_dir,
      topic = fs::path_file(slides_dir),
      slide_name = fs::path_file(fs::path_ext_remove(tex_files)),
      pdf = pdf_files,
      pdf_static = fs::path_tidy(here::here(lecture_dir, "slides-pdf", fs::path_file(pdf_files)))
    )
  }))

  if (!is.null(filter_lectures)) {
    sapply(filter_lectures, checkmate::assert_directory_exists)
    lectures_tbl <- subset(lectures_tbl, lecture %in% filter_lectures)
  }

  # Exclude undesired slide/<folder> and <slide-name>.tex
  lectures_tbl <- subset(lectures_tbl, !(topic %in% exclude_slide_subdirs))
  lectures_tbl <- subset(lectures_tbl, !(slide_name %in% exclude_slide_names))
  lectures_tbl <- subset(lectures_tbl, !grepl("^OLD-", slide_name))


  lectures_tbl$pdf_exists <- fs::file_exists(lectures_tbl$pdf)
  lectures_tbl$pdf_static_exists <- fs::file_exists(lectures_tbl$pdf_static)

  lectures_tbl[, c("lecture", "topic", "slide_name", "tex", "slides_dir", "pdf", "pdf_exists", "pdf_static", "pdf_static_exists")]
}

# Might as well do the thing
#lectures_tbl <- collect_lectures()


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
# @export
#'
#' @examples
#' # Default: Run make and output status
#' make_slides("cart")
#' make_slides("regularization", check_status = TRUE)
#'
#' # Runs in background, but doesn't capture exit code
#' make_slides("cart", check_status = FALSE)
make_slides <- function(topic, lectures_tbl = collect_lectures(), make_arg = "most", pre_clean = TRUE, check_status = TRUE, verbose = TRUE, log = FALSE) {
  tmp <- lectures_tbl[lectures_tbl$topic == topic, ]

  make_arg <- match.arg(make_arg, c("most", "all"))

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
#' @param check_status `[TRUE]`: Wait for `make` to finish and return the exit status.
#' @param verbose `[TRUE]`: Print additional output to the console.
#' @param log `[FALSE]`: Write stdout and stderr logs to `./logs/`.
#'
#' @return Invisibly: A list with entries
#'  - passed: TRUE indicates a successful compilation, FALSE a failure.
#'  - log: Absolute path to the log file in case of a non-zero exit status.
# @export
#'
#' @examples
#' # The "normal" way: A .tex file name
#' compile_slide("slides-cart-computationalaspects.tex")
#'
#' # Also acceptable: A full path (absolute or relative), convenient for scripts
#' compile_slide("lecture_advml/slides/gaussian-processes/slides-gp-bayes-lm.tex")
#'
#' # Lazy way: No extension, just a name
#' compile_slide("slides-cart-predictions")
compile_slide <- function(slide_file, pre_clean = TRUE, check_status = TRUE, verbose = TRUE, log = FALSE) {

  tmp <- find_slide_tex(slide_file = slide_file)

  if (pre_clean) {
    pc <- processx::process$new(command = "latexmk", args = c("-C", tmp$slide_name), wd = tmp$slides_dir)
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
    log_stderr <- here::here("logs", paste0(tmp$topic, "-", tmp$slide_name, "-stderr.log"))
    log_stdout <- here::here("logs", paste0(tmp$topic, "-", tmp$slide_name, "-stdout.log"))
  }

  p <- processx::process$new(command = "latexmk", args = c("-pdf", tmp$slide_name),
                             wd = tmp$slides_dir, stderr = log_stderr, stdout = log_stdout, supervise = TRUE)
  # out_stdout <- p$read_all_output()
  # out_stderr <- p$read_all_error()
  # out_status <- p$get_exit_status()

  result <- list(passed = NA, log = log_stdout)

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
    }
  }

  invisible(result)
}



#' Compare slide PDF against reference PDF
#'
#' A compiled .tex file such as `slides/gaussian-processes/slides-gp-bayes-lm.pdf` will be compared with
#' an assumed to be accepted / known good version at `slides-pdf/slides-gp-bayes-lm.pdf` if it exists.
#'
#' First uses `diff-pdf-visually` to check slides for differences based on the PSNR of rasterised versions
#' of the slides (adjustable with `thresh_psnr`), and then uses `diff-pdf` to create a PDF highlighting
#' the differences if `create_comparison_pdf` is `TRUE`.
#'
#' This only re-runs `diff-pdf` to create a comparison PDF file if the
#' output file under `./comparison/<slide-name>.pdf` is more recent than both of the input PDF files.
#' That way you can safely re-run this function repeatedly without worrying about computational overhead.
#'
#' @param slide_file `character(1)`: A single slide .tex file (see examples).
#' @param verbose `[TRUE]`: Print additional output to the console.
#' @param create_comparison_pdf `[FALSE]`: Use `diff-pdf` to create a comparison PDF at `./comparison/<slide-name>.pdf`
#' @param thresh_psnr `[40]`: PSNR threshold for difference detection in `diff-pdf-visually`.
#'   Higher is more sensitive.
#' @param dpi_check `[50]` Resolution for rasterised files used by both `diff-pdf-visually`.
#'   Lower is more coarse.
#' @param dpi_out `[100]` Resolution for output PDF produced by `diff-pdf`.
#'   Lower values will lead to very pixelated diff PDFs.
#' @param pixel_tol `[20]` Per-page pixel tolerance for comparison used by `diff-pdf`.
#' @param view `[FALSE] For interactive use: Opens window showing comparison diff.
#' @param overwrite `[FALSE]` Re-creates output diff PDF even if it already exists and appears up to date.
#' @return Invisibly: A list of results:
#'   - passed: TRUE indicates a successful comparison, FALSE a failure.
#'   - reason: Shorthand reason for a failing comparison.
#'   - pages: Vector of pages with differences.
#'   - output: Full output produced by diff-pdf-visually.
# @export
#
#' @note Uses `diff-pdf-visually` and `diff-pdf` under the hood, you may need to adjust your $PATH.
#'
#' @examples
#' # The "normal" way: A .tex file name
#' compare_slide("slides-cart-computationalaspects.tex")
#'
#' # Also acceptable: A full path (absolute or relative), convenient for scripts
#' compare_slide("lecture_advml/slides/gaussian-processes/slides-gp-bayes-lm.tex")
#'
#' # Lazy way: No extension, just a name
#' compare_slide("slides-cart-predictions")
#'
#' # Whoopsie supplied name of PDF instead no biggie I got u
#' compare_slide("slides-forests-proximities.pdf")
#'
#' compare_slide("slides-boosting-cwb-basics")
compare_slide <- function(slide_file, verbose = TRUE, create_comparison_pdf = FALSE,
                          thresh_psnr = 40, dpi_check = 50, dpi_out = 100,
                          pixel_tol = 20, view = FALSE, overwrite = FALSE) {

  tmp <- find_slide_tex(slide_file = slide_file)

  result <- list(passed = NA, reason = "", pages = "", signif = "", output = "")

  # Run check again rather than relying on tmp$pdf_exists just in case PDF was just compiled
  if (!(fs::file_exists(tmp$pdf))) {
    if (verbose) cli::cli_alert_warning("{tmp$slide_name}: No compiled PDF")
    result$passed <- FALSE
    result$reason <- "No compiled PDF"
    return(result)
  }

  if (!tmp$pdf_static_exists) {
    if (verbose) cli::cli_alert_warning("{tmp$slide_name}: No reference PDF to compare to")
    result$passed <- FALSE
    result$reason <- "No reference PDF"
    return(result)
  }

  if (!check_system_tool("diff-pdf-visually")) {
    return(result)
  }

  args <- c(
    #"-v",
    sprintf("--threshold=%s", thresh_psnr),
    sprintf("--dpi=%s", dpi_check),
    tmp[["pdf"]], tmp[["pdf_static"]]
  )
  # Might require $PATH adjustments to work
  p <- processx::process$new(
    command = "diff-pdf-visually", args = args,
    stdout = "|", stderr = "|",
    echo_cmd = verbose
  )
  # This is the command that's actually executed in quick "print for debugging" format
  # paste0(c("diff-pdf-visually", args), collapse = " ")

  p$wait()

  # p$get_exit_status()
  # Catch error, usually happens when diff-pdf-visually dependencies are not in $PATH, most likely
  # the ImageMagick `compare` utility.
  error <- p$read_all_error_lines()
  if (length(error) > 0) {
    cli::cli_abort(error[length(error)])
  }

  output <- p$read_all_output_lines()
  keep <- which(!grepl("(^  Temporary directory)|(^  Converting each)|(same number of pages)", output))
  output <- output[keep]

  if (length(output) == 0) {
    # This happens e.g. when $PATH does not include diff-pdf-visually dependencies, but the tool itself
    # Symptom is that `output` contains the first two lines as normal but no actual check output
    cli::cli_abort("Could not parse diff-pdf-visually output correctly for {tmp$slide_name}")
  }

  result$output <- output

  if (grepl("PDFs are the same", output)) {
    if (verbose) cli::cli_alert_success(tmp$slide_name)

    result$passed <- TRUE
  }

  if (grepl("Different number of pages", output)) {
    if (verbose) cli::cli_alert_danger("{tmp$slide_name}: {output}")
    result$passed <- FALSE
    result$reason <- "Differing page count"
    result$pages <- stringr::str_extract(output, "\\d+ vs \\d+")
  }

  if (any(grepl("The most different pages are", x = output))) {
    pages_string <- unlist(stringr::str_extract_all(output, "(page \\d+) \\(sgf\\. (\\d+\\.?\\d+)\\)"))

    different_pages <- pages_string |>
      stringr::str_extract(" \\d+ ") |>
      stringr::str_trim() |>
      as.integer()

    pages_signif <- pages_string |>
      stringr::str_extract(" \\d+\\.\\d+") |>
      stringr::str_trim() |>
      as.numeric() |>
      round(1)

    if (verbose) cli::cli_alert_warning(
      "{tmp$slide_name}: Changes detected in pages: {different_pages} (signif.: {pages_signif})"
    )
    result$passed <- FALSE
    result$reason <- "Dissimilar pages"
    result$pages <- paste(sort(different_pages), collapse = ", ")
    result$signif <- pages_signif
  }

  if (create_comparison_pdf & !result$passed & check_system_tool("diff-pdf")) {

    if (!dir.exists(here::here("comparison"))) dir.create(here::here("comparison"))
    out_path <- fs::path_ext_set(here::here("comparison", tmp$slide_name), "pdf")

    # Check if there's already a comparison file, and update it only if
    # either of the input PDF is more recent
    age_check <- TRUE
    if (fs::file_exists(out_path)) {
      slide_age <- fs::file_info(tmp[["pdf"]])[["modification_time"]]
      slide_static_age <- fs::file_info(tmp[["pdf_static"]])[["modification_time"]]
      comparison_age <- fs::file_info(out_path)[["modification_time"]]

      # Unpleasant nested-if thing but oh well.
      if (comparison_age >= max(slide_age, slide_static_age)) {
        if (verbose) cli::cli_inform("Comparison PDF appears up to date already!")
        age_check <- FALSE
      }

      if (fs::file_size(out_path) == 0) {
        if (verbose) cli::cli_inform("Comparison PDF is empty, recreating...")
        age_check <- TRUE
      }
    }

    if (age_check | view | overwrite) {
      if (verbose & !view) cli::cli_inform("Creating diff PDF at {.file {fs::path_rel(out_path)}}")
      args <- c(
        # Red highlight on the left side to highlight small differences
        "--mark-differences",
        # Total number of pixels allowed to be different per page before specifying the page is different
        # Not sure what a useful value here would be
        paste0("--per-page-pixel-tolerance=", pixel_tol),
        paste0("--dpi=", dpi_out),
        # Maybe skip identical pages? Not sure if that makes it actually easier
        "--skip-identical",
        # Input and reference PDF paths
        tmp[["pdf"]], tmp[["pdf_static"]]
      )

      # If we want to view interactively, --output-diff must not be passed apparently.
      if (view) {
        args <- c("--view", args)
      } else {
        args <- c(paste0("--output-diff=", out_path), args)
      }

      p <- processx::process$new(
        command = "diff-pdf", args = args, stdout = "|", stderr = "|",
        echo_cmd = verbose
      )

      p$get_exit_status()
      out <- p$read_all_output_lines()
      err <- p$read_all_error_lines()

      # Haven't found good way to check if this worked though
      # Got exit status == 1 even though resulting PDF looked fine
      # Sometimes output PDF is 0B for some reason, re-running fixes it. Don't know what happens there.
      if (!view) {
        p$wait()

        if (!fs::file_exists(out_path)) {
          cli::cli_alert_warning("{.file {fs::path_rel(out_path)}} was not created!")
        } else if (fs::file_size(out_path) == 0) {
          cli::cli_alert_warning("{.file {fs::path_rel(out_path)}} is empty!")
        }
      }
    }
  }

  invisible(result)
}

#' Compile and compare all the slides
#'
#' @param lectures_tbl Must contain `tex` column. Defaults to `collect_lectures()`.
#' @param pre_clean `[FALSE]`: Passed to `[compile_slide()]`.
#' @param create_comparison_pdf,thresh_psnr,dpi_check,dpi_out,pixel_tol,overwrite Passed to `[compare_slide()]`.
#' @return Invisibly: An expanded `lectures_tbl` with check results
#' Also saves output at `slide_check_cache.rds`.
check_all_slides_parallel <- function(
    lectures_tbl = collect_lectures(), pre_clean = FALSE,
    create_comparison_pdf = TRUE,
    thresh_psnr = 40, dpi_check = 50, dpi_out = 100,
    pixel_tol = 20, overwrite = FALSE
  ) {

  future::plan("multisession")

  tictoc::tic()
  check_out <- future.apply::future_lapply(lectures_tbl$tex, \(tex) {

    result <- data.frame(
      tex = tex,
      compile_check = NA,
      compare_check = NA,
      compare_check_note = "",
      compare_check_raw = ""
    )

    compile_status <- compile_slide(tex, pre_clean = pre_clean, verbose = FALSE)

    result$compile_check <- compile_status$passed

    if (compile_status$passed) {
      compare_status <- compare_slide(
        tex, verbose = FALSE, create_comparison_pdf = create_comparison_pdf,
        thresh_psnr = thresh_psnr, dpi_check = dpi_check, dpi_out = dpi_out,
        pixel_tol = pixel_tol, overwrite = overwrite
      )

      result$compare_check <- compare_status$passed
      result$compare_check_raw <- compare_status$output

      if (!compare_status$passed) {
        if (compare_status$pages == "") {
          result$compare_check_note <- compare_status$reason
        } else {
          result$compare_check_note <- sprintf("%s: %s", compare_status$reason, compare_status$pages)
        }
      }
    }
    result
  }, future.seed = NULL) # Silence future warning about RNG stuff not relevant in this context

  check_out <- do.call(rbind, check_out)

  # Merge with main slide table
  check_table_result <- merge(lectures_tbl, check_out, by = "tex")

  took <- tictoc::toc()

  cli::cli_alert_info("{took$callback_msg}. Saving results to \"slide_check_cache.rds\".")
  saveRDS(check_table_result, file = "slide_check_cache.rds")
  invisible(check_table_result)
}

# Misc utilities --------------------------------------------------------------------------------------------------

find_slide_tex <- function(lectures_tbl = collect_lectures(), slide_file) {
  # Allow both "slides-cart-predictions.tex" and lazy "slides-cart-predictions"
  # and "slides-cart-predictions.pdf" because why not.
  if (identical(fs::path_ext(slide_file), "")) slide_file <- fs::path_ext_set(slide_file, "tex")
  if (identical(fs::path_ext(slide_file), "pdf")) slide_file <- fs::path_ext_set(slide_file, "tex")

  if (slide_file %in% lectures_tbl$tex) {
    tmp <- lectures_tbl[lectures_tbl$tex == slide_file, ]
  } else if (slide_file %in% fs::path_rel(lectures_tbl$tex)) {
    tmp <- lectures_tbl[fs::path_rel(lectures_tbl$tex) == slide_file, ]
  }

  slide_file <- fs::path_file(slide_file)
  tmp <- lectures_tbl[fs::path_file(lectures_tbl$tex) == slide_file, ]

  if (nrow(tmp) == 0) {
    stop(sprintf("No matching file for %s", slide_file))
  }
  if (nrow(tmp) > 1) {
    stop(sprintf("Multiple files matching name %s, got %i matches", slide_file, nrow(tmp)))
  }

  tmp
}

#' Compile a .tex file using TinyTex's latexmk emulation
#'
#' Automatically installs missing LaTeX packages. Neat.
#' This is just a thin wrapper run the command with
#' a changed working directory, as relative paths used in `preamble.tex` etc. require.
#'
#' @param tex `character(1)` Full path to a `.tex` file to render.
#' @param ... Arguments passed to [`tinyex::latexmk()].
#'
#' @return `TRUE` if an output PDF file exists, `FALSE` otherwise.
# @export
#'
#' @examples
#' compile_slide_tinytex("lecture_advml/slides/gaussian-processes/slides-gp-basic-3.tex")
compile_slide_tinytex <- function(tex, ...) {

  tex <- find_slide_tex(slide_file = tex)[["tex"]]

  oldwd <- setwd(dir = fs::path_dir(tex))
  on.exit(setwd(olwd))

  res <- try(tinytex::latexmk(file = tex, emulation = TRUE, install_packages = TRUE))

  file.exists(res)
}

check_system_tool <- function(x, strict = FALSE) {
  checkmate::assert_character(x, len = 1)
  which <- Sys.which(x)

  if (which == "") {
    msg <- "Could not find {x} in $PATH"
    if (strict) cli::cli_abort(msg)
    cli::cli_alert_warning(msg)
    return(FALSE)
  }

  TRUE
}

lecture_status_local <- function(lectures = unique(collect_lectures()[["lecture"]])) {
  do.call(rbind, lapply(lectures, \(lecture) {

    if (fs::dir_exists(fs::path(lecture, ".git"))) {
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

this_repo_status <- function() {
  lecture_status_local(".")[, -1]
}


# Required in my case to find diff-pdf-visually and its dependencies if installed via homebrew on macOS
if (Sys.info()[["sysname"]] == "Darwin") {
  if (file.exists("/opt/homebrew/bin/brew")) {
    brew_dir <- "/opt/homebrew/bin/"
  }
  if (check_system_tool("brew")) {
    brew_dir <- fs::path_dir(Sys.which("brew"))
    Sys.setenv(PATH = paste(Sys.getenv("PATH"), brew_dir, sep = ":"))
  }
}
