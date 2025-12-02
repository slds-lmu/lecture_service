---
agent: 'agent'
model: 'Claude Opus 4.5 (Preview)' 
tools: ['edit', 'search/codebase', 'runCommands', 'problems', 'changes', 'fetch', 'githubRepo', 'todos']
description: 'Cleanup LaTeX source code'
---
Your goal is to cleanup the source code (macros, environments, styles, ...) of the provided (attached) LaTeX source file. Note that the compiled PDF should not change drastically, wording should stay the **exact** same. However, do correct simple typos.

Requirements:
* **You MUST follow the rules as defined in the [wiki](../../lecture_service.wiki/Slides.md)!**
* It is absolutely essential that you work in **small steps** (each step should equal exactly one frame). `\framebreak`s should be changed to multiple frames with the same title.
* Delete old, commented-out frames and similar legacy code; however, if the comment is R code that produces a figure **that is still in use**, convert this to an R script (`rsrs` folder).
* Do NOT use `vbframe`, instead use `framei` or `framev`.
* Do NOT use `\includegraphics`, instead use our custom image helpers.
* For columns, use `\splitV{}` and its derivatives.
* Prefer setting the font size (e.g., `small`) after the `frame` command, e.g., `\begin{framei}[fs=small]{...}`.
* The result should match the quality of this [reference](../../lecture_i2ml/slides/ml-basics/slides-basics-data.tex).
