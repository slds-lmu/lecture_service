# Manage the with/without margin dummy file

See `style/lmu-lecture.sty` where depending on the presence of an empty
`.tex` file with a specific name certain layout options are set to
compile slides either in 16:9 with margins or in 4:3 without a margin
for the speaker.

## Usage

``` r
set_margin_token_file(wd, margin = TRUE, token_name = "nospeakermargin.tex")
```

## Arguments

- wd:

  Working directory (relative or absolute) where the file needs to be
  created. This is the directory were the `.tex` file to be compiled is
  located.

- margin:

  `[TRUE]` Whether to enable or disable the margin.

- token_name:

  `"nospeakermargin.tex"` If the name changes or needs to be flexible
  for testing it can be adjusted, but typically the name is set in stone
  via `lmu-lecture.sty`.

## Value

Nothing

## Examples

``` r
wd <- tempdir()

set_margin_token_file(wd = wd, margin = FALSE)
stopifnot("file exists when no margin set" = file.exists(file.path(wd, "nospeakermargin.tex")))

set_margin_token_file(wd = wd, margin = TRUE)
stopifnot("file is removed when margin set" = !file.exists(file.path(wd, "nospeakermargin.tex")))
```
