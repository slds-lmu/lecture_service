# lese 0.5.0.9000 (In development)

# lese 0.5.0

- New service file: The root `Makefile` in each lecture was a placeholder, but now it actually does something:
  - Update latex-math (not just via GitHub action now)
  - Update service files
  - Clean LaTeX detritus and PDFs in slide directories
- Robustify the `lecture_service` Makefile to not error if no lectures are cloned (to allow just using `make install` etc.)
- Warn if R is not installed for targets that need it, and link to `rig` as an installation suggestion.
- Convert `file_count.qmd` to RMarkdown for backwards compatibility and consistency with other docs.

## R package

- Add Biblatex utility functions for `references.bib` processing to render per-chapter/lecture lierature lists
- Normalize file paths in `collect_lectures()` (should help path-agnostic usage)
- Change default `compile_slide(..., post_clean = FALSE)` to avoid "file not found" error when `.log` file was unexpectedly missing for checks.
- Fix: Use `fs::path_norm()` instead of `fs::path_real()` for path normalization in `collect_lectures()` because the former expected log files to exists which may not exist.
- Add flexibility for `find_slide_tex()` to allow `compile_slide()` etc. to work with a direct path to a slide file for interactive use in arbitrary directories
= BUmp TeXLive version used by `latexmk_docker()` to 2025.

## LaTeX  (`service/style` etc.)

* Makefile in `slides/` gets big refactors:
  * Remove `all` target, new `release` target that does all the important things and copies to `slides-pdf`
  * Renamed `most` to `slides`
  * Option to use docker (`make slides DOCKER=true`),  
* Logo is now expected at ./local/logo.pdf
* The `\image` macro now can take a url (starting with `http[s]`) to create clickable source link without having to create entry in `references.bib`.
* New `\imageFixed` macro for fixed-position image placement
* Slide check workflows now exit 1 if _at least_ one slide does not compile correctly
* Renamed `frame2` to `framev` to avoid internal beamer package issues
* `framei` and `framev` now override global itemize/enumerate font size control when using a custom font size, and `itemizeM` etc. now correctly inherit their surrounding font sizes when not specified.
* `framei` and `framev` now support `align` argument for beamer frame alignment passthrough.
* Add new ref-buttons `furtherreading{}` and `sourceref{}`, the later superseding `\citelink{}`. `\image` and friends internally use `\sourceref` now.
* Add `chapter-literature.tex` in `style` to compile simple chapter-wise literature lists. Also adds `make` target `literature.`

## GitHub Action workflows (`service/.github/workflows`)

- In both worklows using tinytex, we experimentally pin the used version to 2024.12 for safety. 
  This is likely to change in the future but currently this is the only version generally compatible with everything as far as we know.
  Ideally, we keep bumping this to a recent version, also on Overleaf.
- The Makefile in ./slides/ use a docker image defaulting to 2024 as well

# lese 0.4.0

## R package

* Add experimental `latexmk_docker()` to run `latexmk` wrapped in a docker image with a fixed TeXLive version
* `compile_slide()` gains `method` argument, defaulting to `"system"` to use local `ltexmk`. Can be `"docker"` to use the new `latexmk_docker()` instead.
* Remove `compile_slide_tinytex()` and convert it to the somewhat simpler `latexmk_tinytex()` for use with `compile_slide()`
* `clean_slide()` gains `keep_pdf` option, defaulting to `FALSE` for previous behavior.
* `clean_slide()` gens `check_status` option, analogous to that in `compile_slide()`. The same argument in `compile_slide()` is passed to `clean_slide()`.
* `compare_slide()` gains additional option `eps_signif` (`[0.5]`) to manually filter output from `diff-pdf-visually` to decrease number of false-positives.
* Add `check_docker()` to check whether `docker` is available and running.

## `lecheck` cli:

- Gains `--docker` argument, passed to `compile_slide()` to use `latexmk_docker()`.
  - Currently uses a TeX Live 2023 image as default
  - Allows fully encapsulate compilation of slides with a static environment
- Gains `--postclean` argument to run `latexmk -c` after compilation, removing all detritus but keeping the `.pdf` file.

## LaTeX  (`service/style`)

* Discourageing the use of automatic and explicit `\framebreak`s, which cause rendering issues after some TeXLive version post 2023 cutoff:
  * The `vbframe` environment is considered **deprecated** and should be replace with "regular" beamer `frame`s.
  * Removed framenumber continuation counter from `lmu-lecture.sty` for simplification
* Related: The `vframe` environment (rarely used) is now removed.
* Add cheatsheet preamble content from I2ML. Might need further refactor and adaptation if other lectures also use these.

**Breaking changes** for recently introduced macros (see [the wiki](https://github.com/slds-lmu/lecture_service/wiki/Slides#custom-macros-for-layout-images-citations)):

* `splitV` now maps to `splitVCC`, not `splitVTT`.
* `itemizefill` is renamed to `itemizeF`

**New macros** (see [the wiki](https://github.com/slds-lmu/lecture_service/wiki/Slides#custom-macros-for-layout-images-citations) for usage instructions)

* Extended `itemizeS`, `itemizeM` etc. to take argument for font size control, e.g. `\begin{itemizeM}[small]`.
  * Built upon modular `kitemize` environment.
* Added `framei` environment which automatically wraps content in flexible `itemize` environments with font size and spacing controls.
* Added `frame2`, like `frame` but also has font size control like `itemizeM` etc. and behaves like a regular `frame` otherwise.

# lese 0.3.0

* Rename `check_all_slides` to `check_slides_many()`, which in turn is a wrapper around `check_slides_single()`
* Make documentation more consistent, e.g. by inheriting the `slide_file` parameter doc from `find_slide_tex()`.
* `slide_status_pr.Rmd` and `slide_status.Rmd`: Only show slide comparison column in output if comparison has been conducted (no longer the case by default)
* Remove `make_slides()` as it was effectively superseded by either
    * Running `compile_slide()` on a file of itnerest directly, or
    * Using the `lecheck` cli for more control and better error messages, or
    * Running `make` in selected topic directories in a shell as needed
* Add battery of new layout macros:
  * `\image` and `\imageC` for `\includegraphics`
  * `\splitVXY` family for predefined positioning within columns (see [the wiki](https://github.com/slds-lmu/lecture_service/wiki/Slides#custom-macros-for-layout-images-citations))

# lese 0.2.2

* Ignore  `chapter-order-slides-all.tex` slide name in `collect_lectures()`

# lese 0.2.1

* Added `check_slides()` argument `compare_slides` defaulting to `FALSE`, making the no longer pressingly needed slide comparisons against `slides-pdf` reference slides an optional step rather than default behavior.

# lese 0.2.0

* Add new layout helpers `\splitV`, `\twobytwo` and others, see https://github.com/slds-lmu/teaching_devops_issues/issues/18

# lese 0.1.1

* Add heuristic to handle duplicate slide matches.
  * If topics move between lectures, the current heuristic prefers the most recently edited one.
  * Example: `slides-gp-bayes-lm.tex` is included in `lecture_sl` and `lecture_advml`, but the former is more recent.
* Extend LaTeX dependencies install via `make install-tex` based on requirements of exercises in `lecture_sl`
* Explicitly document that TeX Live 2024 is assumed for the entire setup.

# lese 0.1.0

* `lecheck`: Add `clean` subcommand to run `latexmk -C` and nothing else.
* `lecheck`: Add `--pdf-copy` flag to copy compiled slides to `slides-pdf/<slide-name>.tex`.
* `lecheck`: Add `--no-comparison-pdf` flag to avoid creating diff PDFs via `compare_slides()`.
* `lecheck`: Add `--no-margin` flag that compiles slides without speaker margin.
* Add `margin` flag to `compile_slides(` and `compile_slides_tinytex(` to facilitate with/without margin compilation
* Add `lese::set_margin_token_file` utility to manage the token file for the above.
* Improve robustness of lecture directory listing in `collect_lectures()`.
* Add `file_counts.qmd` (still needs some cleanup and ideally a subdirectory, but paths...)
* Start taking versioning somewhat seriously.
