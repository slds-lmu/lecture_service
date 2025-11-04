---
mode: 'agent'
model: GPT-5-Codex (Preview)
tools: ['edit', 'search/codebase', 'runCommands', 'problems', 'changes', 'fetch', 'githubRepo', 'todos']
description: 'Cleanup LaTeX source code'
---
Your goal is to cleanup the source code (macros, environments, styles, ...) of the provided (attached) LaTeX source file. Note that the compiled PDF should not change drastically, wording should stay the **exact** same. However, do correct simple typos.

Requirements:
* **Follow the rules as defined in the [wiki](../../lecture_service.wiki/Slides.md)!**
* Use our custom [latex-math](../../latex-math/) macros for _all_ equations (if possible).
* Do not use `vbframe`, instead use `framei` or `frame2`.
* Prefer setting the font size (e.g., `small`) after the `frame` command, e.g., `\begin{framei}[fs=small]{...}`.
* The result should match the quality of this [reference](../../lecture_i2ml/slides/ml-basics/slides-basics-data.tex).
