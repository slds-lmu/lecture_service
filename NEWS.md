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
