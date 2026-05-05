# Rules for math in latex slides

- Use the macros in the `latex-math` folder for common symbols
- If an expression is used often but not in latex-math yet, bring it up iun chat and offer to add
- Have latex formulas in src as readable as possible

- Use `$$ ... $$` to denote display math, not `\[`
- The `equation` environment is equivalent to `\[ ... \]`, which we do not use in favor of the simple `$$ ... $$`.
- Do not use `eqnarray` and remove it where you see it. It has been deprecated for years and `align` or `$$ ... $$` is usually preferred.

- Do not use English orthography (`.`, `,`) in math formulas
- Avoid "manual whitespace control" in formulas as much as possible, keep them simply;
  don't use "," often, maybe some well-placed q(q)uad sometimes

- Do not use `{ }` around single-character elements unless required;
  to display $e^x$, use `e^x` rather than `e^{x}`
- Vector / Matrix transposition is denoted using `^T`
- For delimiters such as parentheses and vertical bars, the "simple" versions are preferred,
  so no `\left` and `\right` stuff, use this only when ABSOLUTELY necessary
