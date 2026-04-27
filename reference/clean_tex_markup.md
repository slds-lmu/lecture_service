# Clean up tex markup from biblatex entries

- Removes \\ used for escaping

- Substitutes `\emph{foobar}` with `*foobar*`

- Replaces `{foo}` with foo

## Usage

``` r
clean_tex_markup(x)
```
