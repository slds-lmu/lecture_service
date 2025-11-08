# Compile and compare many slides

Wrapper for
[`check_slides_single()`](https://slds-lmu.github.io/lecture_service/reference/check_slides_single.md).

## Usage

``` r
check_slides_many(
  lectures_tbl = collect_lectures(),
  pre_clean = FALSE,
  compare_slides = FALSE,
  create_comparison_pdf = FALSE,
  parallel = TRUE,
  thresh_psnr = 40,
  dpi_check = 50,
  dpi_out = 100,
  pixel_tol = 20,
  overwrite = FALSE
)
```

## Arguments

- lectures_tbl:

  Must contain `tex` column. Defaults to
  [`collect_lectures()`](https://slds-lmu.github.io/lecture_service/reference/collect_lectures.md).

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

- parallel:

  `[TRUE]` Whether to parallelize. Uses
  [future.apply::future_lapply](https://future.apply.futureverse.org/reference/future_lapply.html)
  with `future::plan("multisession")`.

## Value

Invisibly: An expanded `lectures_tbl` with check results Also saves
output at `slide_check_cache.rds`.
