#' Get the path to the slide check cache file
#'
#' Returns the path where [check_slides_many()] stores its results.
#' The cache lives in the user's data directory
#' (`rappdirs::user_data_dir("lese")`).
#'
#' @return A single character string (the file path). The file or its
#'   parent directory may not exist yet.
#'
#' @export
#' @examples
#' slide_cache_path()
slide_cache_path <- function() {
  fs::path(rappdirs::user_data_dir("lese"), "slide_check_cache.rds")
}


#' Delete the slide check cache
#'
#' Removes the cache file created by [check_slides_many()], if it exists.
#'
#' @return `TRUE` (invisibly) if the file was deleted, `FALSE` if it
#'   did not exist.
#'
#' @export
#' @examples
#' \dontrun{
#' slide_cache_clean()
#' }
slide_cache_clean <- function() {
  path <- slide_cache_path()
  if (fs::file_exists(path)) {
    fs::file_delete(path)
    cli::cli_alert_success("Deleted {.path {path}}")
    invisible(TRUE)
  } else {
    cli::cli_alert_info("No cache file found at {.path {path}}")
    invisible(FALSE)
  }
}
