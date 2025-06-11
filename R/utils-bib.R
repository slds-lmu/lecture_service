format_authors <- function(author_list) {
  vapply(
    author_list,
    \(x) {
      # cli::cli_alert_info("{x}:")
      x <- na.omit(x)

      if (length(x) == 0) {
        ret <- "---"
      }
      if (length(x) == 1) {
        ret <- x
      }
      if (length(x) == 2) {
        ret <- paste(x, collapse = " & ")
      }
      if (length(x) > 2) {
        ret <- paste(x[[1]], "et al.")
      }

      ret
    },
    FUN.VALUE = character(1)
  )
}

clean_tex_markup <- function(x) {
  # x <- bib2df::bib2df(bib_files[[3]])$NOTE

  x |>
    stringr::str_remove_all("\\\\") |>
    stringr::str_replace_all("emph\\{(.*)\\}", "*\\1*") |>
    stringr::str_replace_all("\\{.*\\}", "\\1")
}

#' Convert bib file to formatted list for Markdown output
#'
#' @param bib `[character(1)]` Path to bibtex `.bib` file.
#' @param arrange_by `[character()]` ALl lowercase biblatex field names to sort by. Passed to `dplyr::arrange()`.
#' @return `character` vector with one element per entry in `bib`.
#'
#' @export
#' @importFrom bib2df bib2df
#' @importFrom dplyr arrange rename_with mutate coalesce pull
#'
bib_to_list <- function(bib, arrange_by = "category") {
  checkmate::assert_file_exists(bib)

  bib2df::bib2df(bib) |>
    rename_with(tolower) |>
    arrange(arrange_by) |>
    mutate(
      title = clean_text_markup(title),
      note = clean_tex_markup(note),
      year = coalesce(year, date),
      formatted = glue::glue(
        "- {format_authors(author)} ({year}): [*{title}*]({url}).\n"
      ),
      # Append note if field is provided
      formatted = ifelse(
        !is.na(note),
        glue::glue("{formatted} **Note**: {note}\n"),
        formatted
      )
    ) |>
    pull(formatted)
}
