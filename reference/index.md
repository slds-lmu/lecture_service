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
