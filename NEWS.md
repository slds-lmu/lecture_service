# lese 0.1.0

* Start taking versioning somewhat seriously.
* `lecheck`: Add `--no-comparison-pdf` flag to avoid creating diff PDFs via `compare_slides()`.
* `lecheck`: Add `--no-margin` flag that compiles slides without speaker margin.
* Add `margin` flag to `compile_slides` and `compile_slides_tinytex` to facilitate with/without margin compilation
* Add `lese::set_margin_token_file` utility to manage the token file for the above.
* Improve robustness of lecture directory listing in `collect_lecture`.
* Add `file_counts.qmd` (still needs some cleanup and ideally a subdirectory, but paths...)
