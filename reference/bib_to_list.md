# Convert bib file to formatted list for Markdown output

Convert bib file to formatted list for Markdown output

## Usage

``` r
bib_to_list(bib, arrange_by = "category")
```

## Arguments

- bib:

  `[character(1)]` Path to bibtex `.bib` file.

- arrange_by:

  `[character()]` All lowercase biblatex field names to sort by. Passed
  to
  [`dplyr::arrange()`](https://dplyr.tidyverse.org/reference/arrange.html).

## Value

`character` vector with one element per entry in `bib`.
