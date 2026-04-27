# Compare slide PDF against reference PDF

A compiled .tex file such as
`slides/gaussian-processes/slides-gp-bayes-lm.pdf` will be compared with
an assumed to be accepted / known good version at
`slides-pdf/slides-gp-bayes-lm.pdf` if it exists.

## Usage

``` r
compare_slide(
  slide_file,
  verbose = TRUE,
  create_comparison_pdf = FALSE,
  thresh_psnr = 20,
  dpi_check = 50,
  eps_signif = 0.5,
  dpi_out = 100,
  pixel_tol = 50,
  view = FALSE,
  overwrite = FALSE
)
```

## Arguments

- slide_file:

  `[character(1)]` Name of a (single) slide, with or without `.tex`
  extension. See examples of
  [`find_slide_tex()`](https://slds-lmu.github.io/lecture_service/reference/find_slide_tex.md).
  Can also be a direct file path to enable use of this function outside
  rigid folder hierarchy.

- verbose:

  `[TRUE]`: Print additional output to the console.

- create_comparison_pdf:

  `[FALSE]`: Use `diff-pdf` to create a comparison PDF at
  `./comparison/<slide-name>.pdf`. The PDF contains only the slide pages
  with detected differences, highlighted in red/blue.

- thresh_psnr:

  `[20]`: PSNR threshold for difference detection in
  `diff-pdf-visually`. Higher is more sensitive.

- dpi_check:

  `[50]` Resolution for rasterised files used by both
  `diff-pdf-visually`. Lower is more coarse.

- eps_signif:

  `[0.5]` Significance threshold for difference detection in
  `diff-pdf-visually` to force fewer false-positives.

- dpi_out:

  `[100]` Resolution for output PDF produced by `diff-pdf`. Lower values
  will lead to very pixelated diff PDFs.

- pixel_tol:

  `[50]` Per-page pixel tolerance for comparison used by `diff-pdf`.

- view:

  `[FALSE]` For interactive use: Opens window showing comparison diff.

- overwrite:

  `[FALSE]` Re-creates output diff PDF even if it already exists and
  appears up to date.

## Value

Invisibly: A list of results:

- `passed`: TRUE indicates a successful comparison, FALSE a failure.

- `reason`: Shorthand reason for a failing comparison.

- `pages`: Vector of pages with differences.

- `output`: Full output produced by diff-pdf-visually.

Also prints a summary, e.g.:

"! slides-cart-computationalaspects: Changes detected in pages: 11 and
12 (signif.: 0 and 0)"

## Details

First uses `diff-pdf-visually` to check slides for differences based on
the PSNR of rasterised versions of the slides (adjustable with
`thresh_psnr`), and then uses `diff-pdf` to create a PDF highlighting
the differences if `create_comparison_pdf` is `TRUE`.

This only re-runs `diff-pdf` to create a comparison PDF file if the
output file under `./comparison/<slide-name>.pdf` is more recent than
both of the input PDF files. That way you can safely re-run this
function repeatedly without worrying about computational overhead.

## Note

Uses `diff-pdf-visually` and `diff-pdf` under the hood, you may need to
adjust your \$PATH.

## Examples

``` r
if (FALSE) { # \dontrun{
# The "normal" way: A .tex file name
compare_slide("slides-cart-computationalaspects.tex")

# Also acceptable: A full path (absolute or relative), convenient for scripts
compare_slide("lecture_advml/slides/gaussian-processes/slides-gp-bayes-lm.tex")

# Lazy way: No extension, just a name
compare_slide("slides-cart-predictions")

# Whoopsie supplied name of PDF instead no biggie I got u
compare_slide("slides-forests-proximities.pdf")

compare_slide("slides-boosting-cwb-basics")
} # }
```
