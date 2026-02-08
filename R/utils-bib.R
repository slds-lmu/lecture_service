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
      title = clean_tex_markup(title),
      note = clean_tex_markup(note),
      # year = coalesce(.data[["year"]], .data[["date"]]),
      formatted = glue::glue(
        "- {format_authors(author)} ({year}): [*{title}*]({url}).\n"
      ),
      # Append note if field is provided
      formatted = ifelse(
        !is.na(annotation),
        glue::glue("{formatted} **Note**: {annotation}\n"),
        formatted
      )
    ) |>
    pull(formatted)
}

#' Condense list of authors from biblatex entry
#'
#' - NAs are replaced by ---
#' - Two authors are separated by &
#' - More than two authors are replaced by First Author et al.
#' @keywords internal
#' @param author_list `list()` of character vectors with one author per element.
#' @return `character` vector of same length as list elements
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

#' Clean up tex markup from biblatex entries
#'
#' - Removes \\ used for escaping
#' - Substitutes \emph{foobar} with *foobar*
#' - Replaces {foo} with foo
#' @keywords internal
clean_tex_markup <- function(x) {
  x |>
    stringr::str_remove_all("\\\\") |>
    stringr::str_replace_all("emph\\{(.*)\\}", "*\\1*") |>
    stringr::str_remove_all("[\\{\\}]")
  # stringr::str_replace_all("\\{[,]\\}", "\\1")
}
