# Install the lecheck cli tool

`path` should be in `$PATH` to make the tool usable in shell sessions.

## Usage

``` r
install_lecheck(path = "~/.local/bin", overwrite = TRUE)
```

## Arguments

- path:

  `["~/.local/bin"]` Path to symlink the tool to. Must exist and be
  writable.

- overwrite:

  `[TRUE]` Overwrite any existing symlink.

## Value

`FALSE` if a symlink already exists and is not overwritten. Otherwise:
The path to the symlink is returned.

## Examples

``` r
if (FALSE) {
install_lecheck()

# Would only work if the R session is started under a user that can write to /usr/local/bin
install_lecheck("/usr/local/bin")
}
```
