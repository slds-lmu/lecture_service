# Clean output for a single .tex file

Uses `latexmk -C <slide_file>`, also removing the PDF file. Uses
`latexmk -c <slide_file>` to keep the PDF file.

## Usage

``` r
clean_slide(slide_file, keep_pdf = FALSE, verbose = FALSE, check_status = TRUE)
```

## Arguments

- slide_file:

  `[character(1)]` Name of a (single) slide, with or without `.tex`
  extension. See examples of
  [`find_slide_tex()`](https://slds-lmu.github.io/lecture_service/reference/find_slide_tex.md).
  Can also be a direct file path to enable use of this function outside
  rigid folder hierarchy.

- keep_pdf:

  `[FALSE]`: Keep the PDF file.

- verbose:

  `[TRUE]`: Print additional output to the console.

- check_status:

  `[TRUE]`: Wait for `latexmk` to finish and return the exit status. Not
  supported for `method = "tinytex"`.

## Value

Invisibly:

- If `check_status`, `TRUE` if the exit code is 0, `FALSE` otherwise.

- If `check_status` is `FALSE`, `NULL` is returned.

## Examples

``` r
if (FALSE) { # \dontrun{
# Create the PDF
compile_slide("slides-cart-computationalaspects.tex")

# Remove the PDF and other output
clean_slide("slides-cart-computationalaspects.tex")
} # }
```
