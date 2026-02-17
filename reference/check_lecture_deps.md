# Check and install missing dependencies for all chapter scripts

Scans all R scripts in `slides/*/rsrc/` across all chapters, extracts
package dependencies, and reports which are missing. Optionally installs
them via [`pak::pak()`](https://pak.r-lib.org/reference/pak.html).

## Usage

``` r
check_lecture_deps(lecture_dir = here::here(), install = FALSE)
```

## Arguments

- lecture_dir:

  Character. Path to the lecture directory. Defaults to
  [`here::here()`](https://here.r-lib.org/reference/here.html).

- install:

  Logical. If `TRUE`, install missing packages without prompting.
  Default `FALSE`.

## Value

Invisibly: A list with `all` (all detected packages) and `missing`
(packages not currently installed).

## Examples

``` r
if (FALSE) { # fs::dir_exists(here::here("lecture_i2ml"))
check_lecture_deps(lecture_dir = here::here("lecture_i2ml"))
}
```
