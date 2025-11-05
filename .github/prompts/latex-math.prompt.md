---
mode: 'agent'
model: 'Claude Sonnet 4.5' 
tools: ['edit', 'search/codebase', 'runCommands', 'problems', 'changes', 'fetch', 'githubRepo', 'todos']
description: 'Cleanup latex-math to use our custom macros'
---
Your goal is to ensure all math (equations, in-line, etc.) in the provided (attached) LaTeX source file use our custom macros, as defined in [latex-math](../../latex-math/). Note that the compiled PDF should change at all, this is purely a cleanup of our source code! **ONLY SWAP OUT EXACT MATCHES**, if there are none, do not feel forced to make any changes!

Requirements:
* It is absolutely essential that you work in **small steps** (each step should equal exactly one equation / math block).
* If a source file from `latex-math` is attached, it most definitely useful (contains macros that should & can be used)!
* Make sure to include the relvant parts with `\input{../../latex-math/relevant-part}` at the top of the file.
* Always check [basic-math](../../latex-math/basic-math.tex) and [basic-ml](../../latex-math/basic-ml.tex).
