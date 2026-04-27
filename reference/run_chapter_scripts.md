# Run all scripts in a chapter and track produced figures

Runs each R script in a chapter's `rsrc/` directory sequentially in
isolated subprocesses. For each script, snapshots the `figure/`
directory before and after execution to determine which figure files
were created or modified.

## Usage

``` r
run_chapter_scripts(
  chapter,
  lecture_dir = here::here(),
  lecture = basename(lecture_dir),
  pattern = "[.]R$",
  timeout = 300
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

  Regex pattern to filter script filenames. Default `"[.]R$"`.

- timeout:

  Numeric. Per-script timeout in seconds. Default 300.

## Value

A `data.frame` with columns:

- `script_file`: Script filename.

- `script_path`: Absolute path.

- `success`: Logical.

- `error_message`: Character.

- `elapsed`: Numeric seconds.

- `figures_produced`: List column of character vectors (filenames
  created/modified).

## Details

Scripts are run sequentially because the before/after figure directory
diffing requires that only one script modifies `figure/` at a time.

## Examples

``` r
if (FALSE) { # \dontrun{
run_chapter_scripts("evaluation",
  lecture_dir = here::here("lecture_i2ml")
)

# Only fig*.R scripts
run_chapter_scripts("evaluation",
  lecture_dir = here::here("lecture_i2ml"),
  pattern = "^fig.*[.]R$"
)
} # }
```
