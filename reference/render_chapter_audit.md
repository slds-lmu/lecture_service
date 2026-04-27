# Render a chapter audit report

Renders an HTML report auditing the script-figure-slide dependency chain
for a lecture. Uses the `chapter_audit.Rmd` template bundled with the
package.

## Usage

``` r
render_chapter_audit(
  lecture_dir = ".",
  chapters = NULL,
  pattern = "[.]R$",
  timeout = 300,
  run = FALSE,
  method = "auto",
  output_dir = lecture_dir,
  ...
)
```

## Arguments

- lecture_dir:

  Character. Path to the lecture directory. Defaults to the current
  working directory.

- chapters:

  Character vector of chapter names to audit, or `NULL` (default) to
  audit all chapters.

- pattern:

  Regex pattern to filter script filenames. Default `"[.]R$"` matches
  all `.R` files.

- timeout:

  Numeric. Per-script timeout in seconds. Default 300.

- run:

  Logical. If `TRUE`, execute scripts and track produced figures.
  Default `FALSE`.

- method:

  Character. Figure detection method passed to
  [`audit_chapter()`](https://slds-lmu.github.io/lecture_service/reference/audit_chapter.md).
  One of `"auto"`, `"regex"`, or `"fls"`. Default `"auto"`.

- output_dir:

  Character. Directory for the output HTML file. Defaults to
  `lecture_dir`.

- ...:

  Additional arguments passed to
  [`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).

## Value

The path to the rendered HTML file (invisibly), as returned by
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).

## Examples

``` r
if (FALSE) { # \dontrun{
# From within a lecture directory (e.g. lecture_i2ml/)
render_chapter_audit()

# From lecture_service root
render_chapter_audit(lecture_dir = "lecture_i2ml")

# Audit specific chapters with script execution
render_chapter_audit(
  chapters = c("cart", "evaluation"),
  run = TRUE
)
} # }
```
