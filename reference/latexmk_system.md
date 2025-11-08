# Run latexmk

`latexmk` needs to be in `$PATH` for this to work.

## Usage

``` r
latexmk_system(
  slide_file,
  verbose = TRUE,
  log_stdout = "",
  log_stderr = "",
  supervise = TRUE
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

  `[TRUE]`: Print output from `docker`/`latexmk` to console.

- log_stdout, log_stderr:

  `[""]`: Path to write stdout/stderr log to. Discarded if `NULL` or
  inherited from main R process if `""`. `stderr` can be redirected to
  `stdout` with `"2>&1"`.

- supervise:

  `[TRUE]`: Passed to
  [`processx::process()`](http://processx.r-lib.org/reference/process.md)'s
  `$new()`.

## Value

A
[`processx::process()`](http://processx.r-lib.org/reference/process.md)
object.

## Note

This utility is usually invoked by
[`compile_slide()`](https://slds-lmu.github.io/lecture_service/reference/compile_slide.md).

## Examples

``` r
if (FALSE) { # \dontrun{
latexmk_system("slides-advriskmin-bias-variance-decomposition.tex")
} # }
```
