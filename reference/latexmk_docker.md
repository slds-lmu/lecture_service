# Run dockerized latexmk

This uses the docker image from
<https://gitlab.com/islandoftex/images/texlive>. The default uses tag
`TL2025-historic` for TeXLive 2025.

## Usage

``` r
latexmk_docker(
  slide_file,
  verbose = TRUE,
  tag = "TL2025-historic",
  log_stdout = "",
  log_stderr = "",
  supervise = TRUE
)
```

## Arguments

- slide_file:

  `[character(1)]` Name of a (single) slide, with or without `.tex`
  extension. See examples of
  [`find_slide_tex()`](https://slds-lmu.github.io/lecture_service/reference/find_slide_tex.md).
  Can also be a direct file path to enable use of this function outside
  rigid folder hierarchy.

- verbose:

  `[TRUE]`: Print output from `docker`/`latexmk` to console.

- tag:

  `["TL2025-historic"]`: Tag of `texlive` docker image to use.

- log_stdout, log_stderr:

  `[""]`: Path to write stdout/stderr log to. Discarded if `NULL` or
  inherited from main R process if `""`. `stderr` can be redirected to
  `stdout` with `"2>&1"`.

- supervise:

  `[TRUE]`: Passed to
  [`processx::process()`](http://processx.r-lib.org/reference/process.md)'s
  `$new()`.

## Value

A
[`processx::process()`](http://processx.r-lib.org/reference/process.md)
object.

## Details

You will need to install docker or podman or some other compatible
runtime on your system beforehand.

The docker command run by this is equivalent to something like

    cd path/to/lecture_i2ml/slides/ml-basics

    CWD=$(basename ${PWD})
    LECTURE=$(dirname $(dirname ${PWD}))

    docker run -i --rm --user $(id -u) --name latex \
      -v "${LECTURE}":/usr/src/app:z \
      -w "/usr/src/app/slides/${CWD}" \
      registry.gitlab.com/islandoftex/images/texlive:TL2025-historic \
      latexmk -pdf -halt-on-error slides-basics-data.tex

## Note

This utility is usually invoked by
[`compile_slide()`](https://slds-lmu.github.io/lecture_service/reference/compile_slide.md).

## Examples

``` r
if (FALSE) { # \dontrun{
latexmk_docker("slides-cart-treegrowing.tex")
} # }
```
