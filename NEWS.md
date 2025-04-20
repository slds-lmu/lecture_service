# lese 0.3.9000 (In development)

## R package

* Add experimental `latexmk_docker()` to run `latexmk` wrapped in a docker image with a fixed TeXLive version
* `compile_slide()` gains `method` argument, defaulting to `"system"` to use local `ltexmk`. Can be `"docker"` to use the new `latexmk_docker()` instead.
* Remove `compile_slide_tinytex()` and convert it to the somewhat simpler `latexmk_tinytex()` for use with `compile_slide()`
* `clean_slide()` gains `keep_pdf` option, defaulting to `FALSE` for previous behavior.
* `clean_slide()` gens `check_status` option, analogous to that in `compile_slide()`. The same argument in `compile_slide()` is passed to `clean_slide()`.
* `compare_slide()` gains additional option `eps_signif` (`[0.5]`) to manually filter output from `diff-pdf-visually` to decrease number of false-positives.

## `lecheck` cli:

- Gains `--docker` argument, passed to `compile_slide()` to use `latexmk_docker()`
- Gains `--postclean` argument to run `latexmk -c` after compilation, removing all detritus but keeping the `.pdf` file.

## LaTeX

* Discourageing the use of automatic and explicit `\framebreak`s, which cause rendering issues after some TeXLive version post 2023 cutoff:
  * The `vbframe` environment is considered **deprecated** and should be replace with "regular" beamer `frame`s.
  * Removed framenumber continuation counter from `lmu-lecture.sty` for simplification
* Related: The `vframe` environment (rarely used) is now removed.

**Breaking changes** for recently introduced macros (see [the wiki](https://github.com/slds-lmu/lecture_service/wiki/Slides#custom-macros-for-layout-images-citations)):

* `splitV` now maps to `splitVCC`, not `splitVTT`
* `itemizefill` is renamed to `itemizeF`

**New macros** (see [the wiki](https://github.com/slds-lmu/lecture_service/wiki/Slides#custom-macros-for-layout-images-citations) for usage instructions)

* Extended `itemizeS`, `itemizeM` etc. to take argument for font size control, e.g. `\begin{itemizeM}[small]`.
  * Built upon modular `kitemize` environment.
* Added `framei` environment which automatically wraps content in flexible `itemize` environments with font size and spacing controls.


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
