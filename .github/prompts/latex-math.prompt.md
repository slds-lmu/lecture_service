---
agent: 'agent'
model: 'GPT-5.2' 
tools: ['edit', 'search/codebase', 'execute/getTerminalOutput', 'execute/runInTerminal', 'read', 'search', 'web/fetch', 'web/githubRepo', 'todo']
description: 'Cleanup LaTeX math to use our custom macros'
---
Your goal is to ensure all math (equations, in-line, etc.) in the provided (attached) LaTeX source file use our custom macros, as defined in [latex-math](../../latex-math/). Note that the compiled PDF should change at all, this is purely a cleanup of our source code! **ONLY SWAP OUT EXACT MATCHES**, if there are none, do not feel forced to make any changes!

Requirements:
* It is absolutely essential that you work in **small steps** (each step should equal exactly one equation / math block).
* If a source file from `latex-math` is attached, it most definitely useful (contains macros that should & can be used)!
* Make sure to include the relvant parts with `\input{../../latex-math/relevant-part}` at the top of the file.
* Always check [basic-math](../../latex-math/basic-math.tex) and [basic-ml](../../latex-math/basic-ml.tex).
*  Do not use `{ }` around single-character elements unless required:
   -  To display $e^x$, use `e^x` rather than `e^{x}`
*  Use `$$ ... $$` to denote display math [others disagree, but we accept that](https://tex.stackexchange.com/questions/503/why-is-preferable-to)
*  The `equation` environment is equivalent to `\[ ... \]`, which we do not use in favor of the simple `$$ ... $$`.
*  Do not use `eqnarray` and remove it where you see it. It has been deprecated for years and `align` or `$$ ... $$` is usually preferred.
*  Only use `align` environments if you truly need alignment, use `$$ ... $$` instead
*  Do not use English orthography (`.`, `,`) in math formulas
*  Matrix transposition is denoted using `^T`
    e.g., $(\mathbf{X}^T \mathbf{X})^{-1}$ rather than $(\mathbf{X}^\top \mathbf{X})^{-1}$
*  For delimiters such as parentheses and vertical bars, the "simple" versions are preferred:
   -  `(  )` $$( \sum_{i=1}^n x_i^2 + y_i^2 )$$  
   - `|  |` $$| \sum_{i=1}^n x_i^2 + y_i^2 |$$  
   - `||  ||` $$|| \sum_{i=1}^n x_i^2 + y_i^2 ||$$  
* If absolutely necessary, paired delimiters can be used:
  -  `\left(  \right)` $$\left(\sum_{i=1}^n x_i^2 + y_i^2 \right)$$
  -  `\lvert  \rvert` $$\lvert \sum_{i=1}^n x_i^2 + y_i^2 \rvert$$
  -  `\lVert  \rVert` $$\lVert \sum_{i=1}^n x_i^2 + y_i^2 \rVert$$
