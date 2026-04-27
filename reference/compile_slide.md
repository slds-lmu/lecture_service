# Compile a single .tex file

Compile a single .tex file

## Usage

``` r
compile_slide(
  slide_file,
  pre_clean = TRUE,
  post_clean = FALSE,
  margin = TRUE,
  check_status = TRUE,
  verbose = TRUE,
  log = FALSE,
  method = c("system", "docker", "tinytex"),
  ...
)
```

## Arguments

- slide_file:

  `[character(1)]` Name of a (single) slide, with or without `.tex`
  extension. See examples of
  [`find_slide_tex()`](https://slds-lmu.github.io/lecture_service/reference/find_slide_tex.md).
  Can also be a direct file path to enable use of this function outside
  rigid folder hierarchy.

- pre_clean, post_clean:

  `[TRUE, FALSE]`: Run
  [`clean_slide()`](https://slds-lmu.github.io/lecture_service/reference/clean_slide.md)
  before / after compilation, ensuring a clean slate.

- margin:

  `[TRUE]` By default renders slides with margin. Otherwise a 4:3 slide
  is rendered.

- check_status:

  `[TRUE]`: Wait for `latexmk` to finish and return the exit status. Not
  supported for `method = "tinytex"`.

- verbose:

  `[TRUE]`: Print additional output to the console.

- log:

  `[FALSE]`: Write stdout and stderr logs to `./logs/`. Not supported
  for `method = "tinytex"`.

- method:

  `["system"]`: `"system"` uses
  [`latexmk_system()`](https://slds-lmu.github.io/lecture_service/reference/latexmk_system.md),
  "docker" uses
  [`latexmk_docker()`](https://slds-lmu.github.io/lecture_service/reference/latexmk_docker.md),
  and `"tinytex"` uses
  [`latexmk_tinytex()`](https://slds-lmu.github.io/lecture_service/reference/latexmk_tinytex.md).

- ...:

  For future extension. Currently passed to function invoked via
  `method`.

## Value

Invisibly: A list with entries

- passed: TRUE indicates a successful compilation, FALSE a failure.

- log: Absolute path to the log file in case of a non-zero exit status.

## See also

[`latexmk_docker()`](https://slds-lmu.github.io/lecture_service/reference/latexmk_docker.md)
and
[`latexmk_system()`](https://slds-lmu.github.io/lecture_service/reference/latexmk_system.md)
for internal compilation methods.

## Examples

``` r
if (FALSE) { # \dontrun{
# The "normal" way: A .tex file name
compile_slide("slides-cart-computationalaspects.tex")

# Also acceptable: A full path (absolute or relative), convenient for scripts
compile_slide("lecture_advml/slides/gaussian-processes/slides-gp-bayes-lm.tex")

# Lazy way: No extension, just a name
compile_slide("slides-cart-predictions")
} # }
```
