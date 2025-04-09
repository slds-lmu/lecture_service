SLDS Lecture Service
================

- [Overview](#overview)

<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->

[![R-CMD-check](https://github.com/slds-lmu/lecture_service/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/slds-lmu/lecture_service/actions/workflows/R-CMD-check.yaml)
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
which is also synced into each lecture’s top-level `./scripts/` folder.

Afterwards, `git status` can be used to check changes.

## Overview

The assumed directory structure once lecture repositories where cloned
(or downloaded) looks like this:

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

You can either manually `git clone` lecture repos or use `make clone`

Note that the text file `include_lectures` is used to globally keep
track of the relevant lecture repos, so if you only intend to work on
`lecture_advml` you could set it to only contain `lecture_advml` and
subsequent `make` commands and other functions will be limited on scope
to this lecture. By default it contains all lectures currently hosted at
`slds-lmu/`.

Refer to the [Teaching DevOps
Wiki](https://github.com/slds-lmu/lecture_service/wiki) for our central
documentation hub.
