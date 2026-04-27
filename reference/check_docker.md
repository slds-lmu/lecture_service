# Check if docker can be used

- `docker` needs to be in `$PATH`

- `docker` daemon (or compatible runtime) needs to be running

## Usage

``` r
check_docker(strictness = c("warning", "error", "none"))
```

## Arguments

- strictness:

  `["warning"]` Wether to emit a warning, `"error"`, or nothing
  (`"none"`) if docker can not be used.

## Value

Invisibly: `TRUE` if the docker seems to be running, `FALSE` otherwise,
and an error if `strict` and the tool is not found.

## Examples

``` r
check_docker(strictness = "none")
```
