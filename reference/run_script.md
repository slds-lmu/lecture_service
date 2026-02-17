# Run an R script in an isolated subprocess

Executes `script_path` in a fresh R session via
[`callr::r()`](https://callr.r-lib.org/reference/r.html), with the
working directory set to the script's parent directory (typically the
`rsrc/` folder).

## Usage

``` r
run_script(script_path, timeout = 300)
```

## Arguments

- script_path:

  Character. Absolute path to the R script.

- timeout:

  Numeric. Timeout in seconds. Default 300 (5 minutes).

## Value

A single-row `data.frame` with columns:

- `script_path`: The input path.

- `success`: Logical, `TRUE` if script completed without error.

- `error_message`: Character, empty string on success, error message on
  failure.

- `elapsed`: Numeric, wall-clock seconds.

## Examples

``` r
if (FALSE) { # \dontrun{
run_script("lecture_i2ml/slides/evaluation/rsrc/fig-eval_mape.R")
} # }
```
