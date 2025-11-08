# Lecture repo status

Show latest changes to locally available lectures.

## Usage

``` r
repo_status(lecture = lectures())
```

## Arguments

- lecture:

  Character vector of lecture repo names, defaults to
  [`lectures()`](https://slds-lmu.github.io/lecture_service/reference/lectures.md).
  E.g. `c("lecture_advml", "lecture_i2ml")`.

## Value

A `data.frame` suitable for display via `kable` in RMarkdown.

## Examples

``` r
if (FALSE) repo_status()
```
