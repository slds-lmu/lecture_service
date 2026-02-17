# Get the path to the slide check cache file

Returns the path where
[`check_slides_many()`](https://slds-lmu.github.io/lecture_service/reference/check_slides_many.md)
stores its results. The cache lives in the user's data directory
(`rappdirs::user_data_dir("lese")`).

## Usage

``` r
slide_cache_path()
```

## Value

A single character string (the file path). The file or its parent
directory may not exist yet.

## Examples

``` r
slide_cache_path()
#> ~/.local/share/lese/slide_check_cache.rds
```
