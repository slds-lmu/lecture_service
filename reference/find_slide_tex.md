# Find a slide set across all lectures

Lectures need to be stored locally in the current directory with regular
names like `lecture_i2ml`. It is strongly assumed that slide names such
as `slides-cart-predictions.tex` are unique across all lectures.

## Usage

``` r
find_slide_tex(slide_file, lectures_tbl = NULL)
```

## Arguments

- slide_file:

  `[character(1)]` Name of a (single) slide, with or without `.tex`
  extension. See examples of `find_slide_tex()`. Can also be a direct
  file path to enable use of this function outside rigid folder
  hierarchy.

- lectures_tbl:

  `[NULL]` Must contain `tex` column. Will use
  [`collect_lectures()`](https://slds-lmu.github.io/lecture_service/reference/collect_lectures.md)
  if not set and `slide_file` is not an existing file path.

## Examples

``` r
if (FALSE) { # fs::dir_exists(here::here("lecture_i2ml"))
# The "normal" way: A .tex file name
str(find_slide_tex(slide_file = "slides-cart-computationalaspects.tex"))

# Also acceptable: A full path (absolute or relative), convenient for scripts
str(find_slide_tex(slide_file = "lecture_i2ml/slides/cart/slides-cart-predictions.tex"))

# Lazy way: No extension, just a name
str(find_slide_tex(slide_file = "slides-cart-predictions"))

# Can also get the .tex file for a .pdf
str(find_slide_tex(slide_file = "slides-cart-predictions.pdf"))
}
```
