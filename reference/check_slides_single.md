# Compile and compare a slide chunk

Use
[`check_slides_many()`](https://slds-lmu.github.io/lecture_service/reference/check_slides_many.md)
to check many slides.

## Usage

``` r
check_slides_single(
  slide_file,
  pre_clean = FALSE,
  compare_slides = FALSE,
  create_comparison_pdf = FALSE,
  thresh_psnr = 40,
  dpi_check = 50,
  dpi_out = 100,
  pixel_tol = 20,
  overwrite = FALSE
)
```

## Arguments

- slide_file:

  `[character(1)]` Name of a (single) slide, with or without `.tex`
  extension. See examples of
  [`find_slide_tex()`](https://slds-lmu.github.io/lecture_service/reference/find_slide_tex.md).
  Can also be a direct file path to enable use of this function outside
  rigid folder hierarchy.

- pre_clean:

  `[FALSE]`: Passed to
  [`compile_slide()`](https://slds-lmu.github.io/lecture_service/reference/compile_slide.md).

- compare_slides:

  `[FALSE]` If `TRUE`, run
  [`compare_slide()`](https://slds-lmu.github.io/lecture_service/reference/compare_slide.md)
  on the slide iff the compile check passed.

- create_comparison_pdf, thresh_psnr, dpi_check, dpi_out, pixel_tol,
  overwrite:

  Passed to
  [`compare_slide()`](https://slds-lmu.github.io/lecture_service/reference/compare_slide.md).

## Value

A `data.frame` with columns

- `tex`: Same as `slide_file` argument.

- `compile_check`: `logical` indicating whether
  [`compile_slide()`](https://slds-lmu.github.io/lecture_service/reference/compile_slide.md)
  passed

- `compare_check`: `logical` indicating whether
  [`compare_slide()`](https://slds-lmu.github.io/lecture_service/reference/compare_slide.md)
  passed ( `NA` if `compare_slides = FALSE` or
  [`compile_slide()`](https://slds-lmu.github.io/lecture_service/reference/compile_slide.md)
  did not pass)

- `compare_check_note`: Note from
  [`compare_slide()`](https://slds-lmu.github.io/lecture_service/reference/compare_slide.md)
  indicating number and nature of differences.

- `compare_check_raw`: More verbose form of `compare_check_note`.

- `compile_note`: If there are compilation errors, the error messages
  from
  [`compile_slide()`](https://slds-lmu.github.io/lecture_service/reference/compile_slide.md)
  are included (see also
  [`check_log()`](https://slds-lmu.github.io/lecture_service/reference/check_log.md)).

## Examples

``` r
if (FALSE) { # \dontrun{
check_slides_single(slide_file = "slides-basics-whatisml", pre_clean = TRUE, compare_slides = TRUE)
} # }
```
