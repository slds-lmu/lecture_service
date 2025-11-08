# Assemble table of lecture slides

Assemble table of lecture slides

## Usage

``` r
collect_lectures(
  lectures_path = here::here(),
  filter_lectures = lectures(),
  exclude_slide_subdirs = c("attic", "rsrc", "all", "figure_man", "figures_tikz",
    "figure", "tex", "backup"),
  exclude_slide_names = c("chapter-order", "chapter-order-slides-all",
    "chapter-order-nutshell", "nospeakermargin")
)
```

## Arguments

- lectures_path:

  Path containing lecture\_\* directories. Defaulting to
  [`here::here()`](https://here.r-lib.org/reference/here.html).

- filter_lectures:

  [`character()`](https://rdrr.io/r/base/character.html): Vector of
  lecture repo names to filter table by, e.g. `"lecture_i2ml"`. Defaults
  to
  [`lectures()`](https://slds-lmu.github.io/lecture_service/reference/lectures.md)
  to respect `include_lectures`.

- exclude_slide_subdirs:

  Exclude slides/ subfolders, e.g. `c("attic", "rsrc", "all")`.

- exclude_slide_names:

  Exclude slides matching these names exactly, e.g. `"chapter-order"`
  (default).

## Value

A ``` data.frame`` with one row per slide  ```.tex\` file.

## Examples

``` r
if (FALSE) { # \dontrun{
collect_lectures()
} # }
```
