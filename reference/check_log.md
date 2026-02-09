# Check latexmk logs for common errors

Uses regular expressions to search log files for common errors:

## Usage

``` r
check_log(slide_file, before = 0, after = 1)
```

## Arguments

- slide_file:

  `[character(1)]` Name of a (single) slide, with or without `.tex`
  extension. See examples of
  [`find_slide_tex()`](https://slds-lmu.github.io/lecture_service/reference/find_slide_tex.md).
  Can also be a direct file path to enable use of this function outside
  rigid folder hierarchy.

- before, after:

  `[integer(1)]` Number of log lines to display `before` and `after` the
  line found via regex. Defaults to 0 lines `before`, 1 line `after.`

## Value

A `character` vector with one element per match, with individual lines
separated by `\\n` within each element. If no errors are detected, an
empty `character(0)` is returned.

## Details

- `"^! Undefined control sequence"`: Typo, missing package or preamble
  (including `latex-math`), or command not defined.

- `"not found"`: Implying a missing figure or other included file, maybe
  due to misspecified filename via Overleafs autocompletion
  (`slides/<chapter>/figure/` path instead of `figure/`) or file not
  committed to git.

- `"^! Missing $ inserted"`: Missing `$` delimiter for math

- `"! LaTeX Error:"`: A generic error

- `Runaway argument`: Often caused by missing closing parantheses.

## Examples

``` r
if (FALSE) { # \dontrun{
# Example where compilation failed due to simple typo / syntax error:
check_log("slides-gp-basic-3")
# "976: ! Undefined control sequence.\n976: l.9 \newcommandiscrete\n"
} # }
```
