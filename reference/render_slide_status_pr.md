# Render the slide status PR markdown table

Renders a simplified markdown version of the slide status for use in
pull request comments. Uses the `slide_status_pr.Rmd` template bundled
with the package. Requires the slide check cache produced by
[`check_slides_many()`](https://slds-lmu.github.io/lecture_service/reference/check_slides_many.md)
(see
[`slide_cache_path()`](https://slds-lmu.github.io/lecture_service/reference/slide_cache_path.md)).

## Usage

``` r
render_slide_status_pr(output_dir = ".", quiet = TRUE, ...)
```

## Arguments

- output_dir:

  Character. Directory for the output HTML and assets. Defaults to the
  current working directory.

- quiet:

  Logical. If `TRUE` (default), suppress rmarkdown progress.

- ...:

  Additional arguments passed to
  [`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).

## Value

The path to the rendered markdown file (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
# After running check_slides_many():
render_slide_status_pr()
} # }
```
