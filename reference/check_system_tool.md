# Simple check for availability of system tools

Can be used to verify if a tool (e.g. `convert`) is in `$PATH` and
findable from within R. Sometimes a tool is in `$PATH` in regular shell
sessions but not within R.

## Usage

``` r
check_system_tool(x, strictness = c("warning", "error", "none"))
```

## Arguments

- x:

  Name of a binary, e.g. `convert` for ImageMagick or `brew` for
  Homebrew on macOS.

- strictness:

  `["warning"]` Wether to emit a warning, `"error"`, or nothing
  (`"none"`) if the tool is not found.

## Value

Invisibly: `TRUE` if the tool is find, `FALSE` otherwise, and an error
if `strict` and the tool is not found.

## Examples

``` r
check_system_tool("diff-pdf", strictness = "none")
#> ✖ Could not find diff-pdf in $PATH
```
