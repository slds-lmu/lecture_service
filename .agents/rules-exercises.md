# Rules for exercise sheets (Quarto)

## Scope

- Exercise sheets written in Quarto: a `<sheet>.qmd` per sheet in `exercises/<chapter>/`, with one notebook per language (`sol_<sheet>_R.ipynb`, `sol_<sheet>_py.ipynb`).
- Applies to writing new sheets, editing sheets, and converting existing sheets from LaTeX, Rnw or Rmd.
- Not covered: slides (`.agents/rules-slides.md`), the legacy Rnw sheets in lectures that haven't adopted the template.

## Rules

- The binding spec is `exercises-template/README.md` in this repo; lecture repos have it as `exercises/README.md`. Read it before working on a sheet and follow it, in particular the template (section 5), the markup rules (section 6), the notebook rules (section 7) and the checklist (section 10).
- Create new sheets with `make new-sheet` in `exercises/` (section 9), not by copying another sheet.
- Never change the template files in a lecture (`exercises/_quarto.yml`, `quarto.mk`, `Makefile`, `.gitignore`, `README.md`, `_quarto/`): they are overwritten by updates. Changes to the template go into `exercises-template/` in lecture_service; lecture-specific settings go into `exercises/_lecture.yml`.
- Since I2ML is not part of lecture_service anymore, it has its own copy of the setup and its own `EXERCISE_SPEC.md`, which stays authoritative for I2ML until it switches to the template.
