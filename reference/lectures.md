# Get included lectures

Uses central file `./include_lectures`, ignoring commented out lines.
Can be overridden with environment variable `$include_lectures`. If
neither the environment variable nor the file exists, it defaults to
listing all lectures.

## Usage

``` r
lectures()
```

## Value

A character vector, e.g. `c("lecture_i2ml", "lecture_advml")`, depending
on `./include_lectures`

## Examples

``` r
lectures()
#> [1] "lecture_i2ml"         "lecture_sl"           "lecture_iml"         
#> [4] "lecture_optimization" "lecture_algods"       "lecture_debug"       
```
