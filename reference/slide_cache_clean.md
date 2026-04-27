# Delete the slide check cache

Removes the cache file created by
[`check_slides_many()`](https://slds-lmu.github.io/lecture_service/reference/check_slides_many.md),
if it exists.

## Usage

``` r
slide_cache_clean()
```

## Value

`TRUE` (invisibly) if the file was deleted, `FALSE` if it did not exist.

## Examples

``` r
if (FALSE) { # \dontrun{
slide_cache_clean()
} # }
```
