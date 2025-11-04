# AGENTS.md

**Purpose.** This repository hosts university lecture slides (LaTeX beamer) and supporting code for multiple ML courses. Agents must **use our shared infrastructure and mini DSL** instead of inventing alternatives. Prefer local documentation under `./lecture_service.wiki` and the code in `./latex-math` and `./vistool`.

---

## Repository layout (opened workspace)

```
lecture_service
├─ lecture_service.wiki/  # GitHub Wiki (submodule, authoritative docs)
├─ latex-math/            # Central LaTeX macro library (submodule)
├─ vistool/               # R package for lecture visualizations (submodule)
├─ lecture_*/             # Lecture repos (lecture_i2ml, lecture_sl, lecture_optimization, …)
├─ service/               # Shared LaTeX styles, templates, scripts (managed upstream)
├─ scripts/, R/, Makefile # Build & dev tooling for all lectures
└─ …
```

**When answering or editing, ALWAYS read these first (in order):**
1. `./lecture_service.wiki/Slides.md` (slides, mini LaTeX DSL)
2. `./lecture_service.wiki/Slide-Code-Guide.md` (code style & file layout)
3. `./lecture_service.wiki/Slides-Compilation.md` (how to compile)
4. `./lecture_service.wiki/latex-math.md` (notation policy & update flow)
5. `./latex-math/combined.tex` (actual macro definitions)
6. `./vistool/vignettes/*.Rmd` (R package documentation)

---

## Ground rules (MUST follow)

- **Use R (not Python) for lecture figures and scripts.**  
- **Never define new LaTeX macros in slide content.** Use macros from `latex-math`.  
- **Always use our mini LaTeX DSL.** For frames, images, itemize environements etc.
- **Do not edit `service/` or `latex-math/` INSIDE lecture repos.** Those are managed upstream (e.g., in the `latex-math` submodule).
- **Prefer `vistool` (with ggplot2/plotly backends) for visuals** over ad-hoc plotting.  
- **Keep suggestions reproducible:** seed, explicit library calls, self-contained scripts.  
- **English identifiers & comments.** Clear, minimal, maintainable code.

---

## LaTeX authoring

- **Notation.** Use macros from `latex-math` (e.g., include only, do not redefine).  
  Typical inclusion in a slide preamble:
  ```tex
  % in slides/<topic>/<file>.tex preamble (not in shared style files)
  \input{../latex-math/basic-math}
  \input{../latex-math/basic-ml}
  % add more topic files as needed
  ```
- **Slide environments & styles.** Use the shared styles from `service/` (e.g., `lmu-lecture.sty`, `image.sty`, `customitemize.sty`, etc.). Do **not** modify these in lecture repos.
- **Figures.** Produce images to `../figure/` and include them through the project’s image helpers (from `service/`), rather than raw `\includegraphics` unless instructed otherwise.
- **Math in content.** Use standard LaTeX math constructs. If a macro exists in `latex-math`, use it instead of writing raw symbols.

**Avoid:**
- Creating or redefining macros in slide files.
- Adding packages ad hoc in slide files if the shared preamble already provides them.

---

## R code authoring (figures & demos)

**Defaults**
- Place source under `rsrc/`. One script produces one artifact with matching names:
  - `rsrc/<slug>.R` → `figure/<slug>.png` (or `.pdf`, `.html` if relevant).
- Always include at top:
  ```r
  # rsrc/<slug>.R
  set.seed(1L)
  # library(vistool) if `vistool` can render that plot
  # add: library(mlr3); library(mlr3learners); library(mlr3pipelines) when needed
  ```
- Prefer `vistool`’s 3-step pattern: **initialize → (optionally) add layers → plot/save**.

**Avoid:**
- Base R/ggplot2/plotly plots for content that `vistool` can render.
- Silent global options hidden in the session; scripts must run with `Rscript --vanilla`.

---

## File & naming conventions (enforced by agents)

- **Scripts** live in `rsrc/` and are named after the artifact they produce.
- **Artifacts** go to `figure/` (plots) or `tables/` (LaTeX tables via `kableExtra`).
- **Reproducibility**: `set.seed()`, all libraries at top, script runs “cold”.
- If a figure’s origin is non-obvious, add a brief `%` comment referencing the generating script.

---

## Working with `latex-math`

- Treat `latex-math/` as **read-only** in lecture repos.  
- If you need a new macro, **propose it upstream** in `slds-lmu/latex-math`; then update the local copy via the prescribed workflow (action/PR).
- Include required `.tex` files directly in the **slide preamble** (not in shared preambles).

---

## Definition of done (for agent-created changes)

- Slides compile using `lecheck` **or** the per-chapter Makefile.
- New/changed figures are reproducible from `rsrc/` and saved under `figure/`.
- LaTeX content uses `latex-math` macros; no local macro definitions were introduced.
- No edits to `service/` or `latex-math/` in lecture repos.
- Commit message explains what changed; large new code blocks include a short header comment.

---

## Troubleshooting quick checks

- If macros are “undefined,” verify the correct `\input{../latex-math/<file>}` lines are present in the slide preamble and that the local `latex-math/` is up to date.
