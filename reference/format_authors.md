# Condense list of authors from biblatex entry

- NAs are replaced by —

- Two authors are separated by &

- More than two authors are replaced by First Author et al.

## Usage

``` r
format_authors(author_list)
```

## Arguments

- author_list:

  [`list()`](https://rdrr.io/r/base/list.html) of character vectors with
  one author per element.

## Value

`character` vector of same length as list elements
