# Parse figure references from a LaTeX slide file

Extracts figure paths referenced via `\\includegraphics`, `\\image`,
`\\imageC`, `\\imageL`, `\\imageR`, and `\\imageFixed` commands.

## Usage

``` r
parse_slide_figures(slide_tex_path, prefix = "figure")
```

## Arguments

- slide_tex_path:

  Character. Path to a `.tex` file.

- prefix:

  Character. Directory prefix to filter for, e.g. `"figure"` (default)
  or `"figure_man"`.

## Value

A character vector of figure basenames (without extension), as
referenced by the slide. Duplicates are removed.

## Details

By default, returns references to `figure/` paths (skipping
cross-chapter `../` references, `../../slides-pdf/`, etc.). Set `prefix`
to extract references for other directories, e.g. `"figure_man"`.

Note: This uses regex on `.tex` source and cannot resolve dynamic paths
(e.g. `\\foreach` loops). For more robust detection after compilation,
use
[`audit_chapter()`](https://slds-lmu.github.io/lecture_service/reference/audit_chapter.md)
with `method = "fls"`.

## Examples

``` r
if (FALSE) { # fs::dir_exists(here::here("lecture_i2ml"))
parse_slide_figures("lecture_i2ml/slides/evaluation/slides-evaluation-train.tex")
}
```
