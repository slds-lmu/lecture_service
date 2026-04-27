# AGENTS.md

Project guide for contributors and AI agents working on the `lese` R
package and lecture service infrastructure.

## What This Project Does

This is a **dual-purpose** repository:

1.  **R package (`lese`)** — functions for compiling, checking, and
    auditing lecture slides across multiple LaTeX-based lecture
    repositories
2.  **Service repository** — central hub that clones lecture repos
    (`lecture_i2ml`, `lecture_sl`, …) and syncs shared infrastructure
    (Makefiles, LaTeX styles, GitHub Actions workflows) to them

The lecture repos are **not** in this git tree. They are
cloned/symlinked as sibling directories
(e.g. `lecture_service/lecture_i2ml/`).

## Project Layout

### This Repository

    lecture_service/
    ├── R/                    # R package source (the lese package)
    ├── man/                  # Generated roxygen2 docs (do not edit manually)
    ├── inst/                 # Package-installed files
    │   ├── lecheck           # CLI tool (docopt-based)
    │   ├── check_status.R    # CI exit-code script
    │   ├── chapter_audit.Rmd # Audit report template
    │   ├── slide_status.Rmd  # HTML status site template
    │   └── slide_status_pr.Rmd  # PR comment table template
    ├── service/              # Files synced TO lecture repos
    │   ├── Makefile          # Lecture-level Makefile template
    │   ├── style/            # LaTeX style files (preamble, .sty packages)
    │   ├── scripts/          # Lecture-level scripts (update-service.sh, etc.)
    │   ├── slides/
    │   │   ├── tex.mk        # Chapter-level Makefile (included by slides/<ch>/Makefile)
    │   │   └── R.mk          # rsrc-level Makefile (included by slides/<ch>/rsrc/Makefile)
    │   └── .github/workflows/  # CI workflow templates for lectures
    ├── scripts/              # Service-level scripts (clone, download, install)
    ├── Makefile              # Orchestration Makefile for lecture_service itself
    ├── DESCRIPTION           # R package metadata
    └── NAMESPACE             # Generated (devtools::document)

### Individual Lecture Repositories

Each lecture repository (e.g. `lecture_i2ml`) follows a standard
structure:

    lecture_i2ml/
    ├── slides/               # Source .tex files organized by chapter
    │   ├── ml-basics/
    │   │   ├── slides-basics-data.tex
    │   │   ├── slides-basics-learner.tex
    │   │   ├── figure/       # Generated figures (from rsrc/ scripts)
    │   │   ├── figure_man/   # Manually created figures
    │   │   ├── rsrc/         # R scripts that generate figures
    │   │   └── Makefile      # One-liner: include ../tex.mk
    │   └── tex.mk            # Symlinked/copied from service/slides/tex.mk
    ├── slides-pdf/           # "Known good" PDFs for comparison
    ├── style/                # Synced from lecture_service/service/style/
    ├── latex-math/           # Submodule from slds-lmu/latex-math
    ├── scripts/              # Synced from lecture_service/service/scripts/
    ├── .github/workflows/    # Synced from lecture_service/service/.github/
    └── Makefile              # Top-level targets (synced from service/)

**Naming conventions:** - Slide files: `slides-<chapter>-<name>.tex`
(some lectures use numbered prefixes, not yet universal) - Chapters
correspond to `slides/` subdirectories - Excluded directories: `attic`,
`rsrc`, `all`, `figure`, `figure_man`, `backup` - Excluded files:
`chapter-order*.tex`, `OLD-*`, `TO-DO*`, `TODO*`

## Key Concepts

### The Three Levels

Everything operates at three nested levels:

| Level       | Directory example                      | Makefile                | What happens here                                               |
|-------------|----------------------------------------|-------------------------|-----------------------------------------------------------------|
| **Lecture** | `lecture_i2ml/`                        | `service/Makefile`      | `make audit`, `make slides` (all chapters), `make install-lese` |
| **Chapter** | `lecture_i2ml/slides/evaluation/`      | `service/slides/tex.mk` | `make slides`, `make audit`, `make check-repro`                 |
| **rsrc**    | `lecture_i2ml/slides/evaluation/rsrc/` | `service/slides/R.mk`   | `make all` (run scripts), `make deps`                           |

Chapter Makefiles are one-liners (`include ../tex.mk`), `rsrc` Makefiles
are one-liners (`include ../../R.mk`).

### Figure Audit Data Flow

    rsrc/*.R scripts  →  figure/*.png  →  slides-*.tex  →  .fls files (from latexmk)
                              ↑                                    ↓
                        audit_chapter() cross-references these to find:
                        - orphaned figures (on disk, not in any slide)
                        - missing figures (in slide, not on disk)
                        - attic figures (in figure/attic/, informational only)

Two detection methods: - **regex**: parses `.tex` source for
`\includegraphics` etc. Fast but misses dynamic paths. - **fls**: reads
`.fls` recorder files from `latexmk -recorder`. More accurate (respects
comments, `\iffalse` conditionals). Requires prior `make slides`. -
**auto** (default): uses fls if all `.fls` files exist, otherwise regex.

### Service Sync Mechanism

Lectures pull updates from `lecture_service` via
`bash scripts/update-service.sh [branch]`: - Downloads tarball from
GitHub API - `rsync --delete` for `style/` (strict sync) - Copies
`scripts/`, `.github/`, `Makefile`

This means changes to `service/` files propagate to lectures only when
they explicitly run the update script.

## R Package Architecture

### Function Categories

**Discovery**:
[`lectures()`](https://slds-lmu.github.io/lecture_service/reference/lectures.md),
[`collect_lectures()`](https://slds-lmu.github.io/lecture_service/reference/collect_lectures.md),
[`find_slide_tex()`](https://slds-lmu.github.io/lecture_service/reference/find_slide_tex.md)
— find lectures and slides

**Compilation**:
[`compile_slide()`](https://slds-lmu.github.io/lecture_service/reference/compile_slide.md)
dispatches to
[`latexmk_system()`](https://slds-lmu.github.io/lecture_service/reference/latexmk_system.md)
/
[`latexmk_docker()`](https://slds-lmu.github.io/lecture_service/reference/latexmk_docker.md)
/
[`latexmk_tinytex()`](https://slds-lmu.github.io/lecture_service/reference/latexmk_tinytex.md)

**Checking**:
[`check_slides_single()`](https://slds-lmu.github.io/lecture_service/reference/check_slides_single.md),
[`check_slides_many()`](https://slds-lmu.github.io/lecture_service/reference/check_slides_many.md)
(parallel via `future.apply`),
[`compare_slide()`](https://slds-lmu.github.io/lecture_service/reference/compare_slide.md)
(uses `diff-pdf-visually`)

**Auditing**:
[`audit_chapter()`](https://slds-lmu.github.io/lecture_service/reference/audit_chapter.md),
[`clean_orphaned_figures()`](https://slds-lmu.github.io/lecture_service/reference/clean_orphaned_figures.md),
[`render_chapter_audit()`](https://slds-lmu.github.io/lecture_service/reference/render_chapter_audit.md)

**Scripts**:
[`run_script()`](https://slds-lmu.github.io/lecture_service/reference/run_script.md),
[`run_chapter_scripts()`](https://slds-lmu.github.io/lecture_service/reference/run_chapter_scripts.md)
— isolated [`callr::r()`](https://callr.r-lib.org/reference/r.html)
subprocesses

**Dependencies**:
[`extract_script_deps()`](https://slds-lmu.github.io/lecture_service/reference/extract_script_deps.md),
[`check_script_deps()`](https://slds-lmu.github.io/lecture_service/reference/check_script_deps.md),
[`check_lecture_deps()`](https://slds-lmu.github.io/lecture_service/reference/check_lecture_deps.md)

**Reporting**:
[`render_slide_status()`](https://slds-lmu.github.io/lecture_service/reference/render_slide_status.md),
[`render_slide_status_pr()`](https://slds-lmu.github.io/lecture_service/reference/render_slide_status_pr.md)
— render Rmd templates from `inst/`

### Internal Helpers (not exported)

- `check_lecture_dir()` — validates lecture directory, auto-discovers
  via [`here::here()`](https://here.r-lib.org/reference/here.html)
- `get_chapter_figures()` — lists files in `figure/` and `figure_man/`
  with metadata
- `get_chapter_scripts()` — lists `.R` files in `rsrc/`
- `parse_fls_figures()` — parses `.fls` recorder files for figure paths
- `is_pkg_installed()` — checks package availability without loading
  namespace

### Slide Cache

- Stored in `rappdirs::user_data_dir("lese")`, NOT in the repo
- `.slide_check_stamp` stamp file in repo root tracks freshness
- [`slide_cache_path()`](https://slds-lmu.github.io/lecture_service/reference/slide_cache_path.md)
  /
  [`slide_cache_clean()`](https://slds-lmu.github.io/lecture_service/reference/slide_cache_clean.md)
  manage it

## Documentation

There are three layers of documentation:

1.  **GitHub Wiki** (`lecture_service.wiki/`) — the primary user-facing
    documentation, living at
    <https://github.com/slds-lmu/lecture_service/wiki>. The wiki is
    cloned as a sibling repo at `lecture_service.wiki/`. It targets two
    audiences:

    - **Lecture authors**: how to write slides, use custom LaTeX
      environments, compile locally, record videos, manage Overleaf sync
    - **Infrastructure maintainers**: how the service repo works, CI
      workflows, CLI tools, figure audit and reproducibility checks

    Key wiki pages: \| Page \| Audience \| Covers \| \| ————————————– \|
    ———– \| ——————————————————————————————- \| \| Slides \| Authors \|
    Slide structure, custom environments (`framei`/`framev`), layout
    macros, content guidelines \| \| Slide-Code-Guide \| Authors \| Best
    practices for R scripts in `rsrc/` (reproducibility, naming,
    plotting) \| \| Slides-Compilation \| Both \| Compiling slides
    locally via Makefile or `lecheck`, Docker support \| \|
    Slide-reproducibility-and-unused-files \| Maintainers \| Figure
    audit, orphaned/missing detection, `check-repro`,
    `clean-orphaned-figures` \| \| lecture_service \| Maintainers \|
    Service repo setup, LaTeX style files, CI workflows \| \|
    lecheck-cli \| Maintainers \| CLI tool documentation \| \|
    GitHub-Actions \| Maintainers \| Automated workflows (slide checks,
    PR comments, latex-math updates) \| \| Publishing-Content \|
    Maintainers \| Publishing slides, exercises, literature lists to
    course websites \| \| latex-math \| Both \| Shared notation
    repository, adding/updating macros \| \|
    Overleaf-and-GitHub-Integration \| Authors \| Syncing Overleaf and
    GitHub, handling line endings \|

2.  **pkgdown site** (<https://slds-lmu.github.io/lecture_service/>) —
    auto-generated R package API reference from roxygen2 docs in `R/`
    files

3.  **AGENTS.md** (this file) — technical context for AI agents and
    contributors working on the codebase itself. CLAUDE.md points here.

When adding new features or changing behavior, update both the relevant
wiki page(s) and the R package documentation (roxygen2 + `NEWS.md`).

## Development Workflow

### After editing R files

``` sh
air format R/modified-file.R    # format with air
Rscript -e 'devtools::document()'  # regenerate NAMESPACE + man/
Rscript -e 'devtools::check()'     # or devtools::test() for faster feedback
```

### Key conventions

- Use `cli` package for user-facing messages (never
  [`cat()`](https://rdrr.io/r/base/cat.html) or
  [`print()`](https://rdrr.io/r/base/print.html))
- Avoid [`return()`](https://rdrr.io/r/base/function.html) at end of
  functions (only for early returns)
- Use `data.table` in package code for performance; `dplyr`/tidyverse ok
  in Rmd templates
- testthat 3e for tests
- `latexmk -pdf -halt-on-error` for LaTeX compilation

### Testing changes to Makefiles

Makefiles in `service/` are templates. To test locally: 1. Edit
`service/slides/tex.mk` (or `service/Makefile`, etc.) 2. In a lecture
repo: `bash scripts/update-service.sh figure-repro` (or your branch) 3.
Test the targets there

### Adding a new exported function

1.  Add the function in `R/<appropriate-file>.R` with roxygen2 docs and
    `@export`
2.  Run `devtools::document()` to update NAMESPACE and generate man page
3.  Add entry to `_pkgdown.yml` in the appropriate section
4.  Add entry to `NEWS.md` under the dev version header
5.  Run `devtools::check()` to verify

## CI Workflows

### For lecture_service itself

- `R-CMD-check.yaml` — standard R package checks
- `pkgdown.yaml` — builds docs site at
  <https://slds-lmu.github.io/lecture_service/>

### Templates synced to lectures (`service/.github/workflows/`)

- `pr-slide-check.yaml` — on PRs: compile affected slides, post results
  as PR comment
- `render-lecture-slide-status.yaml` — on push to main: compile all
  slides, deploy HTML status site to GitHub Pages

Both share the pattern: checkout lecture_service at root, checkout
lecture as subdirectory, dual cache (R packages + TinyTeX), then run
make targets.

## LaTeX Style Files

**Location:** `service/style/` (synced to `lecture_*/style/`)

- **`preamble.tex`** — main preamble loaded by all slides
- **`lmu-lecture.sty`** — main beamer theme; handles margin vs no-margin
  switching via `nospeakermargin.tex`
- **`framei.sty`** — enhanced frame with automatic itemize wrapper
  (`fs`, `sep`, `align` options)
- **`framev.sty`** — vanilla frame without itemize, replaces old
  `frame2` (`fs`, `align` options)
- **`image.sty`** — `\image`, `\imageC`, `\imageFixed` macros for
  `\includegraphics`
- **`customitemize.sty`** — `itemizeS`/`itemizeM`/`itemizeL` etc. with
  font size control
- **`splitV.sty`** — `\splitVCC`, `\splitVTT` etc. for column layouts
- **`ref-buttons.sty`** — `\furtherreading{}`, `\sourceref{}`,
  `\citelink{}`

## External Dependencies

- **R packages**: cli, dplyr, fs, git2r, processx, tinytex,
  future.apply, callr, data.table, rappdirs
- **LaTeX**: TinyTeX or full TeX Live distribution
- **Tools** (optional): `diff-pdf`, `diff-pdf-visually` (for slide
  comparison), `pdfannotextractor` (pax, for hyperlink preservation)
- **Docker** (optional): GitLab TeX Live images for reproducible
  compilation

## Common Tasks

### Adding a new lecture

1.  Clone/download repo to `lecture_service/`
2.  Add to `include_lectures` file
3.  Run `make site` to include in checks

### Updating style files

1.  Edit files in `service/style/`
2.  Test locally in a lecture repo
3.  Lectures pull updates via `bash scripts/update-service.sh`

### Debugging failed slides

1.  Check GitHub Pages status site:
    `https://slds-lmu.github.io/{lecture_name}/`
2.  Review comparison PDFs for visual diffs
3.  Check LaTeX logs in workflow output
4.  Compile locally:
    `lecheck compile lecture_name chapter_name slide_name`

## Known Gotchas

### Beamer environment naming

**NEVER** name custom beamer environments `frame<digit>` (e.g. `frame2`,
`frame3`). This triggers beamer’s internal frame parser and causes
cryptic “Use of doesn’t match its definition” errors.

- Bad: `frame2`, `frame3`, `frame123`
- Good: `framei`, `framev`, `myframe`, `customframe`

**Root cause**: When `\NewEnviron{frame2}` is defined, LaTeX creates
internal macros including `\frame2`. Beamer’s parser scans for
`\frame` + digit patterns and mistakes this for a malformed frame
command. The conflict is latent in the name but only manifests when
`keyval` processing is involved (e.g. adding `\define@key` options).
This is why `frame2` used to work with simple font-size passthrough but
broke when alignment options were added.

**If you see this error**: Check if the environment name matches
`frame<digit>`. Rename to use letters. Don’t debug keyval syntax — it’s
not the issue.

### `.fls` vs regex figure detection

A figure can appear orphaned with `.fls` method even though it’s in the
`.tex` source if: - The `\includegraphics` is commented out (`%`) - It’s
inside `\iffalse...\fi` or `\if0...\fi` (disabled conditional) - The
`.fls` file is stale (re-run `make slides`)

This is correct behavior — `.fls` reflects what LaTeX *actually read*.

### `here::here()` in lecture context

Most functions default `lecture_dir = here::here()`. This works when the
working directory is anywhere inside a lecture repo (thanks to `.here`
or `.git` markers). When working from `lecture_service/`, you must pass
`lecture_dir` explicitly.

### Symlinked lectures

[`collect_lectures()`](https://slds-lmu.github.io/lecture_service/reference/collect_lectures.md)
uses `fs::dir_ls(..., type = "any")` to discover lecture directories,
supporting symlinks. This was a past bug — `type = "directory"` skipped
symlinks.

### Package installation checks

`is_pkg_installed()` uses
[`requireNamespace(quietly = TRUE)`](https://rdrr.io/r/base/ns-load.html)
to check without loading, avoiding namespace conflict warnings
(e.g. mlr3 vs mlr). Never use
[`library()`](https://rdrr.io/r/base/library.html) for checking.
