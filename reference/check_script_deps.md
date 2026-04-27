# Check and install missing dependencies for chapter scripts

Extracts package dependencies from all R scripts in a chapter's `rsrc/`
directory, checks which are not installed, and offers to install them
via [`pak::pak()`](https://pak.r-lib.org/reference/pak.html).

## Usage

``` r
check_script_deps(
  chapter,
  lecture_dir = here::here(),
  lecture = basename(lecture_dir),
  pattern = "[.]R$",
  install = interactive()
)
```

## Arguments

- chapter:

  Character. Chapter directory name, e.g. `"evaluation"`.

- lecture_dir:

  Character. Path to the lecture directory. Defaults to
  [`here::here()`](https://here.r-lib.org/reference/here.html).

- lecture:

  Character. Lecture name for display purposes. Defaults to
  `basename(lecture_dir)`.

- pattern:

  Regex pattern to filter scripts. Default `"[.]R$"`.

- install:

  Logical. If `TRUE` (default in interactive sessions), prompt to
  install missing packages. If `FALSE`, only report.

## Value

Invisibly: A list with `all` (all detected packages) and `missing`
(packages not currently installed).

## Examples

``` r
if (FALSE) { # fs::dir_exists(here::here("lecture_i2ml"))
check_script_deps("evaluation",
  lecture_dir = here::here("lecture_i2ml"),
  install = FALSE
)
}
```
