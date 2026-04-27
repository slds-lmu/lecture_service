# Package index

## Finding things

Identifying lectures, finding slides, and checking things are the way
they need to be.

- [`lectures()`](https://slds-lmu.github.io/lecture_service/reference/lectures.md)
  : Get included lectures
- [`collect_lectures()`](https://slds-lmu.github.io/lecture_service/reference/collect_lectures.md)
  : Assemble table of lecture slides
- [`find_slide_tex()`](https://slds-lmu.github.io/lecture_service/reference/find_slide_tex.md)
  : Find a slide set across all lectures
- [`check_system_tool()`](https://slds-lmu.github.io/lecture_service/reference/check_system_tool.md)
  : Simple check for availability of system tools
- [`check_docker()`](https://slds-lmu.github.io/lecture_service/reference/check_docker.md)
  : Check if docker can be used

## Compilation and checking

Compile slides with either latexmk or TinyTeX, and check them against
the reference files in slides-pdf.

- [`check_slides_single()`](https://slds-lmu.github.io/lecture_service/reference/check_slides_single.md)
  : Compile and compare a slide chunk
- [`check_slides_many()`](https://slds-lmu.github.io/lecture_service/reference/check_slides_many.md)
  : Compile and compare many slides
- [`compile_slide()`](https://slds-lmu.github.io/lecture_service/reference/compile_slide.md)
  : Compile a single .tex file
- [`compare_slide()`](https://slds-lmu.github.io/lecture_service/reference/compare_slide.md)
  : Compare slide PDF against reference PDF
- [`clean_slide()`](https://slds-lmu.github.io/lecture_service/reference/clean_slide.md)
  : Clean output for a single .tex file
- [`latexmk_docker()`](https://slds-lmu.github.io/lecture_service/reference/latexmk_docker.md)
  : Run dockerized latexmk
- [`latexmk_system()`](https://slds-lmu.github.io/lecture_service/reference/latexmk_system.md)
  : Run latexmk
- [`latexmk_tinytex()`](https://slds-lmu.github.io/lecture_service/reference/latexmk_tinytex.md)
  : Run TinyTex's latexmk

## Figure script auditing

Audit the script-figure-slide dependency chain within lecture chapters.

- [`audit_chapter()`](https://slds-lmu.github.io/lecture_service/reference/audit_chapter.md)
  : Audit the script-figure-slide dependency chain for a chapter
- [`clean_orphaned_figures()`](https://slds-lmu.github.io/lecture_service/reference/clean_orphaned_figures.md)
  : Remove orphaned figures from a chapter
- [`render_chapter_audit()`](https://slds-lmu.github.io/lecture_service/reference/render_chapter_audit.md)
  : Render a chapter audit report
- [`run_chapter_scripts()`](https://slds-lmu.github.io/lecture_service/reference/run_chapter_scripts.md)
  : Run all scripts in a chapter and track produced figures
- [`run_script()`](https://slds-lmu.github.io/lecture_service/reference/run_script.md)
  : Run an R script in an isolated subprocess
- [`parse_slide_figures()`](https://slds-lmu.github.io/lecture_service/reference/parse_slide_figures.md)
  : Parse figure references from a LaTeX slide file
- [`extract_script_deps()`](https://slds-lmu.github.io/lecture_service/reference/extract_script_deps.md)
  : Extract package dependencies from R scripts
- [`check_script_deps()`](https://slds-lmu.github.io/lecture_service/reference/check_script_deps.md)
  : Check and install missing dependencies for chapter scripts
- [`check_lecture_deps()`](https://slds-lmu.github.io/lecture_service/reference/check_lecture_deps.md)
  : Check and install missing dependencies for all chapter scripts

## Slide status reporting

Render slide status reports and manage the slide check cache.

- [`render_slide_status()`](https://slds-lmu.github.io/lecture_service/reference/render_slide_status.md)
  : Render the slide status HTML report
- [`render_slide_status_pr()`](https://slds-lmu.github.io/lecture_service/reference/render_slide_status_pr.md)
  : Render the slide status PR markdown table
- [`slide_cache_path()`](https://slds-lmu.github.io/lecture_service/reference/slide_cache_path.md)
  : Get the path to the slide check cache file
- [`slide_cache_clean()`](https://slds-lmu.github.io/lecture_service/reference/slide_cache_clean.md)
  : Delete the slide check cache

## Utilities

Various helper functions

- [`check_log()`](https://slds-lmu.github.io/lecture_service/reference/check_log.md)
  : Check latexmk logs for common errors
- [`bib_to_list()`](https://slds-lmu.github.io/lecture_service/reference/bib_to_list.md)
  : Convert bib file to formatted list for Markdown output
- [`install_lecheck()`](https://slds-lmu.github.io/lecture_service/reference/install_lecheck.md)
  : Install the lecheck cli tool
- [`set_margin_token_file()`](https://slds-lmu.github.io/lecture_service/reference/set_margin_token_file.md)
  : Manage the with/without margin dummy file
- [`repo_status()`](https://slds-lmu.github.io/lecture_service/reference/repo_status.md)
  : Lecture repo status
- [`this_repo_status()`](https://slds-lmu.github.io/lecture_service/reference/this_repo_status.md)
  : Service repo checkout status
