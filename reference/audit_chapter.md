# Audit the script-figure-slide dependency chain for a chapter

Performs a comprehensive audit of a lecture chapter:

1.  Discovers scripts in `rsrc/`, figures in `figure/`, and slide `.tex`
    files

2.  Parses slides to find which figures they reference

3.  Optionally runs all scripts and tracks which figures they produce

4.  Cross-references to identify orphaned figures, orphaned scripts, and
    missing figures

## Usage

``` r
audit_chapter(
  chapter,
  lecture_dir = here::here(),
  lecture = basename(lecture_dir),
  pattern = "[.]R$",
  timeout = 300,
  run = TRUE,
  method = c("auto", "regex", "fls")
)
```

## Arguments

- chapter:

  Character. Chapter directory name, e.g. `"evaluation"`.

- lecture_dir:

  Character. Path to the lecture directory. Defaults to
  [`here::here()`](https://here.r-lib.org/reference/here.html), i.e. the
  project root.

- lecture:

  Character. Lecture name for display purposes. Defaults to
  `basename(lecture_dir)`.

- pattern:

  Regex pattern to filter scripts. Default `"[.]R$"`.

- timeout:

  Numeric. Per-script timeout in seconds. Default 300.

- run:

  Logical. If `TRUE` (default), execute scripts. If `FALSE`, only
  perform static analysis (figure existence + slide references).

- method:

  Character. How to detect which figures slides reference:

  - `"auto"` (default): Use `.fls` files if they exist for all slides,
    otherwise fall back to regex. Best for use after `make slides`.

  - `"regex"`: Parse `.tex` source with regex. Fast but can miss
    dynamically constructed paths (e.g. `\\foreach` loops).

  - `"fls"`: Parse `.fls` recorder files from `latexmk`. More robust but
    requires prior compilation (`make slides`). Errors if `.fls` files
    are missing.

## Value

Invisibly: A list with components:

- `scripts`: data.frame of scripts. Includes `success`, `error_message`,
  `elapsed`, and `figures_produced` columns when `run = TRUE` (`NA`
  otherwise).

- `figures`: data.frame of figure files on disk (from `figure/`)

- `figures_man`: data.frame of manually created figure files (from
  `figure_man/`)

- `slide_refs`: named list mapping slide filenames to their `figure/`
  references

- `slide_refs_man`: named list mapping slide filenames to their
  `figure_man/` references

- `orphaned_figures`: character vector of `figure/` filenames (with
  extension) not used by any slide (excludes `attic/` subdirectory)

- `orphaned_figures_man`: character vector of `figure_man/` filenames
  (with extension) not used by any slide (excludes `attic/`
  subdirectory)

- `attic_figures`: character vector of filenames in `figure/attic/`

- `attic_figures_man`: character vector of filenames in
  `figure_man/attic/`

- `orphaned_scripts`: character vector of script filenames that
  succeeded but produced no figure used by any slide (`NULL` if
  `run = FALSE`)

- `failed_scripts`: character vector of script filenames that errored
  during execution (`NULL` if `run = FALSE`)

- `no_figure_scripts`: character vector of script filenames that
  succeeded but produced no figures (`NULL` if `run = FALSE`)

- `missing_figures`: data.frame with columns `figure` and `slide` for
  `figure/` files referenced by slides but not on disk

- `missing_figures_man`: data.frame with columns `figure` and `slide`
  for `figure_man/` files referenced by slides but not on disk

- `missing_pkgs`: character vector of R packages required by scripts but
  not currently installed

## Examples

``` r
if (FALSE) { # fs::dir_exists(here::here("lecture_i2ml"))
# Static audit only (no script execution)
result <- audit_chapter("evaluation",
  lecture_dir = here::here("lecture_i2ml"),
  run = FALSE
)
result$orphaned_figures
result$missing_figures

if (FALSE) { # \dontrun{
# Full audit with script execution
result <- audit_chapter("evaluation",
  lecture_dir = here::here("lecture_i2ml")
)
} # }
}
```
