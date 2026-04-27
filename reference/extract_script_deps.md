# Extract package dependencies from R scripts

Parses R scripts for [`library()`](https://rdrr.io/r/base/library.html),
[`require()`](https://rdrr.io/r/base/library.html), and `pkg::fn` calls
to determine which packages are needed. Scans one or more script files.

## Usage

``` r
extract_script_deps(script_paths)
```

## Arguments

- script_paths:

  Character vector of paths to R scripts.

## Value

A character vector of unique package names, sorted alphabetically.

## Examples

``` r
if (FALSE) { # \dontrun{
script_dir <- file.path("lecture_i2ml", "slides", "evaluation", "rsrc")
scripts <- fs::dir_ls(script_dir, glob = "*.R")
extract_script_deps(scripts)
} # }
```
