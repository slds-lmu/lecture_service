# Rules for exercise sheets (Quarto)

## Scope

- Exercise sheets written in Quarto: a `<sheet>.qmd` per sheet in `exercises/<chapter>/`, with one notebook per language (`sol_<sheet>_R.ipynb`, `sol_<sheet>_py.ipynb`).
- Applies to writing new sheets, editing sheets, and converting existing sheets from LaTeX, Rnw or Rmd.
- Not covered: slides (`.agents/rules-slides.md`), the legacy Rnw sheets in lectures that haven't adopted the template.

## Rules

- The binding spec is `exercises-template/README.md` in this repo; lecture repos have it as `exercises/README.md`. Read it before working on a sheet and follow it, in particular [Writing a new sheet](../exercises-template/README.md#writing-a-new-sheet), the [Markup rules](../exercises-template/README.md#markup-rules), the [Notebooks](../exercises-template/README.md#notebooks) rules and the [checklist](../exercises-template/README.md#checklist-before-committing).
- Create new sheets with `make new-sheet` in `exercises/` ([Writing a new sheet](../exercises-template/README.md#writing-a-new-sheet)), not by copying another sheet.
- Refer to sections of the README by anchor (`README.md#notebooks`), never by number; `scripts/check_readme_refs.sh` checks this.
- Never change the template files in a lecture (`exercises/_quarto.yml`, `quarto.mk`, `Makefile`, `.gitignore`, `README.md`, `_quarto/`): they are overwritten by updates. Changes to the template go into `exercises-template/` in lecture_service; lecture-specific settings go into `exercises/_lecture.yml`.
- Since I2ML is not part of lecture_service anymore, it has its own copy of the setup and its own `EXERCISE_SPEC.md`, which stays authoritative for I2ML until it switches to the template.
