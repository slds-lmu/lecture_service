SLDS Lecture Service
================

- [Overview](#overview)
  - [Quick Start](#quick-start)
- [Slide Compilation & Checking](#slide-compilation--checking)
- [Counting Files](#counting-files)
- [Prerequisites](#prerequisites)
  - [LaTeX Dependencies (Required)](#latex-dependencies-required)
  - [Tools for Slide-Checking
    (Optional)](#tools-for-slide-checking-optional)

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

<!-- badges: end -->

This project has two goals:

1.  Provide common assets needed for all lectures, once, to keep them in
    sync.
2.  Check slides in lecture repositories (do they compile, are the PDFs
    up to date?).

(It also happens to be an R package `lese` you can install with many
convenience functions)

For 1), all required files should live in `./service/` with the
**correct folder structure** such that one can simply copy the files
from this directory “on top” of an existing lecture, e.g.:

``` sh
rsync -r lecture_service/service/ lecture_i2ml/
```

This is wrapped with the script in `service/scripts/update-service.sh`,
which is also synced into each lecture’s top-level `/scripts/` folder.

Afterwards, `git status` can be used to check changes. Note that as of
2024-04-03 the state of the `service` folder is almost ready for action.

The remainder of this document describes the steps needed for goal 2)
[slide checking](#slide-checking).

## Overview

The assumed directory structure once lecture repositories where cloned
(or downloaded) looks like this:

    lecture_service
    ├── lecture_advml
    ├── lecture_i2ml
    ├── lecture_sl
    ├── [...]
    ├── helpers.R
    ├── Makefile
    ├── scripts
    └── [...]

You can either manually `git clone` lecture repos or use
`scripts/clone_lectures.sh` or `download_lectures.sh` respectively. The
`Makefile` has targets `clone` and `download` for these purposes. Since
the git repositories can be fairly large due to the included PDF files,
I recommend to clone with `--depth 1 --single-branch` if done manually,
which only fetches the most recent commit and the default branch.

Note that the text file `include_lectures` is used to globally keep
track of the relevant lecture repos, so if you only intend to work on
`lecture_advml` you could set it to only contain `lecture_advml` and
subsequent `make` commands and other functions will be limited on scope
to this lecture. By default it contains all lectures currently hosted at
`slds-lmu/`.

### Quick Start

The remaining README goes into a little more detail, while this is the
“just get me started” bit.

Say you are working on `lecture_sl` and want to ensure all slides are
compiling without error, then starting from scratch the workflow is as
follows:

1.  Setup the service repo, using a `--single-branch` clone to avoid
    pulling the `gh-pages` branch that’s not needed locally.
2.  File `include_lectures` globally determines the lecture(s) of
    interest, so set it to `lecture_sl`
3.  Install various things in R, LaTeX and the system with `make`. See
    also `make help` and the scripts in `./scripts/install_*`.

``` sh
git clone --single-branch https://github.com/slds-lmu/lecture_service.git
cd lecture_service

# Content in 'include_lectures' determines which lectures are cloned and otherwise considered
echo "lecture_sl" > include_lectures

# Clone lecture_sl (uses shallow clone, main branch only)
make clone
# Install all the things
make install
```

From here on out, you have various options for compilation and
comparison.  
The `Makefile` default target is `site`, giving you the whole comparison
site:

``` r
# Renders comparison to _site/index.html incl comparison PDFs
make site
```

#### Using the R package `lese`

Alternatively, you can use the included R package `lese` to compile and
compare slides individually:

``` r
lese::compile_slide("lecture_sl/slides/regularization/slides-regu-early-stopping.tex")
```

You can omit most parts for the slide file path to rely on the internal
lookup mechanism

``` r
lese::compile_slide("slides-regu-early-stopping")
```

Comparing slides to their `slides-pdf/` counterparts works analogously
(see [Tools](#tools) for an explanation).

``` r
lese::compare_slide("slides-regu-early-stopping")
```

#### Using the cli `lecheck`

The included command-line tool in `./inst/lecheck` can be used as well,
if symlinked into your \`\$PATH.  
It is still experimental and features can and will change.

``` sh
./inst/lecheck --help
```

    ## SLDS Lecture Checker.
    ## 
    ## Usage:
    ##   lecheck [compile] [compare] [clean] [--lecture=<lc>] [--topic=<tc>] [--slide=<sn>] [--preclean] [--no-margin] [--background] [--pdf-copy] [--verbose]
    ##   lecheck compile [--pdf-copy] [--tinytex] [--background]
    ##   lecheck compare [--no-comparison-pdf] [--background]
    ##   lecheck clean [--background]
    ##   lecheck everything [--no-comparison-pdf] [--background]
    ##   lecheck list [--lecture=<lc>] [--topic=<tc>]
    ##   lecheck (-h | --help)
    ##   lecheck --version
    ## 
    ## Example:
    ##   lecheck compile -l i2ml
    ##   lecheck compile -t cart
    ##   lecheck compare -s slides-basics-riskminimization
    ##   lecheck clean -l i2ml
    ##   lecheck list
    ## 
    ## Options:
    ##   -h --help             Show this screen.
    ##   --version             Show version.
    ##   everything            Runs check_all_slides(), which saves results to a file rather than displaying them.
    ##   list                  List all lectures and topics found in this directory.
    ##   -l --lecture=<lc>     Lecture repository, e.g. "lecture_i2ml".
    ##                         Can be abbreviated (dropping "lecture_" prefix) [default: NULL].
    ##   -t --topic=<tc>       Lecture topic, e.g. "cart".
    ##                         Assumed to be unique across lectures.
    ##                         Takes precedence over --lecture [default: NULL].
    ##   -s --slide=<sn>       Slide name, e.g. slides-boosting-cwb-basics.
    ##                         No need for file extension etc. [default: NULL].
    ##                         Takes precedence over --lecture and --topic.
    ##   --no-margin           If set, compiles slides without speaker margin, i.e. 4:3 layout.
    ##   --pdf-copy            Copy rendered slides to slides-pdf/<slide-name>.tex.
    ##   --no-comparison-pdf   Do not render comparison PDFs to comparison/.
    ##   --preclean            Cleans up using `latexmk -C` before compilation.
    ##   --tinytex             Use TinyTex latexmk emulation to auto-install missing packages.
    ##   --background          Do not wait for compilation for status checks. Not applicable if --tinytex is used.
    ##                         Note that this still enumerates lectures and topics but omits status reports.

``` sh
# Compile all slides in the 'regularization' topic (in lecture_sl)
lecheck compile -t regularization
```

``` sh
# Remove all LaTeX detritus and output PDF from all slides in the lecture.
# Can also use 'sl' as 'lecture_' prefix is trimmed
lecheck clean -l lecture_sl
```

``` sh
# Compile a single slide (from i2ml in this case)
lecheck compile -s slides-regu-early-stopping

# Compare against slides in slides-pdf
lecheck compare -s slides-regu-early-stopping
```

Note that `lecheck` can only be run in the `lecture_service` directory
which must contain the lecture repos.

#### Compile `all` slides

To compile all slides in a lecture in 16:9 and copy them to
`slides-pdf`:

    lecheck compile -l sl --preclean --pdf-copy

This compiles one-by one, emitting errors if they come up. Add
`--background` to skip any error reporting and speed up the process.

Afterwards the special `slides/all` slide set containing all slides
combined can be compiled manually using the regular `Makefile`:

    cd lecture_sl/slides/all

    make most

This does not copy the `lecture_sl.pdf` file to `slides-pdf` yet, but
`make all` would.

**Important**: For lectures like I2ML and SL, the `all`-slideset
produces a PDF that is too large (\>35MB) and breaks Overleaf
integration. In these cases the PDF must be moved manually to the Google
Drive SLDS folder (e.g. `Teaching/I2ML/slides_website` for I2ML and SL).
Create a “view only” public share link to the course website where
appropriate (see [here for I2ML and
SL](https://github.com/slds-lmu/i2ml/blob/main/content/chapters/00_all/_index.md?plain=1))

Alternatively, to create 4:3 slides (without margin):

``` sh
lecheck compile -l sl --preclean --pdf-copy

cd lecture_sl/slides/all
make most-nomargin
```

Please note that this `all` slideset merely aggregates the existing
PDFs, so if you want to change the margin setting you have to rerender
*all* slides in the lecture (e.g. via
`lecheck compile -l i2ml --preclean --no-margin` for all of I2ML)

## Slide Compilation & Checking

If all required software is installed (see next section), you can run

``` sh
make site
```

which produces a site at `_site/index.html`.

`_site/` also contains `lecture_*` folders which *do not* contain the
entire lecture repositories, but only the rendered slide PDF files.
These are used for visual comparison of PDFs produced from `<slide>.tex`
files and the “known good” `slide-pdf/<slide>.pdf` file. It also
contains a `comparison` folder, which contains PDF diffs produced by
[`diff-pdf`](https://github.com/vslavik/diff-pdf). These notably only
contain the pages that actually contain some (possibly very minor)
differences.

For manual use in R you can also use the helper functions in `R/`
directly.

Or, if you prefer to work from the terminal, I experimentally wrapped
most functionality in a command-line tool, see
`./inst/lecheck --help`.  
The following examples assume that you have added or symlinked `lecheck`
into your `$PATH`:

``` sh
# List topics in given lecture
lecheck -l lecture_i2ml

# Compile and then compare all slides in i2ml, using lazy shorthand for i2ml
lecheck compile -l i2ml
lecheck compare -l i2ml

# Only the forests topic (auto-detects that this is in i2ml as slide names and topics are assumed to be unique)
lecheck compile -t forests
```

## Counting Files

A separate quarto file can be rendered to count all files per
directories in lecture folders. If you have not set up this repository
alread, run:

``` sh
git clone --single-branch https://github.com/slds-lmu/lecture_service.git
cd lecture_service
make download
make install-service
```

And then render the report:

    quarto render file_counts.qmd

## Prerequisites

Scripts to install R, LaTeX, and system dependencies are located in
`scripts/`. This should work reproducibly on recent Ubuntu versions as
it does on GitHub actions, but system tools will need special handling
on other OSes. I have it running on macOS as well but have no test
system to check a reproducible approach, and I have no idea how to make
any of this work on Windows, sorry (maybe try WSL?).

``` sh
# Install everything below
make install

# Install R packages
make install-r

# Install LaTeX packages via TinyTeX
make install-tex

# Attempt to install diff-pdf (from source) and diff-pdf-visually (via pip)
make install-tools-ubuntu

# Since this is also an R package, install it with e.g.
make install-service
```

### LaTeX Dependencies (Required)

<style type="text/css">
.note-box > h6 {
  margin-top: 1rem;
  margin-bottom: 1rem;
  padding-top: 10px;
  padding-left: 2rem;
}
&#10;.note-box > p {
  margin-top: 0;
  margin-bottom: 0;
  padding-left: 2rem;
  padding-right: 2rem;
  border-left-color: #FECE31;
}
&#10;div.note-box {
  border-left: 0.5rem;
  border-left-style: solid;
  padding-bottom: 1rem;
  margin-left: auto;
  margin-right: auto;
  width: 90%;
  margin-bottom: 1rem;
  margin-top: 1rem;
  border-radius: 1rem;
}
</style>

<div class="note-box">

<h6>

⚠ LaTeX version ⚠
</h6>

<p>

Note that <strong>TeX Live 2024</strong> is required for slides to
compile correctly.
</p>

<p>

Check with e.g.
</p>

<code>
<pre>
$ tlmgr --version
tlmgr revision 71331 (2024-05-24 09:30:36 +0200)
tlmgr using installation: <some path>/TinyTeX
TeX Live (https://tug.org/texlive) version 2024
</pre>

</code>

</div>

LaTeX dependencies are installed via `scripts/install_tex_deps.R` or
`make install-tex` via TinyTeX (recommended) or system `tlmgr`.

I recommend installing [TinyTeX](https://yihui.org/tinytex/) to manage
TeX Live, as I found it to be easy and reliable, and you are independent
from whatever your OS package manager offers.

Install it in R:

``` r
install.packages("tinytex")
tinytex::install_tinytex()
```

To make sure you can compile slides locally:

``` r
# tinytex emulates latexmk and installs missing latex packages automatically.
# Wrapper fun in service repo just sets working directories automatically
lese::compile_slide_tinytex("lecture_i2ml/slides/cart/slides-cart-splitcriteria-classification.tex")
```

Or using `latexmk` internally instead of TinyTeX:

``` r
lese::compile_slide("lecture_i2ml/slides/cart/slides-cart-splitcriteria-classification.tex")
```

### Tools for Slide-Checking (Optional)

These are installed via `scripts/install_tools_ubuntu.sh` or
`make install-tools-ubuntu`.

- [`diff-pdf-visually`](https://pypi.org/project/diff-pdf-visually/):
  For a simple parseable check, e.g.

``` sh
❯ diff-pdf-visually slides-forests-proximities.pdf ../../slides-pdf/slides-forests-proximities.pdf
  Temporary directory: /var/folders/n1/p1hxy7856nndrd0njv0lxzgw0000gn/T/diffpdfdy0681qc
  Converting each page of the PDFs to an image...
  PDFs have same number of pages. Checking each pair of converted images...
Min sig = 14.1795, significant?=True. The PDFs are different. The most different pages are: page 5 (sgf. 14.1795), page 2 (sgf. 14.6277), page 4 (sgf. 15.1376), page 7 (sgf. 16.1474), page 3 (sgf. 16.6224).
```

This needs to be installed and in your `$PATH`, such that
`processx::process()` can run it. The output is used to automatically
check if it is necessary to run `diff-pdf`.

- [`diff-pdf`](https://vslavik.github.io/diff-pdf/), for an actual
  visual comparison for your eyeballs:

``` sh
diff-pdf --view slides-forests-proximities.pdf ../../slides-pdf/slides-forests-proximities.pdf
```

This is used to produce PDFs of only the differences at `comparison` and
for the HTML table.
