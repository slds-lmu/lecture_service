# Remove orphaned figures from a chapter

Runs
[`audit_chapter()`](https://slds-lmu.github.io/lecture_service/reference/audit_chapter.md)
to identify orphaned figures in `figure/` and `figure_man/`, then
deletes them. Figures in `attic/` subdirectories are never deleted.

## Usage

``` r
clean_orphaned_figures(
  chapter,
  lecture_dir = here::here(),
  lecture = basename(lecture_dir),
  method = c("auto", "regex", "fls"),
  dry_run = TRUE
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

- method:

  Character. How to detect which figures slides reference:

  - `"auto"` (default): Use `.fls` files if they exist for all slides,
    otherwise fall back to regex. Best for use after `make slides`.

  - `"regex"`: Parse `.tex` source with regex. Fast but can miss
    dynamically constructed paths (e.g. `\\foreach` loops).

  - `"fls"`: Parse `.fls` recorder files from `latexmk`. More robust but
    requires prior compilation (`make slides`). Errors if `.fls` files
    are missing.

- dry_run:

  Logical. If `TRUE` (default), only list files that would be deleted
  without actually removing them.

## Value

Invisibly: character vector of deleted (or would-be-deleted) file paths.

## Details

Since figures are typically git-tracked, deletions are easily reversible
via `git checkout`.
