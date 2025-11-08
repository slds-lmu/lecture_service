# Run TinyTex's latexmk

A thin wrapper around
[`tinytex::latexmk()`](https://rdrr.io/pkg/tinytex/man/latexmk.html).

## Usage

``` r
latexmk_tinytex(slide_file, ...)
```

## Arguments

- slide_file:

  `[character(1)]` Name of a (single) slide, with or without `.tex`
  extension. See examples of
  [`find_slide_tex()`](https://slds-lmu.github.io/lecture_service/reference/find_slide_tex.md).
  Can also be a direct file path to enable use of this function outside
  rigid folder hierarchy.

- ...:

  Arguments passed to
  [`tinytex::latexmk()`](https://rdrr.io/pkg/tinytex/man/latexmk.html),
  excluding `clean`, which is always `FALSE` as this is handled by
  `[compile_slide()]`.

## Value

`TRUE` if the output PDF exists, `FALSE` otherwise.

## Details

TinyTex's
[`tinytex::latexmk()`](https://rdrr.io/pkg/tinytex/man/latexmk.html)
automatically installs missing LaTeX packages, making it very useful.
This is just a thin wrapper run the command with a changed working
directory, as relative paths used in `preamble.tex` etc. require.

## Note

This utility is usually invoked by
[`compile_slide()`](https://slds-lmu.github.io/lecture_service/reference/compile_slide.md).

## Examples

``` r
if (FALSE) { # \dontrun{
latexmk_tinytex("slides-advriskmin-bias-variance-decomposition.tex")
} # }
```
