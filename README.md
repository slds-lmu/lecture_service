# SLDS Lecture Service (lese)

<!-- badges: start -->
[![R-CMD-check](https://github.com/slds-lmu/lecture_service/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/slds-lmu/lecture_service/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

[[Teaching DevOps Wiki](https://github.com/slds-lmu/lecture_service/wiki)] [[Issue Tracker](https://github.com/orgs/slds-lmu/projects/5/views/1)]

**Note:** Guides and tutorials for working with lectures live in the [Teaching DevOps Wiki](https://github.com/slds-lmu/lecture_service/wiki).
This README covers setup and the R package; for topics like slide authoring, compilation workflows, and CI troubleshooting, see the wiki.

This project has two goals:

1. Provide common assets needed for all lectures, once, to keep them in sync.
2. Check slides in lecture repositories (do they compile, are the PDFs up to date?).

(It also happens to be an R package `lese` you can install with many convenience functions)

For 1), all required files should live in `./service/` with the **correct folder structure** such that one can simply copy the files from this directory "on top" of an existing lecture, e.g.:

```sh
rsync -r lecture_service/service/ lecture_i2ml/
```

This is wrapped with the script in each lecture's `./scripts/update-service.sh` so within e.g. `lecture_i2ml` you can run

```sh
bash scripts/update-service.sh
```

Any changes proposed to service files covered by `./service` (particularly the `style` folder) will first need to be made in this repo and then dependent lecture repos can be updated accordingly.

## Overview

The assumed directory structure once lecture repositories were cloned (or downloaded) looks like this:

```
lecture_service
├── lecture_advml
├── lecture_i2ml
├── lecture_sl
├── [...]
├── Makefile
├── R
├── scripts
├── service
└── [...]
```

You can either manually `git clone` lecture repos or use `make clone`

Note that the text file `include_lectures` is used to globally keep track of the relevant lecture repos, so if you only intend to work on `lecture_advml` you could set it to only contain `lecture_advml` and subsequent `make` commands and other functions will be limited in scope to this lecture.
By default it contains all lectures currently hosted at `slds-lmu/`.

## Installation

The `lese` R package provides functions for compiling, checking, and auditing lecture slides.

```r
# Install with pak (recommended)
pak::pak("slds-lmu/lecture_service")

# Or with remotes
remotes::install_github("slds-lmu/lecture_service")
```

Alternatively, from within the `lecture_service` directory:

```sh
make install
```

The package also includes a `lecheck` CLI tool; see the [lecheck-cli](https://github.com/slds-lmu/lecture_service/wiki/lecheck-cli) wiki page for usage.
