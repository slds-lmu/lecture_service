# Render the slide status HTML report

Renders the slide status overview site from the `slide_status.Rmd`
template bundled with the package. Requires the slide check cache
produced by
[`check_slides_many()`](https://slds-lmu.github.io/lecture_service/reference/check_slides_many.md)
(see
[`slide_cache_path()`](https://slds-lmu.github.io/lecture_service/reference/slide_cache_path.md)).

## Usage

``` r
render_slide_status(output_dir = ".", quiet = TRUE, ...)
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

The path to the rendered HTML file (invisibly), as returned by
[`rmarkdown::render()`](https://pkgs.rstudio.com/rmarkdown/reference/render.html).

## Examples

``` r
if (FALSE) { # \dontrun{
# After running check_slides_many():
render_slide_status()
} # }
```
