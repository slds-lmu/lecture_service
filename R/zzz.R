.onLoad <- function(libname, pkgname) {
  # Set the cache file path
  if (is.null(getOption("lese.slide_check_cache_file"))) {
    default_cache_file = fs::path(rappdirs::user_cache_dir("lese"), "slide_check_cache.rds")
    options(lese.slide_check_cache_file = default_cache_file)
  }
}

.onUnload <- function(libname, pkgname) {
  options(lese.slide_check_cache_file = NULL)
}
