# SLDS Lecture Service

<!-- badges: start -->
[![render-rmarkdown](https://github.com/slds-lmu/lecture_service/actions/workflows/render-status-check.yaml/badge.svg)](https://github.com/slds-lmu/lecture_service/actions/workflows/render-status-check.yaml)
<!-- badges: end -->

This project has two goals:

1. Provide common assets needed for all lectures, once, to keep them in sync.
2. Check slides in lecture repositories (do they compile, are the PDFs up to date?).

For 1), all required files should live in `./service/` with the **correct folder structure** such that one can simply copy the files from this directory "on top" of an existing lecture, e.g.:

```sh
rsync -R lecture_service/service/ lecture_i2ml/
```

Afterwards, `git status` can be used to check changes.

The remainder of this document describes the steps needed for goal 2) slide checking.

## Usage

The assumed directory structure once lecture repositories where cloned (or downloaded) looks like this:

```
lecture_service
├── lecture_advml
├── lecture_i2ml
├── lecture_sl
├── [...]
├── helpers.R
├── Makefile
├── scripts
└── [...]
```

You can either manually `git clone` lecture repos or use `scripts/clone_lectures.sh` or `scripts/download_lectures.sh`.
Since the git repositories can be fairly large due to the included PDF files, I recommend to clone with `--depth 1 --single-branch` if done manually, which only fetches the most recent commit and the default branch.

If all required software is installed (see next section), you can run 

```sh
make
```

which produces a site at `_site/index.html`.

`_site/` also contains `lecture_*` folders which *do not* contain the entire lecture repositories, but only the rendered slide PDF files.
These are used for visual comparison of PDFs produced from `<slide>.tex` files and the "known good" `slide-pdf/<slide>.pdf` file.
It also contains a `comparison` folder, which contains PDF diffs produced by [`diff-pdf`](https://github.com/vslavik/diff-pdf).  
These notably only contain the pages that actually contain some (possibly very minor) differences.

For manual use in R you can also use the helper functions in `helpers.R` directly.

Or, if you prefer to work from the terminal, I experimentally wrapped most functionality in a command-line tool, see `./lecheck --help`:

```sh
# List topics in given lecture
./lecheck -l lecture_i2ml

# Compile and then compare all slides in i2ml, using lazy shorthand for i2ml
./lecheck compile -l i2ml
./lecheck compare -l i2ml

# Only the forests topic (auto-detects that this is in i2ml)
./lecheck compile -t forests
```

## Prerequisites

Scripts to install R, LaTeX, and system dependencies are located in `scripts/`.
This should work reproducibly on recent Ubuntu versions as it does on GitHub actions, but system tools will need special handling on other OSes.
I have it running on macOS as well but have no test system to check a reproducible approach, and I have no idea how to make any of this work on Windows, sorry (maybe try WSL?).

```sh
# Install R packages
make install-r

# Install LaTeX packages via TinyTeX
make install-tex

# Attempt to install diff-pdf (from source) and diff-pdf-visually (via pip)
make install-tools-ubuntu
```

### Tools

These are installed via `scripts/install_tools_ubuntu.sh` or `make install-tools-ubuntu`.

- [`diff-pdf-visually`](https://pypi.org/project/diff-pdf-visually/): For a simple parseable check, e.g.

```sh
❯ diff-pdf-visually slides-forests-proximities.pdf ../../slides-pdf/slides-forests-proximities.pdf
  Temporary directory: /var/folders/n1/p1hxy7856nndrd0njv0lxzgw0000gn/T/diffpdfdy0681qc
  Converting each page of the PDFs to an image...
  PDFs have same number of pages. Checking each pair of converted images...
Min sig = 14.1795, significant?=True. The PDFs are different. The most different pages are: page 5 (sgf. 14.1795), page 2 (sgf. 14.6277), page 4 (sgf. 15.1376), page 7 (sgf. 16.1474), page 3 (sgf. 16.6224).
```

This needs to be installed and in your `$PATH`, such that `processx::process()` can run it.  
The output is used to automatically check if it is necessary to run `diff-pdf`.


- [`diff-pdf`](https://vslavik.github.io/diff-pdf/), for an actual visual comparison for your eyeballs:

```sh
diff-pdf --view slides-forests-proximities.pdf ../../slides-pdf/slides-forests-proximities.pdf
```

This is used to produce PDFs of only the differences at `comparison` and for the HTML table.


### LaTeX Dependencies

LaTeX dependencies are installed via `scripts/install_tex_deps.R` or `make install-tex` via TinyTex.

Install [TinyTex](https://yihui.org/tinytex/):

```r
install.packages("tinytex")
tinytex::install_tinytex()
```

To make sure you can compile slides locally:

```r
oldwd <- getwd()
setwd("lecture_i2ml/slides/cart/")

# tinytex emulates latexmk and installs missing latex packages automatically.
tinytex::latexmk("slides-cart-splitcriteria-classification.tex")

setwd(oldwd)
```

